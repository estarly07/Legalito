import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:myapp/core/gemini.dart';

Future<List<String>> fetchLegalTips() async {
  final model = GenerativeModel(model: modelGemini, apiKey: apikeyGemini);
  final content = [
    Content.text("""
Actúa como Legalito, un abogado colombiano con un tono cercano, claro y sin tecnicismos. Escribe 10 consejos legales breves y útiles para la vida cotidiana en Colombia. Devuélvelos como una lista de frases, una por línea, sin títulos, sin numeración, y sin comillas. Cada frase debe ser un consejo concreto que indique qué hacer o qué evitar.
"""),
  ];

  final response = await model.generateContent(content);

  if (response.text != null) {
    // Assuming Gemini returns tips separated by newlines or similar.
    // You might need to adjust the splitting logic based on the actual API response format.
    final tips =
        response.text!.split('\n').where((tip) => tip.isNotEmpty).toList();
    return tips.take(5).toList(); // Ensure we only return up to 5 tips
  } else {
    return [];
  }
}
