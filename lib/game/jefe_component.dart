import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:legalito/game/legalito_game.dart';
import 'package:legalito/game/models/Jefe.dart';
import 'package:flame/palette.dart';

class JefeComponent extends PositionComponent with HasGameRef<LegalitoGame> {
  final Jefe jefe;

  JefeComponent(this.jefe);

  @override
  Future<void> onLoad() async {
    position = Vector2(0, gameRef.size.y - 120);
    size = Vector2(gameRef.size.x, 100);
    priority = 999;
    await super.onLoad();
    add(SpriteComponent()
      ..sprite = await Sprite.load(jefe.assetImage)
      ..position = Vector2(size.x - 250, -200)
      ..size = Vector2(350, 400));
    add(_FraseNube(jefe.frase));
  }
}

class _FraseNube extends PositionComponent {
  final String frase;

  _FraseNube(this.frase);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final textPaint = TextPaint(
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );

    final text = TextComponent(
      text: frase,
      textRenderer: textPaint,
    )..anchor = Anchor.topLeft;

    await text.onLoad();

    const double padding = 12;
    const double tailSize = 10;

    final double width = text.size.x + padding * 2;
    final double height = text.size.y + padding * 2;

    final nubeShape = _NubeShapeComponent(
      width: width,
      height: height,
      tailSize: tailSize,
      paint: Paint()..color = Colors.white,
    );

    add(nubeShape);

    text.position = Vector2(padding, padding);
    add(text);

    size = Vector2(width, height + tailSize);
  }
}

class _NubeShapeComponent extends ShapeComponent {
  final double width;
  final double height;
  final double tailSize;

  _NubeShapeComponent({
    required this.width,
    required this.height,
    required this.tailSize,
    required Paint paint,
  }) : super(paint: paint);

  @override
  void render(Canvas canvas) {
    final path = Path()
      ..moveTo(20, height)
      ..arcToPoint(
        Offset(0, height - 20),
        radius: const Radius.circular(20),
        clockwise: false,
      )
      ..lineTo(0, 20)
      ..arcToPoint(
        Offset(20, 0),
        radius: const Radius.circular(20),
        clockwise: false,
      )
      ..lineTo(width - 20, 0)
      ..arcToPoint(
        Offset(width, 20),
        radius: const Radius.circular(20),
        clockwise: false,
      )
      ..lineTo(width, height - 20)
      ..arcToPoint(
        Offset(width - 20, height),
        radius: const Radius.circular(20),
        clockwise: false,
      )
      ..lineTo(40, height)
      ..lineTo(30, height + tailSize) // Cola del bocadillo
      ..lineTo(20, height)
      ..close();

    canvas.drawPath(path, paint);
  }
}
