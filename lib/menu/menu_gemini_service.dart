import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:myapp/core/gemini.dart';

Future<List<String>> fetchLegalTips() async {
  final model = GenerativeModel(model: modelGemini, apiKey: apikeyGemini);
  final content = [
    Content.text(
        'Generate 5 short legal tips relevant to everyday life. Each tip should be concise.'),
  ];

  final response = await model.generateContent(content);

  if (response.text != null) {
    // Assuming Gemini returns tips separated by newlines or similar.
    // You might need to adjust the splitting logic based on the actual API response format.
    final tips = response.text!
        .split('\n')
        .where((tip) => tip.isNotEmpty)
        .toList();
    return tips.take(5).toList(); // Ensure we only return up to 5 tips
  } else {
    return [];
  }
}