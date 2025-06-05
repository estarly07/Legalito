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

class _DocumentsScreenState extends State<DocumentsScreen> {
  final TextEditingController _controller = TextEditingController();
  final _debounce = BehaviorSubject<String>();

  late DocumentsSearchBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = DocumentsSearchBloc(DocumentsGeminiService());

    // Escucha del stream con debounce
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
        appBar: AppBar(title: const Text("Buscar documentos")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              BlocBuilder<DocumentsSearchBloc, DocumentsSearchState>(
                builder: (context, state) {
                  final isLoading = state is DocumentsSearchLoading;
                  return TextField(
                    controller: _controller,
                    onChanged: (text) => _debounce.add(text),
                    decoration: InputDecoration(
                      labelText: "Buscar documento (Ej. contrato de arriendo)",
                      prefixIcon:
                          isLoading
                              ? const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                              : const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<DocumentsSearchBloc, DocumentsSearchState>(
                  builder: (context, state) {
                    if (state is DocumentsSearchLoaded) {
                      final docs = state.documents;
                      if (docs.isEmpty) {
                        return const Center(
                          child: Text("No se encontraron documentos."),
                        );
                      }
                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: Text(docs[index]),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/suvey_document',
                                  arguments: {'pushName': docs[index]},
                                );
                              },
                            ),
                          );
                        },
                      );
                    } else if (state is DocumentsSearchError) {
                      return Center(child: Text("Error: ${state.error}"));
                    } else if (state is DocumentsSearchInitial) {
                      return const Center(
                        child: Text("Escribe algo para comenzar"),
                      );
                    } else {
                      return const SizedBox(); // Loading ya se muestra en el input
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
