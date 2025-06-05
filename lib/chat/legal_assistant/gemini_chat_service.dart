import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:myapp/core/gemini.dart';

class GeminiChatService {
  static final GeminiChatService _instance = GeminiChatService._internal();

  factory GeminiChatService() => _instance;

  late final GenerativeModel _model;
  late ChatSession _chatSession;

  GeminiChatService._internal() {
    _model = GenerativeModel(
      model: modelGemini,
      apiKey: apikeyGemini,
    );

    _initializeChat([]);
  }

  void _initializeChat(List<Content> history) {
    _chatSession = _model.startChat(
      history: [
        Content('model', [
          TextPart(
            'Actúa como Legalito, un asistente legal colombiano que responde con amabilidad, humor y claridad. '
            'Tu tarea es ayudar a las personas a entender conceptos legales sin dar asesoría legal vinculante. '
            'Habla como si fueras un abogado parcero que explica todo con ejemplos claros y lenguaje humano.',
          ),
        ]),
        ...history,
      ],
    );
  }

  void resetChat() {
    _initializeChat([]);
  }

  Future<String> sendMessageWithContext({
    required List<Content> history,
    required String newMessage,
  }) async {
    // Limit context to the last 10 exchanges (20 messages)
    final limitedHistory =
        history.length > 20 ? history.sublist(history.length - 20) : history;

    // Re-initialize chat with the limited history and the persona
    _initializeChat(limitedHistory);

    return ask(newMessage);
  }

  Future<String> ask(String question) async {
    try {
      final response = await _chatSession.sendMessage(Content.text(question));
      final answer = response.text;
      print("QHUBO $answer");
      if (answer == null || answer.trim().isEmpty) {
        return 'Hmm... no estoy seguro cómo responder eso. ¿Podés explicarme mejor?';
      }
      return answer;
    } catch (e) {
      print('Error con Legalito: $e');
      return 'Uy, se me cruzaron los códigos. Intentá más tarde, ¿sí?';
    }
  }
}
