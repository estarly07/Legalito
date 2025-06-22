import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CloudShapePainter extends CustomPainter {
  final Color color;

  CloudShapePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final radius = 20.0;

    // Top-left arc
    path.moveTo(radius, 0);
    path.arcToPoint(Offset(0, radius), radius: Radius.circular(radius));

    // Left side
    path.lineTo(0, size.height - radius);
    path.arcToPoint(Offset(radius, size.height),
        radius: Radius.circular(radius));

    // Bottom side
    path.lineTo(size.width - radius, size.height);
    path.arcToPoint(Offset(size.width, size.height - radius),
        radius: Radius.circular(radius));

    // Right side
    path.lineTo(size.width, radius);
    path.arcToPoint(Offset(size.width - radius, 0),
        radius: Radius.circular(radius));

    // Top side
    path.lineTo(radius, 0);

    path.close(); // Important: this fills the shape!

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CloudBubble extends StatelessWidget {
  final String text;

  const CloudBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          children: [
            CustomPaint(
              painter: CloudShapePainter(color: Colors.white),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                child: DefaultTextStyle(
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
