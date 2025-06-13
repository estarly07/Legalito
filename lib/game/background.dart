import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:legalito/game/game_assets.dart';

class Background extends SpriteComponent with HasGameRef {
  Background();

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(GameAssets.backgroundGame);
    size = gameRef.size;
    position = Vector2.zero();
    priority = -1; // Dibuja detrás de todo
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    size = canvasSize; // Mantiene el fondo del tamaño completo
  }
}
