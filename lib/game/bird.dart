import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame_audio/flame_audio.dart';

import 'game_assets.dart';
import 'legalito_game.dart';

class Bird extends SpriteComponent
    with HasGameRef<LegalitoGame>, CollisionCallbacks {
  final double gravity = 800; // pixeles por segundo^2
  final double jumpVelocity = -300;
  double velocityY = 0;

  Bird() : super(size: Vector2(80, 100.0));

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite(GameAssets.legalitoGame);
    position = Vector2(gameRef.size.x * 0.3, gameRef.size.y / 2);
    anchor = Anchor.center;

    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!gameRef.isGameStarted || gameRef.isGameOver) return;

    velocityY += gravity * dt;
    position.y += velocityY * dt;

    // Limitar la posición para no salir del suelo o cielo
    if (position.y < 0) {
      position.y = 0;
      velocityY = 0;
    }

    if (position.y > gameRef.size.y) {
      gameRef.endGame();
    }
  }

  void jump() {
    velocityY = jumpVelocity;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is! Bird) {
      gameRef.endGame();
    }
  }
}
