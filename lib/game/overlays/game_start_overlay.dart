import 'package:flutter/material.dart';
import 'package:legalito/game/game_assets.dart';
import 'package:legalito/game/legalito_game.dart';

class StartOverlay extends StatelessWidget {
  final LegalitoGame game;

  const StartOverlay({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background de pantalla completa
        Positioned.fill(
          child: Image.asset(
            GameAssets.background,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Image.asset(
            GameAssets.legalito,
            fit: BoxFit.cover,
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2359671079.
            height: MediaQuery.of(context).size.height * 0.5,
          ),
        ),
        Positioned(
          bottom: -100,
          left: -50,
          child: Image.asset(
            GameAssets.pipe,
            fit: BoxFit.cover,
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2359671079.
            height: MediaQuery.of(context).size.height * 0.75,
          ),
        ),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              shadowColor: Colors.black54,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            onPressed: () {
              game.overlays.remove('start');
              game.overlays.add('countdown'); // Mostrar cuenta atrás
            },
            child: const Text(
              'Jugar',
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 50,
                  color: Colors.black,
                ),
              ],
            ),
            child: Text(
              'Mayor puntuación:\n${game.highScore}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        // Imagen de Legalito en esquina inferior derecha
      ],
    );
  }
}
