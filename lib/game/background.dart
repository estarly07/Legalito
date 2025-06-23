import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/widgets.dart';
import 'package:legalito/game/game_assets.dart';
import 'package:legalito/game/legalito_game.dart'; // Import your game file to access the score

class Background extends SpriteComponent with HasGameRef<LegalitoGame> {
  // List of background asset paths
  final List<String> _backgroundAssets = [
    GameAssets.backgroundGame, // Replace with your actual asset paths
    GameAssets.backgroundNight, // Replace with your actual asset paths
    GameAssets.backgroundMorning, // Replace with your actual asset paths
    GameAssets.backgroundBeach,
    GameAssets.backgroundNight, // Replace with your actual asset paths
    GameAssets.backgroundWinter,
    GameAssets.backgroundAutumn,
    GameAssets.backgroundNightTwo,
  ];

  int _currentBackgroundIndex = 0;
  int _lastScoreThreshold = 0; // To track when to change the background

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
    // Get the current score from the game
    final currentScore = gameRef.score;

    if (!initial) {
      if (currentScore >= _lastScoreThreshold + 10) {
        _currentBackgroundIndex =
            (_currentBackgroundIndex + 1) % _backgroundAssets.length;
        final asset = _backgroundAssets[_currentBackgroundIndex];

        // Opcional: desvanece el sprite actual
        // Fade out actual (si quieres ocultar antes de cargar el nuevo)
        await add(
          OpacityEffect.to(
            0,
            EffectController(duration: 0.3, curve: Curves.easeOut),
            onComplete: () async {
              sprite = await gameRef.loadSprite(asset);
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
        // Update the last score threshold
        _lastScoreThreshold =
            (currentScore ~/ 10) * 10; // Set to the current 10-point multiple
      }
    } else {
      sprite =
          await gameRef.loadSprite(_backgroundAssets[_currentBackgroundIndex]);
    }
  }
}
