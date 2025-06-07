import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:myapp/core/gemini.dart';

class SimpleQuestionsGeminiService {
  late final GenerativeModel _model;

  SimpleQuestionsGeminiService() {
    _model = GenerativeModel(
      model: modelGemini, // Or the appropriate model for document search
      apiKey: apikeyGemini,
    );
  }

  Future<String> analyzeProblem(String question) async {
    try {
      final content = [
        Content.text("""
  Responde este problema legal como si fueras Legalito, un abogado colombiano amigable que explica todo de forma clara, sencilla y sin palabras complicadas. Imagina que le estás hablando a un amigo que no sabe de leyes. Usa un tono empático, cálido y directo. La respuesta debe estar basada en el contexto legal colombiano. Aquí va el problema:
  $question
  Al final, si es necesario, puedes sugerirle qué pasos podría seguir o si vale la pena hablar con un abogado en persona. Usa un tono amigable y cercano, como si quisieras que la persona se sienta tranquila después de leerte.
  """),
      ];
      final response = await _model.generateContent(content);
      return response.text ?? 'No response from Gemini.';
    } catch (e) {
      print('Error asking Gemini: $e');
      return 'Error getting response from Gemini.';
    }
  }
}
