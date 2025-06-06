import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/simple_questions/bloc/simple_questions_bloc.dart';

class SimpleQuestionsScreen extends StatefulWidget {
  const SimpleQuestionsScreen({Key? key}) : super(key: key);

  @override
  _SimpleQuestionsScreenState createState() => _SimpleQuestionsScreenState();
}

class _SimpleQuestionsScreenState extends State<SimpleQuestionsScreen> {
  final TextEditingController _questionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Questions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your problem here',
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    context.read<SimpleQuestionsBloc>().add(
                      SubmitProblem(_questionController.text),
                    );
                    _questionController.clear();
                  },
                  child: const Text('Analizar'),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Answer:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: BlocBuilder<SimpleQuestionsBloc, SimpleQuestionsState>(
                builder: (context, state) {
                  if (state is SimpleQuestionsInitial) {
                    return const Text(
                      'Enter your question and press "Preguntar".',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  } else if (state is SimpleQuestionsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SimpleQuestionsLoaded) {
                    return SingleChildScrollView(
                      child: Text(
                        state.answer,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    );
                  } else if (state is SimpleQuestionsError) {
                    return Text(
                      'Error: ${state.message}',
                      style: const TextStyle(fontSize: 16.0, color: Colors.red),
                    );
                  }
                  return const SizedBox.shrink(); // Should not reach here
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}
