import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DiscoFilter extends RectangleComponent {
  final List<Color> _colors = [
    Colors.red.withOpacity(0.3),
    Colors.blue.withOpacity(0.3),
    Colors.purple.withOpacity(0.3),
    Colors.green.withOpacity(0.3),
    Colors.orange.withOpacity(0.3),
  ];

  int _currentColorIndex = 0;
  double _timer = 0.0;
  final double switchInterval; // segundos entre colores

  DiscoFilter({
    required Vector2 screenSize,
    this.switchInterval = 0.3,
  }) : super(
          size: screenSize,
          position: Vector2.zero(),
          paint: Paint()..color = Colors.red.withOpacity(0.3),
          priority: 100, // encima de todo
        );

  @override
  void update(double dt) {
    super.update(dt);

    _timer += dt;
    if (_timer >= switchInterval) {
      _timer = 0;
      _currentColorIndex = (_currentColorIndex + 1) % _colors.length;
      paint.color = _colors[_currentColorIndex];
    }
  }
}
