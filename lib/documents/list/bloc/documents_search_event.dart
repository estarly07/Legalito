sealed class DocumentsSearchEvent {}

class SearchDocuments extends DocumentsSearchEvent {
  final String query;

  SearchDocuments(this.query);
}