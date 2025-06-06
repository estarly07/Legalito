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
 final content = [Content.text("Analyze the following problem description and provide a solution:\n\n$question")];
      final response = await _model.generateContent(content);
      return response.text ?? 'No response from Gemini.';
    } catch (e) {
      print('Error asking Gemini: $e');
      return 'Error getting response from Gemini.';
    }
  }
}