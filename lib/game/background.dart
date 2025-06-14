import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/widgets.dart';
import 'package:legalito/game/game_assets.dart';
import 'package:legalito/game/legalito_game.dart';

class Background extends SpriteComponent with HasGameRef<LegalitoGame> {
  String _currentAsset = '';

  Background();

  @override
  Future<void> onLoad() async {
    size = gameRef.size;
    position = Vector2.zero();
    await _updateSprite(initial: true);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateSprite();
  }

  Future<void> _updateSprite({bool initial = false}) async {
    final asset = _getBackgroundAssetForScore(gameRef.score);

    if (asset != _currentAsset) {
      _currentAsset = asset;

      // Opcional: desvanece el sprite actual
      if (!initial) {
        // Fade out actual (si quieres ocultar antes de cargar el nuevo)
        await add(
          OpacityEffect.to(
            0,
            EffectController(duration: 0.3, curve: Curves.easeOut),
            onComplete: () async {
              sprite = await gameRef.loadSprite(_currentAsset);
              // Fade in nueva imagen
              add(
                OpacityEffect.to(
                  1,
                  EffectController(duration: 0.5, curve: Curves.easeIn),
                ),
              );
            },
          ),
        );
      } else {
        sprite = await gameRef.loadSprite(_currentAsset);
      }
    }
  }

  String _getBackgroundAssetForScore(int score) {
    if (score <= 10) return GameAssets.backgroundGame;
    if (score <= 20) return GameAssets.backgroundNight;
    return GameAssets.backgroundMorning;
  }
}
