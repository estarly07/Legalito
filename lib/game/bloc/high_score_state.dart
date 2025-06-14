abstract class HighScoreState {}

class HighScoreInitial extends HighScoreState {}

class HighScoreLoading extends HighScoreState {}

class HighScoreLoaded extends HighScoreState {
  final int highScore;

  HighScoreLoaded(this.highScore);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HighScoreLoaded &&
          runtimeType == other.runtimeType &&
          highScore == other.highScore;

  @override
  int get hashCode => highScore.hashCode;
}

class HighScoreError extends HighScoreState {
  final String message;

  HighScoreError(this.message);
}
