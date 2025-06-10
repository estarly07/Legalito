import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legalito/simple_questions/simple_questions_gemini_service.dart';

// Events
abstract class SimpleQuestionsEvent {}

class SubmitProblem extends SimpleQuestionsEvent {
  final String question;

  SubmitProblem(this.question);
}

// States
abstract class SimpleQuestionsState {}

class SimpleQuestionsInitial extends SimpleQuestionsState {}

class SimpleQuestionsLoading extends SimpleQuestionsState {}

class SimpleQuestionsLoaded extends SimpleQuestionsState {
  final String answer;

  SimpleQuestionsLoaded(this.answer);
}

class SimpleQuestionsError extends SimpleQuestionsState {
  final String message;

  SimpleQuestionsError(this.message);
}

// BLoC
class SimpleQuestionsBloc
    extends Bloc<SimpleQuestionsEvent, SimpleQuestionsState> {
  final SimpleQuestionsGeminiService _geminiService;

  SimpleQuestionsBloc(this._geminiService) : super(SimpleQuestionsInitial()) {
    on<SubmitProblem>(_onSubmitProblem);
  }

  Future<void> _onSubmitProblem(
    SubmitProblem event,
    Emitter<SimpleQuestionsState> emit,
  ) async {
    emit(SimpleQuestionsLoading());
    try {
      final answer = await _geminiService.analyzeProblem(event.question);
      emit(SimpleQuestionsLoaded(answer));
    } catch (e) {
      emit(SimpleQuestionsError('Error getting answer: ${e.toString()}'));
    }
  }
}
