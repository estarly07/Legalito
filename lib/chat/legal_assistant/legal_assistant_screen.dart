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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatId = ModalRoute.of(context)?.settings.arguments as String?;
      if (chatId != null) {
        context.read<LegalAssistantBloc>().add(LoadChatEvent(chatId));
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<LegalAssistantBloc>().add(SendMessageEvent(text));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LegalAssistantBloc, LegalAssistantState>(
      listener: (context, state) {
        if (state is LegalAssistantLoading) {
          setState(() => _isLoading = true);
        } else if (state is LegalAssistantLoaded) {
          setState(() {
            _messages = state.messages;
            _isLoading = false;
          });
        } else if (state is LegalAssistantError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
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
                        Navigator.pop(
                          context,
                        ); // Regresa a la pantalla anterior
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
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/legalito_front.png'),
                    radius: 20,
                  ),
                  const Text(
                    "Legalito",
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
        body: Column(
          children: [
            Expanded(
              child:
                  _messages.isEmpty
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/legalito_analizing.png',
                                height: 120,
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Hola, soy Legalito 👋\nCuéntame tu caso legal y te ayudaré.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        itemCount: _messages.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (_isLoading && index == 0) {
                            return _buildLoadingBubble();
                          }

                          final realIndex = _isLoading ? index - 1 : index;
                          final message =
                              _messages[_messages.length - 1 - realIndex];
                          return _buildChatBubble(message);
                        },
                      ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(Message message) {
    final isUser = message.isUser;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isUser ? const Color(0xFFDCF8C6) : Colors.white;
    final margin =
        isUser
            ? const EdgeInsets.fromLTRB(80, 6, 8, 6)
            : const EdgeInsets.fromLTRB(8, 6, 80, 6);
    final shadow = BoxShadow(
      color: Colors.black12,
      blurRadius: 4,
      offset: const Offset(2, 2),
    );

    return Align(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: margin,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 0),
                bottomRight: Radius.circular(isUser ? 0 : 18),
              ),
              boxShadow: [shadow],
            ),
            child: formatGeminiResponse(
              message.text
                  .replaceFirst("Usuario:", "")
                  .replaceFirst("Legalito:", ""),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 14, top: 2),
            child: Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 6, 80, 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/legalito_front.png', height: 24, width: 24),
            const SizedBox(width: 8),
            const Text(
              'Legalito está escribiendo',
              style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
            ),
            AnimatedDots(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      margin: EdgeInsets.all(10),
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
              icon: const Icon(Icons.send, color: Colors.deepOrange),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedDots extends StatefulWidget {
  const AnimatedDots({super.key});
  @override
  State<AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _dotAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    _dotAnimation = IntTween(begin: 1, end: 3).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotAnimation,
      builder: (_, __) {
        return Text("." * _dotAnimation.value);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
Widget formatGeminiResponse(String rawText) {
    final boldRegex = RegExp(r'\*\*(.*?)\*\*');
    final bulletRegex = RegExp(r'^- (.*)', multiLine: true);
    final titleRegex = RegExp(r'^## (.*)', multiLine: true);

    final lines = rawText.trim().split('\n');
    final spans = <TextSpan>[];

    for (var line in lines) {
      // Título
      if (titleRegex.hasMatch(line)) {
        final match = titleRegex.firstMatch(line);
        spans.add(
          TextSpan(
            text: '${match?.group(1)?.trim()}\n',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        );
        continue;
      }

      // Lista con viñeta
      if (bulletRegex.hasMatch(line)) {
        final match = bulletRegex.firstMatch(line);
        spans.add(
          TextSpan(
            text: '• ${match?.group(1)?.trim()}\n',
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        );
        continue;
      }

      // Negrita en línea
      final parts = <TextSpan>[];
      var currentIndex = 0;

      for (final match in boldRegex.allMatches(line)) {
        if (match.start > currentIndex) {
          parts.add(
            TextSpan(
              text: line.substring(currentIndex, match.start),
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          );
        }

        parts.add(
          TextSpan(
            text: match.group(1),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        );

        currentIndex = match.end;
      }

      // Agregar el resto del texto si hay
      if (currentIndex < line.length) {
        parts.add(
          TextSpan(
            text: line.substring(currentIndex),
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        );
      }

      // Si no hay negritas, agregar línea normal
      spans.addAll(
        parts.isNotEmpty
            ? [TextSpan(children: parts), const TextSpan(text: '\n')]
            : [
              TextSpan(
                text: line + '\n',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
      );
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }