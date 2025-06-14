import 'package:flutter/material.dart';
import 'package:legalito/game/legalito_game.dart';

class GameOverOverlay extends StatelessWidget {
  final LegalitoGame game;

  const GameOverOverlay({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo oscuro traslúcido
        Container(
          color: Colors.black.withOpacity(0.7),
          width: double.infinity,
          height: double.infinity,
        ),

        // Contenido central
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Texto principal con sombra
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.greenAccent.withOpacity(0.8),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Legalito dice:',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.greenAccent.withOpacity(0.8),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  '¡Te declaras culpable de perder!',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
                child: Text(
                  'Puntaje: ${game.score}',
                ),
              ),
              const SizedBox(height: 40),

              // Botón circular de reiniciar
              GestureDetector(
                onTap: () {
                  game.resetGame();
                  game.overlays.remove('gameOver');
                  game.overlays.add(
                      'countdown'); // Mostrar cuenta atrás antes de reiniciar
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Botón de salir en la esquina inferior derecha
        Positioned(
          bottom: 32,
          right: 24,
          child: ElevatedButton.icon(
            onPressed: () {
              game.overlays.remove('gameOver');
              Navigator.of(context).pop(); // Vuelve a la app
            },
            icon: const Icon(Icons.exit_to_app),
            label: const Text(
              'Salir',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              iconColor: Colors.white,
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
