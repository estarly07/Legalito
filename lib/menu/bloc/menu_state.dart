import 'package:legalito/menu/guide/guide.dart';

sealed class MenuState {
  const MenuState();

  @override
  List<Object> get props => [];
}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final List<String> legalTips;
  final List<Guide> guides; // Added list of Guide objects

  MenuLoaded({
    required this.legalTips,
    required this.guides,
  }); // Updated constructor
}

class MenuLogoutSuccess extends MenuState {}
