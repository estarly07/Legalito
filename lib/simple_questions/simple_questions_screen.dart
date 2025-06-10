import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legalito/chat/legal_assistant/legal_assistant_screen.dart';
import 'package:legalito/simple_questions/bloc/simple_questions_bloc.dart';

class SimpleQuestionsScreen extends StatefulWidget {
  const SimpleQuestionsScreen({Key? key}) : super(key: key);

  @override
  State<SimpleQuestionsScreen> createState() => _SimpleQuestionsScreenState();
}

class _SimpleQuestionsScreenState extends State<SimpleQuestionsScreen> {
  final TextEditingController _questionController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 6),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
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
                      child: Icon(
                        Icons.arrow_back,
                        color: Color(0xFFFA4A0C),
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '¿En qué te ayudamos hoy?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.question_answer_outlined,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _questionController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Escribe tu problema legal aquí...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        final text = _questionController.text.trim();
                        if (text.isNotEmpty) {
                          context.read<SimpleQuestionsBloc>().add(
                            SubmitProblem(text),
                          );
                          _questionController.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Consultar'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<SimpleQuestionsBloc, SimpleQuestionsState>(
                builder: (context, state) {
                  if (state is SimpleQuestionsInitial) {
                    return const Center(
                      child: Text(
                        'Describe tu problema legal y presiona "Consultar".',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else if (state is SimpleQuestionsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SimpleQuestionsLoaded) {
                    return SingleChildScrollView(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: formatGeminiResponse(state.answer),
                        ),
                      ),
                    );
                  } else if (state is SimpleQuestionsError) {
                    return Center(
                      child: Text(
                        'Ocurrió un error: ${state.message}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.redAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
