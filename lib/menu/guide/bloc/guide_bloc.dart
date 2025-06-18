import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Import for FormattedStep

import 'package:legalito/menu/guide/guide_gemini.dart';

part 'guide_event.dart';
part 'guide_state.dart';

class GuideBloc extends Bloc<GuideEvent, GuideState> {
  final GuideGemini _guideGemini = GuideGemini();

  GuideBloc() : super(GuideInitial()) {
    on<GetSolutionStepsEvent>(_onGetSolutionSteps);
  }

  Future<void> _onGetSolutionSteps(
      GetSolutionStepsEvent event, Emitter<GuideState> emit) async {
    emit(GuideLoading());
    try {
      final steps =
          await _guideGemini.getSolutionSteps(event.problemDescription);
      emit(GuideLoaded(steps)); // Emit with List<FormattedStep>
    } catch (e) {
      emit(GuideError(e.toString()));
    }
  }
}
