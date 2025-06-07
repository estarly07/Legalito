import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/chat/chat_list/chat_list_screen.dart';
import 'package:myapp/database_helper.dart';
import 'package:myapp/chat/legal_assistant/legal_assistant_bloc.dart';
import 'package:myapp/documents/list/documents_screen.dart';
import 'package:myapp/documents/survey/survey_screen.dart';
import 'package:myapp/menu/menu_screen.dart';
import 'package:myapp/simple_questions/bloc/simple_questions_bloc.dart';
import 'package:myapp/simple_questions/simple_questions_gemini_service.dart';
import 'chat/chat_list/bloc/chat_list_bloc.dart';
import 'welcome_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'simple_questions/simple_questions_screen.dart';
import 'theme.dart';
import 'chat/legal_assistant/legal_assistant_screen.dart';
import 'simulator_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final db = DatabaseHelper();
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), // Apply the custom theme
      initialRoute: '/bienvenida',
      routes: {
        '/bienvenida': (context) => const WelcomeScreen(),
        '/menu': (context) => MenuScreen(),
        '/suvey_document': (context) => SurveyScreen(),
        '/asistente_legal':
            (context) => BlocProvider(
              create: (context) => LegalAssistantBloc(db),
              child: const LegalAssistantScreen(),
            ),
        '/chats':
            (context) => BlocProvider(
              create: (context) => ChatListBloc(db),
              child: const ChatListScreen(),
            ),
        '/documentos': (context) => const DocumentsScreen(),
        '/simple_questions':
            (context) => BlocProvider(
              create:
                  (context) =>
                      SimpleQuestionsBloc(SimpleQuestionsGeminiService()),
              child: const SimpleQuestionsScreen(),
            ),
        '/simulador': (context) => const SimulatorScreen(),
      },
    );
  }
}
