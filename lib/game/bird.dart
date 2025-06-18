import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';

import 'game_assets.dart';
import 'legalito_game.dart';

enum BirdState { falling, jumping, crashed }

class Bird extends SpriteComponent
    with HasGameRef<LegalitoGame>, CollisionCallbacks {
  final double gravity = 800; // pixeles por segundo^2
  final double jumpVelocity = -300;
  double velocityY = 0;
  BirdState _state = BirdState.falling;
  Bird() : super(size: Vector2(80, 100.0));
  @override
  Future<void> onLoad() async {
    await _setState(BirdState.falling);
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
    /*  angle = velocityY.clamp(-300, 300) / 600; // Inclina el pájaro ligeramente */
    if (velocityY > 0 && _state != BirdState.falling) {
      _setState(BirdState.falling);
    }

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
    _setState(BirdState.jumping);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is! Bird) {
      _setState(BirdState.crashed);
      gameRef.endGame();
    }
  }

  Future<void> _setState(BirdState state) async {
    if (game.score > 20) {
      sprite = await gameRef.loadSprite(GameAssets.legalitoDolphin);
      size = Vector2(60, 70);
      return;
    }
    if (_state == state) return;
    _state = state;

    switch (state) {
      case BirdState.falling:
        sprite = await gameRef.loadSprite(GameAssets.legalitoGame);
        size = Vector2(80, 100);
        /* add(SizeEffect.to(Vector2(80, 100), EffectController(duration: 0.2))); */
        break;
      case BirdState.jumping:
        sprite = await gameRef.loadSprite(GameAssets.legalitoFlying);
        size = Vector2(60, 60);
        break;
      case BirdState.crashed:
        sprite = await gameRef.loadSprite(GameAssets.legalitoCrying);
        add(SizeEffect.to(Vector2(60, 60), EffectController(duration: 0.2)));
        break;
    }
  }
}
