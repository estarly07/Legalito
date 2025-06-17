import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/widgets.dart';
import 'package:legalito/game/game_assets.dart';
import 'legalito_game.dart';

class Barrier extends PositionComponent
    with HasGameRef<LegalitoGame>, CollisionCallbacks {
  static const double gapSize = 160;
  static const double pipeWidth = 40.0;
  static const double pipeXPosition = 25.0;

  late RectangleComponent topPipe;
  late SpriteComponent topImage;
  late RectangleComponent bottomPipe;
  late SpriteComponent bottomImage;

  final double startX;

  double _verticalOscillationTimer = 0;
  double baseHoleY = 0;

  Barrier(this.startX);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    position = Vector2(startX, 0);
    size = Vector2(80, gameRef.size.y);

    final random = Random();
    baseHoleY = 100 + random.nextDouble() * (gameRef.size.y - 200 - gapSize);

    // === TUBERÍA SUPERIOR ===
    topPipe = RectangleComponent(
      size: Vector2(pipeWidth, baseHoleY),
      position: Vector2(pipeXPosition, 0),
      paint: Paint()..color = const Color(0xFF4CAF50).withOpacity(0),
    )..add(RectangleHitbox());
    add(topPipe);

    topImage = SpriteComponent()
      ..sprite = await gameRef.loadSprite(GameAssets.pipeTop)
      ..size = Vector2(pipeWidth * 2, baseHoleY)
      ..position = Vector2(0, 0);
    add(topImage);

    // === TUBERÍA INFERIOR ===
    final pipeHeightBottom = gameRef.size.y - baseHoleY - gapSize;
    final pipePositionYBottom = baseHoleY + gapSize;

    bottomPipe = RectangleComponent(
      size: Vector2(pipeWidth, pipeHeightBottom),
      position: Vector2(pipeXPosition, pipePositionYBottom),
      paint: Paint()..color = const Color(0xFF4CAF50).withOpacity(0),
    )..add(RectangleHitbox());
    add(bottomPipe);

    bottomImage = SpriteComponent()
      ..sprite = await gameRef.loadSprite(GameAssets.pipeBottom)
      ..size = Vector2(pipeWidth * 2, pipeHeightBottom)
      ..position = Vector2(0, pipePositionYBottom);
    add(bottomImage);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!gameRef.isGameStarted || gameRef.isGameOver) return;

    // Movimiento horizontal
    position.x -= gameRef.velocidadTuberias * dt;

    // Movimiento vertical si está activo
    if (gameRef.moverseVerticalmente) {
      _verticalOscillationTimer += dt;
      final offsetY = sin(_verticalOscillationTimer * 2) * 30; // Suavemente
      topPipe.position.y = offsetY;
      topImage.position.y = offsetY;
      bottomPipe.position.y = baseHoleY + gapSize + offsetY;
      bottomImage.position.y = baseHoleY + gapSize + offsetY;
    }

    if (position.x + size.x < 0) {
      removeFromParent();
    }

    if (!gameRef.passedBarriers.contains(this) &&
        position.x + size.x < gameRef.bird.position.x) {
      gameRef.increaseScore();
      gameRef.passedBarriers.add(this);
    }
  }
}
