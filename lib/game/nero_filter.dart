import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class NeroFilterComponent extends PositionComponent with HasGameRef {
  NeroFilterComponent();

  @override
  Future<void> onLoad() async {
    size = gameRef.size;
    position = Vector2.zero();
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.65,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.4),
        ],
        stops: [0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);

    // Agrega una capa marrón/verde opaca para simular suciedad
    final dirtPaint = Paint()
      ..color = const Color(0xFF3E3E1F).withOpacity(0.07);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), dirtPaint);
  }
}
