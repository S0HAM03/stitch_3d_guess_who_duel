import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'character.dart';
import '../data/characters_data.dart';

enum GamePhase { waitingInLobby, selectingCard, playing, gameOver }
enum GameResult { none, win, lose }

class ChatMessage {
  final String sender;
  final String message;
  final DateTime timestamp;
  final bool isSystem;

  ChatMessage({
    required this.sender,
    required this.message,
    DateTime? timestamp,
    this.isSystem = false,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'sender': sender,
    'message': message,
    'isSystem': isSystem,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
    sender: map['sender'],
    message: map['message'],
    isSystem: map['isSystem'] ?? false,
    timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
  );
}

class GameState extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot>? _lobbySubscription;

  // Local Player
  String localPlayerName = '';
  int wins = 0;
  int gamesPlayed = 0;
  int gems = 0;

  // Lobby
  String selectedTopic = 'default';
  String lobbyCode = '';
  bool isHost = false;
  bool guestJoined = false;
  String hostName = 'Player 1';
  String guestName = 'Player 2';

  // Chat
  List<ChatMessage> chatMessages = [];

  // Game
  GamePhase phase = GamePhase.waitingInLobby;
  GameResult result = GameResult.none;
  List<Character> boardCharacters = [];
  Character? mySecretCard;
  Character? opponentSecretCard;
  bool opponentSelectedCard = false;

  bool isPlayerTurn = false;
  int opponentStandingCount = 12;
  int? turnEndTimestamp;

  // Question logic
  Map<String, dynamic>? currentQuestion;

  void updateLocalPlayerName(String name) {
    localPlayerName = name;
    hostName = name; // If they host, use their name
    guestName = name; // If they join, use their name
    notifyListeners();
  }

  void setTopic(String topic) {
    selectedTopic = topic;
    if (isHost && lobbyCode.isNotEmpty) {
      _firestore.collection('lobbies').doc(lobbyCode).update({'selectedTopic': topic});
    }
    notifyListeners();
  }

  // --- Firebase Sync Handling ---
  
