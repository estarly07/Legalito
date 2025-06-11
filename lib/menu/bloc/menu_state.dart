sealed class MenuState {
  const MenuState();

  @override
  List<Object> get props => [];
}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final List<String> legalTips;

  const MenuLoaded({required this.legalTips});

  @override
  List<Object> get props => [legalTips];
}

class MenuLogoutSuccess extends MenuState {}
