import 'dart:async';
import 'package:flame_audio/flame_audio.dart';
import 'package:legalito/game/game_assets.dart';

class AudioManagerFlame {
  double _volume = 1.0;
  final Duration _fadeDuration = const Duration(milliseconds: 500);

  AudioPlayer? _backgroundSong;
  AudioPlayer? _djBossSong;

  /// Inicializa los audios antes de usarlos (para evitar lag).
  Future<void> init() async {
    await FlameAudio.audioCache.loadAll([
      GameAssets.backgroundSong,
      GameAssets.djSong,
    ]);
  }

  /// Reproduce la canción de fondo (ya precargada).
  Future<void> playBackground() async {
    final player = await FlameAudio.playLongAudio(GameAssets.backgroundSong);
    _backgroundSong = player;
    _backgroundSong!.setReleaseMode(ReleaseMode.loop);
    _fadeIn(_backgroundSong!);
  }

  Future<void> pausarBackgroundSong() async {
    if (_backgroundSong == null) return;
    await _fadeOut(_backgroundSong!);
    await _backgroundSong!.pause();
  }

  Future<void> reaundarBackgroundSong() async {
    if (_backgroundSong == null) return;
    await _backgroundSong!.resume();
    _fadeIn(_backgroundSong!);
  }

  Future<void> stopBackground() async {
    await _backgroundSong?.stop();
    _backgroundSong = null;
  }

  /// Cambia la velocidad de reproducción de la canción de fondo (1.0 = normal).
  Future<void> setBackgroundPlaybackRate(double rate) async {
    if (_backgroundSong == null) return;
    await _backgroundSong!.setPlaybackRate(rate);
  }

  Future<void> playDJ() async {
    final player = await FlameAudio.playLongAudio(GameAssets.djSong);
    _djBossSong = player;
    _djBossSong!.setReleaseMode(ReleaseMode.loop);
    _fadeIn(_djBossSong!);
  }

  Future<void> stopDJ() async {
    if (_djBossSong == null) return;
    await _fadeOut(_djBossSong!);
    await _djBossSong!.stop();
    _djBossSong = null;
  }

  /// Fade out gradual.
  Future<void> _fadeOut(AudioPlayer audio) async {
    const step = 0.1;
    for (double i = _volume; i >= 0.0; i -= step) {
      audio.setVolume(i);
      await Future.delayed(_fadeDuration * step);
    }
    _volume = 0.0;
  }

  /// Fade in gradual.
  Future<void> _fadeIn(AudioPlayer audio) async {
    const step = 0.1;
    for (double i = 0.0; i <= 1.0; i += step) {
      audio.setVolume(i);
      await Future.delayed(_fadeDuration * step);
    }
    _volume = 1.0;
  }
}
