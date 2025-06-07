import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/documents/list/bloc/documents_search_bloc.dart';
import 'package:myapp/documents/list/bloc/documents_search_event.dart';
import 'package:myapp/documents/list/bloc/documents_search_state.dart';
import 'package:myapp/documents/list/documents_gemini_service.dart';
import 'package:rxdart/rxdart.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final _debounce = BehaviorSubject<String>();
  late DocumentsSearchBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = DocumentsSearchBloc(DocumentsGeminiService());

    _debounce.debounceTime(const Duration(milliseconds: 700)).listen((query) {
      if (query.trim().isNotEmpty) {
        _bloc.add(SearchDocuments(query));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce.close();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                BlocBuilder<DocumentsSearchBloc, DocumentsSearchState>(
                  builder: (context, state) {
                    return _buildSearchBar(state is DocumentsSearchLoading);
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: BlocBuilder<DocumentsSearchBloc, DocumentsSearchState>(
                    builder: (context, state) {
                      if (state is DocumentsSearchLoaded) {
                        final docs = state.documents;
                        if (docs.isEmpty) {
                          return const Center(
                            child: Text(
                              "No se encontraron documentos.",
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: docs.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildDocumentCard(docs[index], index);
                          },
                        );
                      } else if (state is DocumentsSearchError) {
                        return Center(child: Text("❌ Error: ${state.error}"));
                      } else if (state is DocumentsSearchInitial) {
                        return const Center(
                          child: Text(
                            "🔍 Escribe algo para comenzar",
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      } else {
                        return const SizedBox(); // Loading handled in search bar
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          color: Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.pop(context); // Regresa a la pantalla anterior
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.arrow_back, color: Color(0xFFFA4A0C), size: 24),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          "Buscar documentos",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isLoading) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // Color muy suave
            blurRadius: 24, // Qué tan difusa es la sombra
            spreadRadius: 2, // Qué tanto se extiende desde el widget
            offset: const Offset(0, 8), // Dirección de la sombra (eje X, Y)
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: (text) => _debounce.add(text),
        decoration: InputDecoration(
          hintText: "Ej. contrato de arriendo",
          prefixIcon:
              isLoading
                  ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                  : const Icon(Icons.search_rounded),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard(String title, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + index * 100),
      curve: Curves.easeOut,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/suvey_document',
            arguments: {'pushName': title},
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.insert_drive_file_rounded,
                color: Color(0xFFFA4A0C),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
