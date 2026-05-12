import 'dart:io';
import 'dart:convert';

class Lobby {
  final String code;
  WebSocket? host;
  WebSocket? guest;

  Lobby(this.code, this.host);

  void broadcast(String message, WebSocket sender) {
    if (host != null && host != sender && host!.readyState == WebSocket.open) {
      host!.add(message);
    }
    if (guest != null && guest != sender && guest!.readyState == WebSocket.open) {
      guest!.add(message);
    }
  }

  void close() {
    host?.close();
    guest?.close();
  }
}

final Map<String, Lobby> lobbies = {};

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8081);
  print('WebSocket Server running on ws://localhost:8081');

  await for (HttpRequest request in server) {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      WebSocketTransformer.upgrade(request).then(handleWebSocket);
    } else {
      request.response.statusCode = HttpStatus.forbidden;
      request.response.close();
    }
  }
}

void handleWebSocket(WebSocket socket) {
  String? currentLobbyCode;

  socket.listen((message) {
    try {
      final data = jsonDecode(message);
      final type = data['type'];

      if (type == 'host_game') {
        final code = data['code'];
        currentLobbyCode = code;
        lobbies[code] = Lobby(code, socket);
        print('Lobby created: $code');
      } else if (type == 'join_game') {
        final code = data['code'];
        if (lobbies.containsKey(code)) {
          final lobby = lobbies[code]!;
          if (lobby.guest == null) {
            lobby.guest = socket;
            currentLobbyCode = code;
            print('Guest joined lobby: $code');
            
            // Notify host
            lobby.host?.add(jsonEncode({'type': 'guest_joined'}));
            // Notify guest
            socket.add(jsonEncode({'type': 'join_success'}));
          } else {
            socket.add(jsonEncode({'type': 'error', 'message': 'Lobby is full'}));
          }
        } else {
          socket.add(jsonEncode({'type': 'error', 'message': 'Lobby not found'}));
        }
      } else if (currentLobbyCode != null) {
        // Broadcast all other events to the opponent
        final lobby = lobbies[currentLobbyCode!];
        if (lobby != null) {
          lobby.broadcast(message, socket);
        }
      }
    } catch (e) {
      print('Error parsing message: $e');
    }
  }, onDone: () {
    print('Client disconnected.');
    if (currentLobbyCode != null && lobbies.containsKey(currentLobbyCode)) {
      final lobby = lobbies[currentLobbyCode]!;
      if (lobby.host == socket) {
        lobby.guest?.add(jsonEncode({'type': 'opponent_disconnected'}));
        lobbies.remove(currentLobbyCode);
      } else if (lobby.guest == socket) {
        lobby.host?.add(jsonEncode({'type': 'opponent_disconnected'}));
        lobby.guest = null;
      }
    }
  });
}
