import 'package:legalito/game/game_assets.dart';

enum JefeTipo { ladronNero, jefePrisas }

class Jefe {
  final JefeTipo tipo;
  final String frase;
  final String assetImage;
  final double velocidadTuberias;

  Jefe({
    required this.tipo,
    required this.frase,
    required this.assetImage,
    required this.velocidadTuberias,
  });
}

final List<Jefe> jefesDisponibles = [
  Jefe(
    tipo: JefeTipo.ladronNero,
    frase: '¿Me regala la hora, socio?',
    assetImage: GameAssets.enemyNero,
    velocidadTuberias: 100.0, // más lento
  ),
  Jefe(
    tipo: JefeTipo.jefePrisas,
    frase: '¡Eso es pa’ ayer!',
    assetImage: GameAssets.enemyEmployer,
    velocidadTuberias: 250.0, // más rápido
  ),
];
