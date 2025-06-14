import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/widgets.dart';
import 'package:legalito/game/game_assets.dart';
import 'legalito_game.dart';

class Barrier extends PositionComponent
    with HasGameRef<LegalitoGame>, CollisionCallbacks {
  static const double speed = 150;
  static const double gapSize = 150;

  late RectangleComponent topPipe;
  late RectangleComponent bottomPipe;

  final double startX;

  Barrier(this.startX);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    position = Vector2(startX, 0);
    size = Vector2(80, gameRef.size.y);

    final random = Random();
    final holeY = 125 + random.nextDouble() * (gameRef.size.y - 200 - gapSize);
    final pipeWidth = 40.0;
    final pipeXPosition = 25.0;

    // === TUBERÍA SUPERIOR ===
    topPipe = RectangleComponent(
      size: Vector2(pipeWidth, holeY),
      position: Vector2(pipeXPosition, 0),
      paint: Paint()
        ..color = const Color(0xFF4CAF50).withOpacity(0), // invisible
    )..add(RectangleHitbox());
    add(topPipe);

    final topImage = SpriteComponent()
      ..sprite = await gameRef.loadSprite(GameAssets.pipeTop)
      ..size = Vector2(pipeWidth * 2, holeY)
      ..position = Vector2(0, 0);
    add(topImage);

    // === TUBERÍA INFERIOR ===
    final pipeHeightBottom = gameRef.size.y - holeY - gapSize;
    final pipePostionYBottom = holeY + gapSize;
    bottomPipe = RectangleComponent(
      size: Vector2(pipeWidth, pipeHeightBottom),
      position: Vector2(pipeXPosition, pipePostionYBottom),
      paint: Paint()
        ..color = const Color(0xFF4CAF50).withOpacity(0), // invisible
    )..add(RectangleHitbox());
    add(bottomPipe);

    final bottomImage = SpriteComponent()
      ..sprite = await gameRef.loadSprite(GameAssets.pipeBottom)
      ..size = Vector2(pipeWidth * 2, pipeHeightBottom)
      ..position = Vector2(0, pipePostionYBottom);
    add(bottomImage);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!gameRef.isGameStarted || gameRef.isGameOver) return;

    position.x -= speed * dt;

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
