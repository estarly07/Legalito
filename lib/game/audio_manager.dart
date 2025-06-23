import 'dart:async';
import 'package:flame_audio/flame_audio.dart';
import 'package:legalito/game/game_assets.dart';

class AudioManagerFlame {
  double _volume = 1.0;
  final Duration _fadeDuration = const Duration(milliseconds: 500);

  AudioPlayer? _backgroundSong;
  AudioPlayer? _djBossSong;
  AudioPlayer? _neroBossSong;
  AudioPlayer? _empleyorBossSong;

  /// Inicializa los audios antes de usarlos (para evitar lag).
  Future<void> init() async {
    await FlameAudio.audioCache.loadAll([
      GameAssets.backgroundSong,
      GameAssets.djSong,
      GameAssets.neroSong,
      GameAssets.empleyorSong,
    ]);
  }

  /// Reproduce la canción de fondo (ya precargada).
  Future<void> playBackground() async {
    try {
      final player = await FlameAudio.playLongAudio(GameAssets.backgroundSong);
      _backgroundSong = player;
      _backgroundSong!.setReleaseMode(ReleaseMode.loop);
    } catch (e) {}
  }

  Future<void> pausarBackgroundSong() async {
    try {
      if (_backgroundSong == null) return;
      await _fadeOut(_backgroundSong!);
      await _backgroundSong!.pause();
    } catch (e) {}
  }

  Future<void> reaundarBackgroundSong() async {
    try {
      if (_backgroundSong == null) return;
      await _backgroundSong!.resume();
      _fadeIn(_backgroundSong!);
    } catch (e) {}
  }

  Future<void> stopBackground() async {
    try {
      await _backgroundSong?.stop();
      _backgroundSong = null;
    } catch (e) {}
  }

  Future<void> playDJ() async {
    try {
      final player = await FlameAudio.playLongAudio(GameAssets.djSong);
      _djBossSong = player;
      _djBossSong!.setReleaseMode(ReleaseMode.loop);
      _fadeIn(_djBossSong!);
    } catch (e) {}
  }

  Future<void> stopDJ() async {
    try {
      if (_djBossSong == null) return;
      await _fadeOut(_djBossSong!);
      await _djBossSong?.stop();
      _djBossSong = null;
    } catch (e) {}
  }

  Future<void> playNeroBoss() async {
    try {
      final player = await FlameAudio.playLongAudio(GameAssets.neroSong);
      _neroBossSong = player;
      _neroBossSong!.setReleaseMode(ReleaseMode.loop);
      _fadeIn(_neroBossSong!);
    } catch (e) {}
  }

  Future<void> stopNeroBoss() async {
    try {
      if (_neroBossSong == null) return;
      await _fadeOut(_neroBossSong!);
      await _neroBossSong?.stop();
      _neroBossSong = null;
    } catch (e) {}
  }

  Future<void> playEmpleyorBoss() async {
    try {
      final player = await FlameAudio.playLongAudio(GameAssets.empleyorSong);
      _empleyorBossSong = player;
      _empleyorBossSong!.setReleaseMode(ReleaseMode.loop);
      _fadeIn(_empleyorBossSong!);
    } catch (e) {}
  }

  Future<void> stopEmpleyorBoss() async {
    try {
      if (_empleyorBossSong == null) return;
      await _fadeOut(_empleyorBossSong!);
      await _empleyorBossSong?.stop();
      _empleyorBossSong = null;
    } catch (e) {}
  }

  /// Fade out gradual.
  Future<void> _fadeOut(AudioPlayer audio) async {
    try {
      const step = 0.1;
      for (double i = _volume; i >= 0.0; i -= step) {
        audio.setVolume(i);
        await Future.delayed(_fadeDuration * step);
      }
      _volume = 0.0;
    } catch (e) {}
  }

  /// Fade in gradual.
  Future<void> _fadeIn(AudioPlayer audio) async {
    try {
      const step = 0.1;
      for (double i = 0.0; i <= 1.0; i += step) {
        audio.setVolume(i);
        await Future.delayed(_fadeDuration * step);
      }
      _volume = 1.0;
    } catch (e) {}
  }
}
