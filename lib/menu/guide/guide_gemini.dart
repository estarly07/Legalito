import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:legalito/core/gemini.dart';
import 'package:flutter/material.dart';

class FormattedStep {
  final String rawText;
  final List<TextSpan> textSpans;

  FormattedStep(this.rawText, this.textSpans);
}

class GuideGemini {
  final GenerativeModel _model;

  GuideGemini()
      : _model = GenerativeModel(
          model: modelGemini,
          apiKey: apikeyGemini,
        );

  Future<List<FormattedStep>> getSolutionSteps(
      String problemDescription) async {
    try {
      final prompt = '''
Actúa como **Legalito**, un abogado colombiano muy buena onda que ayuda a resolver problemas legales y cotidianos de forma clara, chistosa y paso a paso.

Dado un problema que te diré, quiero que generes una lista de posibles **acciones o tareas** que el usuario puede hacer para solucionarlo. Cada acción debe ser un paso que se pueda intentar, en orden de menor a mayor complejidad.

Por cada paso:
- Explica qué debe hacer el usuario.
- Si aplica y si se puede, da un ejemplo realista de lo que podría decir o hacer.
- Sé empático y usa frases amigables, como si hablaras con una persona común.
- El paso debe ser claro, específico, y debe tener sentido por sí mismo. Si ese paso resuelve el problema, el usuario debe poder marcarlo como solucionado.
- Usa frases divertidas o cercanas cuando sea posible, que representen a un abogado colombiano bacano.
- Usa formato **markdown** para destacar con negrillas.

⚠️ Separa cada paso usando el símbolo: ###

Problema: $problemDescription

Responde solamente con los pasos separados por ### como lo indiqué.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final text = response.text;

      if (text != null && text.trim().isNotEmpty) {
        final rawSteps = text
            .split('###')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        final formattedSteps =
            rawSteps.map((step) => _formatStepText(step)).toList();

        return formattedSteps;
      } else {
        return [
          FormattedStep(
            'No se encontraron pasos. Intenta con otro problema.',
            [
              TextSpan(
                  text: 'No se encontraron pasos. Intenta con otro problema.')
            ],
          )
        ];
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
      final trimmed = line.trim();

      if (trimmed.startsWith('## ')) {
        // Título
        textSpans.add(TextSpan(
          text: trimmed.substring(3) + '\n',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ));
      } else if (trimmed.startsWith('### ')) {
        // Subtítulo
        textSpans.add(TextSpan(
          text: trimmed.substring(4) + '\n',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ));
      } else {
        final boldRegex = RegExp(r'(\*\*[^*]+\*\*|\*[^*]+\*)');
        final matches = boldRegex.allMatches(line);

        int lastMatchEnd = 0;
        for (final match in matches) {
          if (match.start > lastMatchEnd) {
            textSpans
                .add(TextSpan(text: line.substring(lastMatchEnd, match.start)));
          }

          final matchedText = match.group(0)!;

          // Detecta si es ** o *
          final isDouble = matchedText.startsWith('**');
          final cleaned = matchedText.substring(
              isDouble ? 2 : 1, matchedText.length - (isDouble ? 2 : 1));

          textSpans.add(TextSpan(
            text: cleaned,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ));

          lastMatchEnd = match.end;
        }

// Agrega el resto del texto normal si hay algo después del último match
        if (lastMatchEnd < line.length) {
          textSpans.add(TextSpan(text: line.substring(lastMatchEnd)));
        }

        textSpans.add(const TextSpan(text: '\n'));
      }
    }

    return FormattedStep(text, textSpans);
  }
}
