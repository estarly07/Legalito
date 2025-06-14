
abstract class HighScoreEvent {}

class LoadHighScore extends HighScoreEvent {}

class UpdateHighScore extends HighScoreEvent {
  final int newScore;

  UpdateHighScore(this.newScore);
}
