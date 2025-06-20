import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:legalito/core/gemini.dart';

class SurveyGeminiService {
  late final GenerativeModel _model;

  SurveyGeminiService() {
    _model = GenerativeModel(model: modelGemini, apiKey: apikeyGemini);
  }

  Future<List<Map<String, dynamic>>> fetchFormStructure(
    String documentName,
  ) async {
    try {
      final prompt = """
Actúa como un generador de formularios inteligentes.

Tu tarea es crear un arreglo JSON que contenga la estructura necesaria para completar un documento de :"$documentName".

Sigue estas instrucciones:

1. Genera todos los campos necesarios para el contenido del documento, dependiendo del título.
2. Cada campo debe incluir estas claves:
   - "label": el texto visible que explica qué debe ingresar el usuario.
   - "type": el tipo de campo (usa uno de estos: "text", "number", "date", "boolean", "select").
   - "required": true o false, según la necesidad legal del dato.
   - "key": un identificador único en snake_case.
3. Si el campo tiene "type": "select", agrega una clave adicional llamada "options" con un arreglo de opciones que el usuario puede elegir.
4. Sé claro y preciso. Si el documento requiere datos personales (nombre, documento, fecha, dirección, género, etc.), inclúyelos.
5. Devuelve únicamente el arreglo JSON. No incluyas explicaciones ni comentarios.

Ejemplo de un campo con tipo select:

{
  "label": "Género",
  "type": "select",
  "required": true,
  "key": "genero",
  "options": ["Masculino", "Femenino", "Otro"]
}

Recuerda: solo devuelve el arreglo JSON. Nada más.
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
      final prompt = '''
Actúa como un redactor legal profesional colombiano.

Tu tarea es redactar el contenido de un documento de tipo "$documentName".

Usa esta información en formato JSON para completarlo:
${json.encode(answers)}

Sigue estas instrucciones con precisión:

1. El contenido debe estar en **texto plano** (sin HTML, sin markdown).
2. Usa una **estructura clara y profesional**:
   - TÍTULOS PRINCIPALES: en mayúsculas y con salto de línea antes y después.
   - Subtítulos o secciones: con dos puntos (:) al final si aplica.
   - Cada párrafo debe estar separado por una línea en blanco.
3. Redacta con lenguaje formal, claro y coherente.
4. Resalta **elementos clave** como nombres, fechas o cláusulas usando mayúsculas.
5. Si el documento lo requiere, incluye al final líneas de firma como:
   Firma del cliente: ________________________
   Firma del representante: __________________

Importante:
- El texto debe ser 100% plano, sin asteriscos (*), guiones (-), numeraciones, ni símbolos decorativos.
- No agregues comentarios explicativos ni texto fuera del documento.
- Redacta como si fuera un contrato, carta legal o acta notarial profesional.

Devuelve únicamente el contenido del documento estructurado, sin introducción, sin explicación.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        throw Exception(
            'Gemini API returned empty response for document generation.');
      }

      return response.text!.trim();
    } catch (e) {
      print('Error generating document content: $e');
      rethrow;
    }
  }
}
