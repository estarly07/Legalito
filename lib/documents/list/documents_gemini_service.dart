import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:myapp/core/gemini.dart'; // Assuming this path is correct

class DocumentsGeminiService {
  late final GenerativeModel _model;

  DocumentsGeminiService() {
    // Use the API key from the example Gemini service.
    // Replace 'YOUR_API_KEY' with the actual API key if it's not managed elsewhere.
    _model = GenerativeModel(
      model: modelGemini, // Or the appropriate model for document search
      apiKey: apikeyGemini,
    );
  }

  Future<List<String>> fetchRelatedDocuments(String query) async {
    try {
      final content = [
        Content.text(
          'A partir de la siguiente consulta: "$query", dame una lista de nombres de archivos o títulos de documentos legales relacionados de Colombia. Devuélveme únicamente los títulos, uno por línea, sin explicaciones ni detalles adicionales.',
        ),
      ];

      final response = await _model.generateContent(content);

      if (response.text != null) {
        // Split the response text into lines to get individual document entries
        final documentEntries =
            response.text!
                .split('\n')
                .where((line) => line.trim().isNotEmpty)
                .toList();
        return documentEntries;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching related documents: $e');
      return []; // Return an empty list on error
    }
  }
}
