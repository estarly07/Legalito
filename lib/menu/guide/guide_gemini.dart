import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:legalito/core/gemini.dart';
import 'package:flutter/material.dart'; // Import for TextSpan and TextStyle

class FormattedStep {
  final String rawText;
  final List<TextSpan> textSpans;

  FormattedStep(this.rawText, this.textSpans);
}

class GuideGemini {
  final GenerativeModel _model;

  GuideGemini()
      : _model = GenerativeModel(
          model: modelGemini, // Usa tu modelo Gemini
          apiKey: apikeyGemini,
        );

  Future<List<FormattedStep>> getSolutionSteps(
      String problemDescription) async {
    try {
      final prompt = '''
Actúa como **Legalito**, un abogado colombiano súper buena onda y experto en resolver problemas legales y cotidianos en Colombia. Tu misión es ayudar a cualquier persona a entender qué hacer paso a paso, como si se lo explicaras a tu tía o a un amigo que no sabe nada de leyes.

Dado el siguiente problema, entrega una **guía paso a paso muy detallada** para resolverlo. Cada paso debe ser **claro, secuencial y completamente explicado**. No solo digas qué hacer, sino también **cómo hacerlo, dónde hacerlo, qué documentos necesita, a qué lugar debe acudir, cuánto puede demorar, y por qué se hace cada paso.** Usa ejemplos prácticos, consejos útiles y un lenguaje cercano, profesional pero simpático.

### 🔖 Reglas importantes:
- Cada paso debe estar **separado por la línea: `--- PASO ---`**. Ese será el delimitador entre pasos.
- Usa **formato markdown** para títulos, subtítulos y negrillas:
  - Título general: `##`
  - Subtítulo (si aplica): `###`
  - Negritas: `**texto**`
- Usa un tono amistoso, claro y con toques de humor colombiano.
- No incluyas pasos vacíos ni vagos como “puedes demandar”. Mejor explícalo: “Debes ir a la Superintendencia de Industria... con este documento... y pedir esto...”.

---

Problema del usuario: "$problemDescription"

---

Ahora sí, Legalito, danos la guía completica, paso a paso, con toda la actitud. 🎓💼📄
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final text = response.text;
      if (text != null) {
        final rawSteps = text
            .split('--- PASO ---')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        final formattedSteps =
            rawSteps.map((step) => _formatStepText(step)).toList();

        return formattedSteps;
      } else {
        return [];
      }
    } catch (e) {
      print('Error generating solution steps: $e');
      return [
        FormattedStep(
          'Ocurrió un error generando la solución. Inténtalo de nuevo más tarde.',
          [
            TextSpan(
                text:
                    'Ocurrió un error generando la solución. Inténtalo de nuevo más tarde.')
          ],
        ),
      ];
    }
  }

  FormattedStep _formatStepText(String text) {
    final List<TextSpan> textSpans = [];
    final lines = text.split('\n');

    for (var line in lines) {
      if (line.trim().startsWith('## ')) {
        textSpans.add(TextSpan(
          text: line.trim().substring(3) + '\n',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ));
      } else if (line.trim().startsWith('### ')) {
        textSpans.add(TextSpan(
          text: line.trim().substring(4) + '\n',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ));
      } else {
        // Manejo de negrillas **texto**
        final boldRegex = RegExp(r'\*\*(.*?)\*\*');
        final matches = boldRegex.allMatches(line);

        int lastMatchEnd = 0;
        for (final match in matches) {
          if (match.start > lastMatchEnd) {
            textSpans
                .add(TextSpan(text: line.substring(lastMatchEnd, match.start)));
          }
          textSpans.add(TextSpan(
            text: match.group(1),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ));
          lastMatchEnd = match.end;
        }

        if (lastMatchEnd < line.length) {
          textSpans.add(TextSpan(text: line.substring(lastMatchEnd)));
        }

        textSpans.add(const TextSpan(text: '\n'));
      }
    }

    return FormattedStep(text, textSpans);
  }
}
