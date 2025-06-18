part of 'guide_bloc.dart';

abstract class GuideEvent {}

class GetSolutionStepsEvent extends GuideEvent {
  final String problemDescription;

  GetSolutionStepsEvent(this.problemDescription);
}
