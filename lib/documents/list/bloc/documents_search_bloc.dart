import 'package:bloc/bloc.dart';
import 'package:myapp/documents/list/bloc/documents_search_event.dart';
import 'package:myapp/documents/list/bloc/documents_search_state.dart';
import 'package:myapp/documents/list/documents_gemini_service.dart';

class DocumentsSearchBloc extends Bloc<DocumentsSearchEvent, DocumentsSearchState> {
  final DocumentsGeminiService _documentsGeminiService;

  DocumentsSearchBloc(this._documentsGeminiService) : super(DocumentsSearchInitial()) {
    on<SearchDocuments>(_onSearchDocuments);
  }

  Future<void> _onSearchDocuments(
      SearchDocuments event, Emitter<DocumentsSearchState> emit) async {
    emit(DocumentsSearchLoading());
    try {
      final documents = await _documentsGeminiService.fetchRelatedDocuments(event.query);
      emit(DocumentsSearchLoaded(documents));
    } catch (e) {
      emit(DocumentsSearchError(e.toString()));
    }
  }
}