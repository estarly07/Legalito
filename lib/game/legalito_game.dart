import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legalito/game/audio_manager.dart';
import 'package:legalito/game/background.dart';
import 'package:legalito/game/bird.dart';
import 'package:legalito/game/bloc/high_score_bloc.dart';
import 'package:legalito/game/bloc/high_score_event.dart';
import 'package:legalito/game/disco_filter.dart';
import 'package:legalito/game/jefe_component.dart';
import 'package:legalito/game/models/Jefe.dart';
import 'package:legalito/game/nero_filter.dart';
import 'package:vibration/vibration.dart';
import 'barrier.dart';

const double _barrierInterval = 2.5;
const double _velocityBarriers = 150;
const int _intervalBoss = 5;
const velocidadCambio =
    5.0; // puedes ajustar qué tan rápido cambia la velocidad de los tubos

class LegalitoGame extends FlameGame with HasCollisionDetection, TapDetector {
  late Bird bird;
  late TextComponent scoreText;
  final BuildContext context;
  int score = 0;
  double _barrierTimer = 0;
  final List<Barrier> passedBarriers = [];

  bool isGameStarted = false;
  bool isGameOver = false;
  bool moverseVerticalmente = false;
  late final AudioManagerFlame _audioManager;
  // Jefes
  JefeComponent? jefeActivo;
  int puntosInicioJefe = -1;
  double velocidadTuberias = _velocityBarriers;
  double targetVelocidadTuberias = _velocityBarriers;
  DiscoFilter? discoFilter = null;
  NeroFilterComponent? _neroFilter;

  LegalitoGame(
      {super.children, super.world, super.camera, required this.context});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _audioManager = AudioManagerFlame();
    await _audioManager.init(); // Precarga canciones
    addBackground();
    addBird();
    await addScoreText();
  }

  @override
  void onDispose() {
    desactivarBackgroundSong();
    super.onDispose();
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

  void resetJefe() {
    if (jefeActivo != null) remove(jefeActivo!);
    switch (jefeActivo?.jefe.tipo) {
      case JefeTipo.djGrandMom:
        desactivarDJMode();
        break;
      case JefeTipo.jefePrisas:
        desactivarEmpleyor();
        break;
      case JefeTipo.ladronNero:
        desactivarLadronNero();
        break;
      case null:
    }
    jefeActivo = null;
    targetVelocidadTuberias = _velocityBarriers;
  }

  void increaseScore() {
    score++;
    scoreText.text = score.toString();

    if (jefeActivo != null) {
      if (score - puntosInicioJefe >= 5) {
        resetJefe();
      }
    } else {
      if (score % _intervalBoss == 0) {
        final jefe = (jefesDisponibles..shuffle()).first;
        puntosInicioJefe = score;
        switch (jefe.tipo) {
          case JefeTipo.djGrandMom:
            activarDJMode();
            break;
          case JefeTipo.jefePrisas:
            activarEmpleyorMode();
            break;
          case JefeTipo.ladronNero:
            activarNeroMode();
            break;
        }
        if (jefe.tipo != JefeTipo.djGrandMom) {
          targetVelocidadTuberias = jefe.velocidadTuberias;
        }
        jefeActivo = JefeComponent(jefe);
        add(jefeActivo!);
      }
    }
  }

  void resetScore() {
    score = 0;
    scoreText.text = '0';
    passedBarriers.clear();
    jefeActivo = null;
    velocidadTuberias = _velocityBarriers;
  }

  void resetGame() {
    isGameStarted = false;
    isGameOver = false;
    resetJefe();
    resetScore();
    removeWhere((component) => component is Barrier);
    bird.position = Vector2(100, size.y / 2);
    bird.angle = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameStarted && !isGameOver) {
      velocidadTuberias = _interpolate(
        velocidadTuberias,
        targetVelocidadTuberias,
        dt,
        velocidadCambio,
      );

      _barrierTimer += dt;
      if (_barrierTimer >= _barrierInterval) {
        _barrierTimer = 0;
        spawnBarrier();
      }
    }
  }

// Método auxiliar de interpolación
  double _interpolate(double actual, double target, double dt, double factor) {
    final diff = target - actual;
    final step = diff * dt * factor;
    return (diff.abs() < 1.0) ? target : actual + step;
  }

  void spawnBarrier() {
    final barrier = Barrier(size.x + 50); // Aparece fuera de pantalla
    add(barrier);
  }

  void endGame() {
    isGameOver = true;
    switch (jefeActivo?.jefe.tipo) {
      case JefeTipo.djGrandMom:
        desactivarDJMode();
        break;
      case JefeTipo.jefePrisas:
        desactivarEmpleyor();
        break;
      case JefeTipo.ladronNero:
        desactivarLadronNero();
        break;
      case null:
    }
    desactivarBackgroundSong();
    overlays.add('gameOver');
/*     Future.value(hasVibrator()).then((hasVibrator) {
      if (hasVibrator) Vibration.vibrate();
    }); */
    context.read<HighScoreBloc>().add(UpdateHighScore(score));
  }

  Future<bool> hasVibrator() async => await Vibration.hasVibrator();
  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);

    if (isGameStarted && !isGameOver) {
      bird.jump();
    }
  }

  void activarDJMode() {
    pausarBackgroundSong();
    _audioManager.playDJ();
    discoFilter = DiscoFilter(screenSize: size);
    add(discoFilter!);
    moverseVerticalmente = true;

    // Aquí puedes reproducir también la música del DJ
  }

  void activarNeroMode() {
    pausarBackgroundSong();
    _audioManager.playNeroBoss();
    _neroFilter = NeroFilterComponent();
    add(_neroFilter!);
  }

  void activarEmpleyorMode() {
    pausarBackgroundSong();
    _audioManager.playEmpleyorBoss();
  }

  void desactivarDJMode() {
    discoFilter?.removeFromParent();
    _audioManager.stopDJ();
    moverseVerticalmente = false;
    reaundarBackgroundSong();
    // Y detener la música
  }

  void desactivarLadronNero() {
    _neroFilter?.removeFromParent();
    _audioManager.stopNeroBoss();
    reaundarBackgroundSong();
  }

  void desactivarEmpleyor() {
    _audioManager.stopEmpleyorBoss();
    reaundarBackgroundSong();
  }

  void activarBackgroundSong() {
    _audioManager.playBackground();
  }

  void desactivarBackgroundSong() {
    _audioManager.stopBackground();
    _audioManager.stopDJ();
  }

  void pausarBackgroundSong() {
    _audioManager.pausarBackgroundSong();
  }

  void reaundarBackgroundSong() {
    _audioManager.reaundarBackgroundSong();
  }
}
