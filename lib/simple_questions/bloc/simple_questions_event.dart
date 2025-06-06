part of 'simple_questions_bloc.dart';

abstract class SimpleQuestionsEvent {
  const SimpleQuestionsEvent();

  @override
  List<Object> get props => [];
}

class SubmitQuestion extends SimpleQuestionsEvent {
  final String question;

  const SubmitQuestion(this.question);

  @override
  List<Object> get props => [question];
}