  void _listenToLobby(String code) {
    _lobbySubscription?.cancel();
    _lobbySubscription = _firestore.collection('lobbies').doc(code).snapshots().listen((snapshot) {
      if (!snapshot.exists) {
        if (phase != GamePhase.waitingInLobby) {
          chatMessages.add(ChatMessage(sender: 'System', message: 'Lobby closed by host.', isSystem: true));
          resetGame();
        }
        return;
      }

      final data = snapshot.data() as Map<String, dynamic>;
      
      // Update Guest Joined Status
      bool newGuestJoined = data['guestJoined'] ?? false;
      if (newGuestJoined && !guestJoined) {
        chatMessages.add(ChatMessage(sender: 'System', message: 'Player 2 joined the lobby!', isSystem: true));
      }
      guestJoined = newGuestJoined;

      // Update Topic
      selectedTopic = data['selectedTopic'] ?? 'default';

      // Update Phase
      String phaseStr = data['phase'] ?? 'waitingInLobby';
      GamePhase newPhase = GamePhase.values.firstWhere((e) => e.name == phaseStr);
      
      if (newPhase == GamePhase.selectingCard && phase == GamePhase.waitingInLobby) {
        // Game started!
        boardCharacters = CharactersData.getCharactersForTopic(selectedTopic);
        for (final c in boardCharacters) c.isKnockedDown = false;
        result = GameResult.none;
        mySecretCard = null;
        opponentSecretCard = null;
        opponentSelectedCard = false;
        opponentStandingCount = boardCharacters.length;
        isPlayerTurn = isHost ? (data['turn'] == 'host') : (data['turn'] == 'guest');
        chatMessages.add(ChatMessage(sender: 'System', message: 'Game started! Pick your secret card.', isSystem: true));
      }
      phase = newPhase;

      // Update Turn
      String turnStr = data['turn'] ?? 'host';
      isPlayerTurn = isHost ? (turnStr == 'host') : (turnStr == 'guest');
      turnEndTimestamp = data['turnEndTime'];

      // Update Question
      currentQuestion = data['currentQuestion'] != null ? Map<String, dynamic>.from(data['currentQuestion']) : null;

      // Update Standing Counts
      if (isHost) {
        opponentStandingCount = data['guestStandingCount'] ?? 12;
      } else {
        opponentStandingCount = data['hostStandingCount'] ?? 12;
      }

      // Update Cards
      if (isHost) {
        opponentSelectedCard = data['guestSelected'] ?? false;
        if (data['guestSecretCard'] != null) {
          opponentSecretCard = Character(
            name: data['guestSecretCard']['name'],
            imageUrl: data['guestSecretCard']['imageUrl'],
          );
        }
      } else {
        opponentSelectedCard = data['hostSelected'] ?? false;
        if (data['hostSecretCard'] != null) {
          opponentSecretCard = Character(
            name: data['hostSecretCard']['name'],
            imageUrl: data['hostSecretCard']['imageUrl'],
          );
        }
      }

      // Check if both selected
      if (phase == GamePhase.selectingCard && (data['hostSelected'] ?? false) && (data['guestSelected'] ?? false)) {
        phase = GamePhase.playing;
        chatMessages.add(ChatMessage(sender: 'System', message: 'Both players selected. Game begins!', isSystem: true));
        if (isHost) _startNewTurn();
      }

      // Handle Guess Result
      if (data['lastGuess'] != null) {
        String sender = data['lastGuess']['sender'];
        String guessedName = data['lastGuess']['guessedName'];
        bool wasCorrect = data['lastGuess']['wasCorrect'] ?? false;

        if (sender != (isHost ? 'host' : 'guest')) {
          // This is the incoming guess from opponent
          if (wasCorrect) {
            result = GameResult.lose;
            phase = GamePhase.gameOver;
          } else {
            chatMessages.add(ChatMessage(sender: 'System', message: 'Opponent guessed $guessedName, but it was wrong!', isSystem: true));
          }
        }
      }

      // Update Chat
      if (data['chat'] != null) {
        List<dynamic> chatData = data['chat'];
        if (chatData.length > chatMessages.length) {
          chatMessages = chatData.map((m) => ChatMessage.fromMap(m as Map<String, dynamic>)).toList();
        }
      }

      notifyListeners();
    });
  }

  // --- Lobby Methods ---

