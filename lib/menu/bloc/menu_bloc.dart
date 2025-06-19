import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legalito/database_helper.dart';
import 'package:legalito/menu/bloc/menu_event.dart';
import 'package:legalito/menu/bloc/menu_state.dart';
import 'package:legalito/menu/guide/guide.dart';
import 'package:legalito/menu/guide/guideservice.dart';
import 'package:legalito/menu/menu_gemini_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc() : super(MenuInitial()) {
    on<FetchLegalTipsEvent>(_onFetchLegalTips);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onFetchLegalTips(
    FetchLegalTipsEvent event,
    Emitter<MenuState> emit,
  ) async {
    List<String> legalTips = [];
    List<Guide> guides = [];
    try {
      emit(MenuLoading());
      legalTips = await fetchLegalTips();
      emit(MenuLoaded(legalTips: legalTips, guides: guides));
    } catch (e) {
      emit(MenuLoaded(legalTips: legalTips, guides: guides));
      // Handle error, potentially emit an error state
      print('Error fetching legal tips: $e');
    }
    // Independently fetch problems (guides)
    try {
      guides = await GuideService().fetchProblems();
      emit(MenuLoaded(
        legalTips: legalTips,
        guides: guides,
      ));
    } catch (e) {}
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<MenuState> emit,
  ) async {
    try {
      await DatabaseHelper().deleteAllChats();
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      emit(MenuLogoutSuccess());
    } catch (e) {}
  }
}
