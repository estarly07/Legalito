import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/database_helper.dart';

import 'bloc/chat_list_bloc.dart';
import 'bloc/chat_list_event.dart';
import 'bloc/chat_list_state.dart'; // You'll need to add the intl dependency to your pubspec.yaml

import 'package:timeago/timeago.dart' as timeago;

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    context.read<ChatListBloc>().add(FetchChats());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mis casos con Legalito",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed:
                () => context.read<ChatListBloc>().add(DeleteAllChatsEvent()),
          ),
        ],
      ),
      body: BlocBuilder<ChatListBloc, ChatListState>(
        builder: (context, state) {
          if (state is ChatListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChatListLoaded) {
            if (state.chats.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              itemCount: state.chats.length,
              itemBuilder: (context, index) {
                final chat = state.chats[index];
                final lastMessage =
                    chat.messages.isNotEmpty ? chat.messages.last : null;
                final timestamp = lastMessage?.timestamp;
                final formattedDate =
                    timestamp != null
                        ? timeago.format(timestamp, locale: 'es')
                        : "Sin mensajes";

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/asistente_legal",
                          arguments: chat.id,
                        );
                      },
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          chat.name.isNotEmpty
                              ? chat.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      title: Text(
                        chat.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(formattedDate),
                      trailing: const Icon(Icons.arrow_right),
                    ),
                  ),
                );
              },
            );
          } else if (state is ChatListError) {
            return Center(
              child: Text('Error al cargar los chats: ${state.message}'),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, "/asistente_legal"),
        label: const Text("Consultar a Legalito"),
        icon: const Icon(Icons.chat_bubble_outline),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/legalito_front.png', height: 120),
            const SizedBox(height: 24),
            const Text(
              "¡Bienvenido a Legalito!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Aquí verás todos tus chats legales guardados. Presiona el botón de abajo para iniciar una nueva conversación.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
