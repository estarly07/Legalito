import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legalito/game/background.dart';
import 'package:legalito/game/bird.dart';
import 'package:legalito/game/bloc/high_score_bloc.dart';
import 'package:legalito/game/bloc/high_score_event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'barrier.dart';

class LegalitoGame extends FlameGame with HasCollisionDetection, TapDetector {
  late Bird bird;
  late TextComponent scoreText;
  final BuildContext context;
  int score = 0;
  double _barrierTimer = 0;
  final double _barrierInterval =
      2.5; // Cada 2.5 segundos se genera una nueva barrera

  final List<Barrier> passedBarriers = [];

  bool isGameStarted = false;
  bool isGameOver = false;

  LegalitoGame({super.children, super.world, super.camera, required this.context});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    addBackground();
    addBird();
    await addScoreText();
  }

  void addBackground() {
    final background =
        Background(); // Asegúrate de que esta clase esté bien definida
    add(background);
  }

  void addBird() {
    bird = Bird(); // Debes tener una propiedad `late Bird bird;` en la clase
    add(bird);
  }

  Future<void> addScoreText() async {
    scoreText = TextComponent(
      text: '0',
      position: Vector2(size.x / 2, 20),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(blurRadius: 4, color: Colors.black, offset: Offset(2, 2))
          ],
        ),
      ),
    );
    add(scoreText);
  }

  void increaseScore() {
    score++;
    scoreText.text = score.toString();
  }

  void resetScore() {
    score = 0;
    scoreText.text = '0';
    passedBarriers.clear();
  }

  void resetGame() {
    isGameStarted = false;
    isGameOver = false;
    resetScore();
    removeWhere((component) => component is Barrier);
    bird.position = Vector2(100, size.y / 2);
    bird.angle = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isGameStarted && !isGameOver) {
      _barrierTimer += dt;
      if (_barrierTimer >= _barrierInterval) {
        _barrierTimer = 0;
        spawnBarrier();
      }
    }
  }

  void spawnBarrier() {
    final barrier = Barrier(size.x + 50); // Aparece fuera de pantalla
    add(barrier);
  }

  void endGame() {
    isGameOver = true;

    // Mostrar botón de reintentar o volver al menú
    overlays.add('gameOver');
    context.read<HighScoreBloc>().add(UpdateHighScore(score));
    // Detener el loop del juego (opcional si lo necesitas)
  }

  void stopGame() {
    pauseEngine();
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);

    if (isGameStarted && !isGameOver) {
      bird.jump(); // 👈 Llama la función jump del pájaro
    }
  }
}
