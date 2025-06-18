part of 'guide_bloc.dart';

abstract class GuideState {}

class GuideInitial extends GuideState {}

class GuideLoading extends GuideState {}

class GuideLoaded extends GuideState {
  final List<FormattedStep> steps; // Changed to List<FormattedStep>

  GuideLoaded(this.steps);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuideLoaded &&
          runtimeType == other.runtimeType &&
          listEquals(steps, other.steps);

  @override
  int get hashCode => steps.hashCode;
}

class GuideError extends GuideState {
  final String message;

  GuideError(this.message);
}
