part of 'simple_questions_bloc.dart';

abstract class SimpleQuestionsState {
  const SimpleQuestionsState();

  @override
  List<Object> get props => [];
}

class SimpleQuestionsInitial extends SimpleQuestionsState {}

class SimpleQuestionsLoading extends SimpleQuestionsState {}

class SimpleQuestionsSuccess extends SimpleQuestionsState {
  final String answer;

  const SimpleQuestionsSuccess(this.answer);

  @override
  List<Object> get props => [answer];
}

class SimpleQuestionsError extends SimpleQuestionsState {
  final String message;

  const SimpleQuestionsError(this.message);

  @override
  List<Object> get props => [message];
}