  Future<void> hostGame() async {
    isHost = true;
    lobbyCode = _generateCode();
    guestJoined = false;
    phase = GamePhase.waitingInLobby;
    chatMessages = [
      ChatMessage(sender: 'System', message: 'Lobby created! Share code $lobbyCode.', isSystem: true),
    ];
    
    await _firestore.collection('lobbies').doc(lobbyCode).set({
      'hostName': localPlayerName.isEmpty ? 'Host' : localPlayerName,
      'guestJoined': false,
      'selectedTopic': selectedTopic,
      'phase': 'waitingInLobby',
      'hostSelected': false,
      'guestSelected': false,
      'currentQuestion': null,
      'turn': 'host',
      'hostStandingCount': 12,
      'guestStandingCount': 12,
      'chat': chatMessages.map((m) => m.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    _listenToLobby(lobbyCode);
    notifyListeners();
  }

  Future<bool> joinLobby(String code) async {
    if (code.length == 4) {
      final doc = await _firestore.collection('lobbies').doc(code).get();
      if (doc.exists) {
        final data = doc.data()!;
        if (data['guestJoined'] == true) {
          return false; // Lobby full
        }

        isHost = false;
        lobbyCode = code;
        guestJoined = true;
        phase = GamePhase.waitingInLobby;
        
        await _firestore.collection('lobbies').doc(code).update({
          'guestJoined': true,
          'guestName': localPlayerName.isEmpty ? 'Guest' : localPlayerName,
        });

        _listenToLobby(code);
        return true;
      }
    }
    return false;
  }

  void sendMessage(String text) {
    final sender = isHost ? hostName : guestName;
    final message = ChatMessage(sender: sender, message: text);
    
    _firestore.collection('lobbies').doc(lobbyCode).update({
      'chat': FieldValue.arrayUnion([message.toMap()])
    });
  }

  // --- Question Methods ---

  void askQuestion(String text) {
    final sender = isHost ? 'host' : 'guest';
    _firestore.collection('lobbies').doc(lobbyCode).update({
      'currentQuestion': {
        'text': text,
        'sender': sender,
        'status': 'pending',
      }
    });
    
    // Also add to chat for record
    sendMessage("Question: $text");
  }

  void answerQuestion(bool response) {
    if (currentQuestion == null) return;
    
    final answerText = response ? "YES ✅" : "NO ❌";
    sendMessage("Answer: $answerText");

    // Update question status and toggle turn
    _firestore.collection('lobbies').doc(lobbyCode).update({
      'currentQuestion': null, // Clear the current question
      'turn': isHost ? 'guest' : 'host', // Pass turn after answering
      'turnEndTime': DateTime.now().add(const Duration(minutes: 2)).millisecondsSinceEpoch,
    });
  }

  void passTurn() {
    if (!isPlayerTurn || currentQuestion != null) return;
    
    sendMessage("Turn passed ⏩");
    _firestore.collection('lobbies').doc(lobbyCode).update({
      'turn': isHost ? 'guest' : 'host',
      'turnEndTime': DateTime.now().add(const Duration(minutes: 2)).millisecondsSinceEpoch,
    });
  }

  void _startNewTurn() {
    _firestore.collection('lobbies').doc(lobbyCode).update({
      'turnEndTime': DateTime.now().add(const Duration(minutes: 2)).millisecondsSinceEpoch,
    });
  }

  // --- Game Methods ---

  void startGame(List<Character> characters) {
    boardCharacters = characters;
    for (var c in boardCharacters) c.isKnockedDown = false;
    opponentStandingCount = characters.length;
    
    _firestore.collection('lobbies').doc(lobbyCode).update({
      'phase': 'selectingCard',
      'turn': 'host',
      'hostStandingCount': characters.length,
      'guestStandingCount': characters.length,
      'lastGuess': null,
    });
    notifyListeners();
  }

  void selectMyCard(Character card) {
    mySecretCard = card;
    final fieldPrefix = isHost ? 'host' : 'guest';
    
    _firestore.collection('lobbies').doc(lobbyCode).update({
      '${fieldPrefix}Selected': true,
      '${fieldPrefix}SecretCard': {
        'name': card.name,
        'imageUrl': card.imageUrl,
      },
    });
    notifyListeners();
  }

  void knockDownCard(int index) {
    if (index < boardCharacters.length) {
      boardCharacters[index].isKnockedDown = !boardCharacters[index].isKnockedDown;
      
      final standingCount = boardCharacters.where((c) => !c.isKnockedDown).length;
      final key = isHost ? 'hostStandingCount' : 'guestStandingCount';
      
      _firestore.collection('lobbies').doc(lobbyCode).update({
        key: standingCount,
      });
      
      notifyListeners();
    }
  }

  Future<GameResult> guessCharacter(Character character) async {
    bool isCorrect = character.name == opponentSecretCard?.name;
    
    final guessData = {
      'sender': isHost ? 'host' : 'guest',
      'guessedName': character.name,
      'wasCorrect': isCorrect,
    };

    await _firestore.collection('lobbies').doc(lobbyCode).update({
      'lastGuess': guessData,
    });

    if (isCorrect) {
      result = GameResult.win;
      phase = GamePhase.gameOver;
      await _firestore.collection('lobbies').doc(lobbyCode).update({'phase': 'gameOver'});
      notifyListeners();
      return GameResult.win;
    } else {
      // Wrong guess ends turn immediately in our logic
      passTurn();
      return GameResult.lose;
    }
  }

  void resetGame() {
    if (isHost && lobbyCode.isNotEmpty) {
      _firestore.collection('lobbies').doc(lobbyCode).delete();
    }
    _lobbySubscription?.cancel();
    phase = GamePhase.waitingInLobby;
    result = GameResult.none;
    mySecretCard = null;
    opponentSecretCard = null;
    opponentSelectedCard = false;
    boardCharacters = [];
    guestJoined = false;
    lobbyCode = '';
    currentQuestion = null;
    opponentStandingCount = 12;
    notifyListeners();
  }

  String _generateCode() {
    return (1000 + math.Random().nextInt(9000)).toString();
  }
}
