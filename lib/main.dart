import 'package:flutter/material.dart';
import 'package:legalito/chat/chat_list/chat_list_screen.dart';
import 'package:legalito/database_helper.dart';
import 'package:legalito/game/legalito_game.dart';
import 'package:flame/game.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:legalito/chat/legal_assistant/legal_assistant_bloc.dart';
import 'package:legalito/documents/list/documents_screen.dart';
import 'package:legalito/documents/survey/survey_screen.dart';
import 'package:legalito/game/overlays/countdown_overlay.dart';
import 'package:legalito/game/overlays/game_over_overlay.dart';
import 'package:legalito/game/overlays/game_start_overlay.dart';
import 'package:legalito/login/login_bloc.dart';
import 'package:legalito/login/login_screen.dart';
import 'package:legalito/login/login_service.dart';
import 'package:legalito/menu/bloc/menu_bloc.dart';
import 'package:legalito/menu/bloc/menu_event.dart';
import 'package:legalito/menu/menu_screen.dart';
import 'package:legalito/simple_questions/bloc/simple_questions_bloc.dart';
import 'package:legalito/simple_questions/simple_questions_gemini_service.dart';
import 'chat/chat_list/bloc/chat_list_bloc.dart';
import 'welcome_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'simple_questions/simple_questions_screen.dart';
import 'chat/legal_assistant/legal_assistant_screen.dart';
import 'simulator_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(initialRoute: isLoggedIn ? '/menu' : '/bienvenida'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  MyApp({required this.initialRoute});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final db = DatabaseHelper();
    return MaterialApp(
      title: 'Legalito',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), // Apply the custom theme
      initialRoute: initialRoute,
      routes: {
        '/bienvenida': (context) => const WelcomeScreen(),
        '/menu': (context) => BlocProvider(
              create: (context) => MenuBloc()..add(FetchLegalTipsEvent()),
              child: MenuScreen(),
            ),
        '/suvey_document': (context) => SurveyScreen(),
        '/asistente_legal': (context) => BlocProvider(
              create: (context) => LegalAssistantBloc(db),
              child: const LegalAssistantScreen(),
            ),
        '/chats': (context) => BlocProvider(
              create: (context) => ChatListBloc(db),
              child: const ChatListScreen(),
            ),
        '/documentos': (context) => const DocumentsScreen(),
        '/simple_questions': (context) => BlocProvider(
              create: (context) =>
                  SimpleQuestionsBloc(SimpleQuestionsGeminiService()),
              child: const SimpleQuestionsScreen(),
            ),
        '/simulador': (context) => const SimulatorScreen(),
        '/login': (context) => BlocProvider(
              create: (context) => LoginBloc(LoginService()),
              child: LoginScreen(),
            ),
        '/flappy': (context) => GameWidget<LegalitoGame>(
              game: LegalitoGame(),
              initialActiveOverlays: const [
                'start'
              ], // Aquí se muestra al comenzar
              overlayBuilderMap: {
                'start': (context, game) => StartOverlay(game: game),
                'gameOver': (context, game) => GameOverOverlay(game: game),
                'countdown': (context, game) => CountdownOverlay(game: game),
              },
            )
      },
    );
  }
}
