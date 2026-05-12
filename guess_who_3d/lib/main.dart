import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/game_state.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/lobby_screen.dart';
import 'screens/game_screen.dart';
import 'screens/category_screen.dart';
import 'screens/login_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameState(),
      child: const GuessWho3DApp(),
    ),
  );
}

class GuessWho3DApp extends StatelessWidget {
  const GuessWho3DApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guess Who 3D',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/category':
            return MaterialPageRoute(builder: (_) => const CategoryScreen());
          case '/lobby':
            final args = settings.arguments as Map<String, dynamic>?;
            final isHost = args?['isHost'] ?? true;
            return MaterialPageRoute(
                builder: (_) => LobbyScreen(isHost: isHost));
          case '/game':
            return MaterialPageRoute(builder: (_) => const GameScreen());
          default:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      },
    );
  }
}