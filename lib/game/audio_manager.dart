import 'dart:async';
import 'package:flame_audio/flame_audio.dart';
import 'package:legalito/game/game_assets.dart';

class AudioManagerFlame {
  double _volume = 1.0;
  final _fadeDuration = Duration(milliseconds: 500);
  AudioPlayer? _djBossSong;
  AudioPlayer? _backgroundSong;

  Future<void> playBackground() async {
    FlameAudio.playLongAudio(GameAssets.backgroundSong).then((song) {
      _backgroundSong = song;
      _fadeIn(_backgroundSong!);
    });
  }

  Future<void> pausarBackgroundSong() async {
    if (_backgroundSong == null) return;
    _fadeOut(_backgroundSong!);
    _backgroundSong!.pause(); // Cuando desaparece
  }

  Future<void> reaundarBackgroundSong() async {
    if (_backgroundSong == null) return;
    _backgroundSong?.resume();
    _fadeIn(_backgroundSong!);
  }

  Future<void> stopBackground() async {
    _backgroundSong?.stop();
  }

  Future<void> playDJ() async {
    FlameAudio.playLongAudio(GameAssets.djSong).then((song) {
      _djBossSong = song;
      _fadeIn(_djBossSong!);
    });
  }

  Future<void> stopDJ() async {
    if (_djBossSong == null) return;
    _fadeOut(_djBossSong!);
    _djBossSong!.stop();
  }

  Future<void> _fadeOut(AudioPlayer audio) async {
    const step = 0.1;
    for (var i = _volume; i > 0.0; i -= step) {
      audio.setVolume(i);
      await Future.delayed(_fadeDuration * step);
    }
    _volume = 0.0;
  }

  Future<void> _fadeIn(AudioPlayer audio) async {
    const step = 0.1;
    for (var i = 0.0; i < 1.0; i += step) {
      audio.setVolume(i);
      await Future.delayed(_fadeDuration * step);
    }
    _volume = 1.0;
  }
}
