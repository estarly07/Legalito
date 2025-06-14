import 'package:bloc/bloc.dart';
import 'package:legalito/game/bloc/high_score_event.dart';
import 'package:legalito/game/bloc/high_score_state.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HighScoreBloc extends Bloc<HighScoreEvent, HighScoreState> {
  HighScoreBloc() : super(HighScoreInitial()) {
    on<LoadHighScore>(_onLoadHighScore);
    on<UpdateHighScore>(_onUpdateHighScore);
  }

  Future<void> _onLoadHighScore(
      LoadHighScore event, Emitter<HighScoreState> emit) async {
    emit(HighScoreLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final highScore = prefs.getInt('highScore') ?? 0;
      emit(HighScoreLoaded(highScore));
    } catch (e) {
      emit(HighScoreError(e.toString()));
    }
  }

  Future<void> _onUpdateHighScore(
      UpdateHighScore event, Emitter<HighScoreState> emit) async {
    if (state is HighScoreLoaded) {
      final currentHighScore = (state as HighScoreLoaded).highScore;
      if (event.newScore > currentHighScore) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('highScore', event.newScore);
          emit(HighScoreLoaded(event.newScore));
        } catch (e) {
          emit(HighScoreError(e.toString()));
        }
      }
    } else {
      // If the state is not HighScoreLoaded, we need to load it first
      // before updating. This can happen if the UpdateHighScore event
      // is dispatched before LoadHighScore.
      add(LoadHighScore());
      // After loading, the next UpdateHighScore event will handle the update.
      // Alternatively, you could handle the update directly here after loading.
      // For simplicity, we'll just reload and let the next event handle it.
    }
  }
}
