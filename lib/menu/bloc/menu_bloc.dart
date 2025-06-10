import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legalito/menu/bloc/menu_event.dart';
import 'package:legalito/menu/bloc/menu_state.dart';
import 'package:legalito/menu/menu_gemini_service.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc() : super(MenuInitial()) {
    on<FetchLegalTipsEvent>(_onFetchLegalTips);
  }

  Future<void> _onFetchLegalTips(
    FetchLegalTipsEvent event,
    Emitter<MenuState> emit,
  ) async {
    try {
      emit(MenuLoading());
      final legalTips = await fetchLegalTips();
      emit(MenuLoaded(legalTips: legalTips));
    } catch (e) {
      emit(MenuLoaded(legalTips: []));
      // Handle error, potentially emit an error state
      print('Error fetching legal tips: $e');
    }
  }
}
