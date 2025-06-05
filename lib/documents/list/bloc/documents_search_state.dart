sealed class DocumentsSearchState {
  const DocumentsSearchState();

  @override
  List<Object> get props => [];
}

class DocumentsSearchInitial extends DocumentsSearchState {}

class DocumentsSearchLoading extends DocumentsSearchState {}

class DocumentsSearchLoaded extends DocumentsSearchState {
  const DocumentsSearchLoaded(this.documents);

  final List<String> documents;

  @override
  List<Object> get props => [documents];
}

class DocumentsSearchError extends DocumentsSearchState {
  const DocumentsSearchError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}
