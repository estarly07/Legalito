// Agrega este widget encima del MenuScreen, usando un Stack o Navigator.pushOverlay
// Este overlay recorre los 4 pasos del tutorial con el fondo oscuro traslúcido

import 'package:flutter/material.dart';
import 'package:legalito/menu/cloud_background.dart';

class MenuTutorialOverlay extends StatefulWidget {
  final VoidCallback onFinish;
  const MenuTutorialOverlay({super.key, required this.onFinish});

  @override
  State<MenuTutorialOverlay> createState() => _MenuTutorialOverlayState();
}

class _MenuTutorialOverlayState extends State<MenuTutorialOverlay> {
  int step = 0;

  final List<_TutorialStep> steps = [
    _TutorialStep(
      showBottom: true,
      description:
          'Aquí puedes hablar con Legalito\npara resolver dudas legales.',
      highlightKey: GlobalObjectKey('asistenteLegal'),
      alignment: Alignment.topLeft,
    ),
    _TutorialStep(
      showBottom: true,
      description:
          'Este botón te ayudará a encontrar\nsoluciones rápidas a tus problemas legales.',
      highlightKey: GlobalObjectKey('solucionarProblema'),
      alignment: Alignment.topRight,
    ),
    _TutorialStep(
      showBottom: false,
      description:
          'Aquí puedes crear guías de documentos\nlegales como contratos o cartas importantes.',
      highlightKey: GlobalObjectKey('documentos'),
      alignment: Alignment.centerLeft,
    ),
    _TutorialStep(
      showBottom: false,
      description:
          'Aquí puedes ver los problemas más comunes y sus posibles soluciones.',
      highlightKey: GlobalObjectKey('problemas'),
      alignment: Alignment.centerLeft,
    ),
    _TutorialStep(
      showBottom: true,
      description:
          '¿Necesitas distraerte? Da doble tap en este banner\ny descubre una forma divertida\nde distraerte con Legalito.',
      highlightKey: GlobalObjectKey('legalitoBanner'),
      alignment: Alignment.centerRight,
    ),
  ];

  void _nextStep() {
    if (step < steps.length - 1) {
      setState(() => step++);
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = steps[step];
    return GestureDetector(
      onTap: _nextStep,
      child: Stack(
        children: [
          // Fondo oscuro que avanza el paso al tocar
          // The tutorial overlay
          CustomPaint(
            size: Size.infinite,
            painter: OverlayWithHolePainter(targetKey: current.highlightKey),
          ),

          // Área resaltada - DEBE ESTAR directamente dentro del Stack
          IgnorePointer(
            child: _HighlightBox(highlightKey: current.highlightKey),
          ),

          // Caja de texto + personaje
          Align(
            alignment:
                current.showBottom ? Alignment.bottomRight : Alignment.topRight,
            child: Padding(
              padding: !current.showBottom
                  ? EdgeInsets.symmetric(horizontal: 8.0, vertical: 100)
                  : const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: current.alignment == Alignment.centerRight
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: CloudBubble(text: current.description),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Image.asset(
                      'assets/legalito_teaching.png',
                      width: 150,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialStep {
  final bool showBottom;
  final String description;
  final GlobalKey highlightKey;
  final Alignment alignment;

  _TutorialStep({
    required this.description,
    required this.highlightKey,
    required this.alignment,
    required this.showBottom,
  });
}

class _HighlightBox extends StatelessWidget {
  final GlobalKey highlightKey;

  const _HighlightBox({required this.highlightKey});

  @override
  Widget build(BuildContext context) {
    final renderBox =
        highlightKey.currentContext?.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? Size.zero;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

    return Container(
      width: size.width + 16,
      height: size.height + 16,
      margin: EdgeInsets.only(
        left: offset.dx - 8,
        top: offset.dy - 8,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 3),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class OverlayWithHolePainter extends CustomPainter {
  final double borderRadius;
  final GlobalKey targetKey;

  OverlayWithHolePainter({
    required this.targetKey,
    this.borderRadius = 16,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect? holeRect = _getHolePosition();
    if (holeRect == null) return;

    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final clearPaint = Paint()..blendMode = BlendMode.clear;

    // Draw background layer
    canvas.saveLayer(Offset.zero & size, Paint());

    // Draw the dark overlay
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), overlayPaint);

    // Clear the hole with rounded corners
    final holePath = Path()
      ..addRRect(
          RRect.fromRectAndRadius(holeRect, Radius.circular(borderRadius)));

    canvas.drawPath(holePath, clearPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
  Rect? _getHolePosition() {
    final RenderBox? renderBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      return position & renderBox.size;
    }
    return null;
  }
}
