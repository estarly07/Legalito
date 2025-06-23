import 'dart:async';
import 'package:flutter/material.dart';
import 'package:legalito/game/legalito_game.dart';

class CountdownOverlay extends StatefulWidget {
  final LegalitoGame game;

  const CountdownOverlay({Key? key, required this.game}) : super(key: key);

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> {
  int countdown = 3;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    try {
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (countdown == 1) {
          timer.cancel();
          widget.game.overlays.remove('countdown');
          widget.game.isGameStarted = true;
          widget.game.activarBackgroundSong();
        }
        setState(() {
          countdown--;
        });
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    String text = countdown > 0 ? countdown.toString() : '¡Vamos!';
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                  blurRadius: 20,
                  color: Colors.greenAccent,
                  offset: Offset(0, 4)),
              Shadow(
                  blurRadius: 10, color: Colors.black45, offset: Offset(0, 2)),
            ],
          ),
          child: Text(
            text,
          ),
        ),
      ),
    );
  }
}
