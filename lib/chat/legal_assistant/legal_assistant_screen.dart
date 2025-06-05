import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myapp/chat/legal_assistant/legal_assistant_bloc.dart';
import 'package:myapp/message.dart';

class LegalAssistantScreen extends StatefulWidget {
  const LegalAssistantScreen({Key? key}) : super(key: key);

  @override
  State<LegalAssistantScreen> createState() => _LegalAssistantScreenState();
}

class _LegalAssistantScreenState extends State<LegalAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Message> _messages = [];
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // your code goes here
      // Retrieve chat ID from route arguments
      final chatId = ModalRoute.of(context)?.settings.arguments as String?;

      if (chatId != null) {
        // Dispatch LoadChatEvent with the chat ID
        context.read<LegalAssistantBloc>().add(LoadChatEvent(chatId));
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      /* _messages.add(
        _ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      ); */
      context.read<LegalAssistantBloc>().add(SendMessageEvent(text));
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LegalAssistantBloc, LegalAssistantState>(
      listener: (context, state) {
        if (state is LegalAssistantLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is LegalAssistantLoaded) {
          _messages = state.messages;
          setState(() {
            _isLoading = false;
            /* _messages.add(
              _ChatMessage(
                text: state.messages.last,
                isUser: false,
                timestamp: DateTime.now(),
              ),
            ); */
          });
        } else if (state is LegalAssistantError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/legalito_front.png'),
              ),
              const SizedBox(width: 8),
              const Text('Legalito'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child:
                  _messages.isEmpty
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/legalito_front.png',
                                height: 100,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Hola, soy Legalito. Puedes contarme tu caso legal y te ayudaré a entenderlo.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      )
                      : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(8),
                        itemCount: _messages.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (_isLoading && index == 0) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(8, 4, 60, 4),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/legalito_front.png',
                                      height: 24,
                                      width: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Legalito está escribiendo...',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final realIndex = _isLoading ? index - 1 : index;
                          final message =
                              _messages[_messages.length - 1 - realIndex];

                          final isUser = message.isUser;
                          final alignment =
                              isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft;
                          final margin =
                              isUser
                                  ? const EdgeInsets.fromLTRB(60, 4, 8, 4)
                                  : const EdgeInsets.fromLTRB(8, 4, 60, 4);
                          final bubbleColor =
                              isUser ? Colors.blue[200] : Colors.grey[300];

                          return Align(
                            alignment: alignment,
                            child: Column(
                              crossAxisAlignment:
                                  isUser
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: margin,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: bubbleColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft:
                                          isUser
                                              ? const Radius.circular(16)
                                              : const Radius.circular(0),
                                      bottomRight:
                                          isUser
                                              ? const Radius.circular(0)
                                              : const Radius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    message.text
                                        .replaceFirst("Usuario:", "")
                                        .replaceFirst("Legalito:", ""),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    DateFormat(
                                      'HH:mm',
                                    ).format(message.timestamp),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        maxLines: 5,
                        minLines: 1,
                        decoration: const InputDecoration(
                          hintText: 'Escribe tu mensaje...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
