import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:myapp/core/gemini.dart';

class SurveyGeminiService {
  late final GenerativeModel _model;

  SurveyGeminiService() {
    _model = GenerativeModel(model: modelGemini, apiKey: apikeyGemini);
  }

  Future<List<Map<String, dynamic>>> fetchFormStructure(
    String documentName,
  ) async {
    try {
      final prompt ="""
      Genera un arreglo JSON que contenga los campos necesarios para un formulario titulado "$documentName".
      Cada objeto dentro del arreglo debe incluir las siguientes claves:
      "label": una cadena de texto con el nombre visible del campo.
      "type": una cadena que indique el tipo de dato (por ejemplo: "text", "number", "date", "boolean").
      "required": un valor booleano que indique si el campo es obligatorio.
      "key": una cadena única que sirva como identificador del campo.
      Asegúrate de incluir al menos 3 campos distintos y de que la salida sea un JSON válido.
      """;
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        throw Exception('Gemini API returned empty response.');
      }

      // Basic parsing assuming the response is a JSON string
      // More robust parsing might be needed depending on Gemini's exact output format
      final jsonString =
          response.text!.replaceAll('```json', '').replaceAll('```', '').trim();

      // Using dart:convert for JSON decoding
      return (json.decode(jsonString) as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching form structure: $e');
      rethrow; // Re-throw the exception to be caught by the BLoC
    }
  }

  Future<String> generateDocumentContent(
    String documentName,
    Map<String, dynamic> answers,
  ) async {
    try {
      final prompt =
          'Generate the content for a "$documentName" using the following information:\n\n${json.encode(answers)}. Provide only the generated document content as a plain string, without any extra formatting like markdown.';
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        throw Exception('Gemini API returned empty response for document generation.');
      }

      return response.text!.trim();
    } catch (e) {
      print('Error generating document content: $e');
      rethrow; // Re-throw the exception
    }
  }
}
