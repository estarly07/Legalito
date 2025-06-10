import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/chat_list_bloc.dart';
import 'package:legalito/database_helper.dart';
import 'bloc/chat_list_event.dart';
import 'bloc/chat_list_state.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
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
                  "Mis casos con Legalito",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 20,
                  ),
                ),
                const Spacer(),
                IconButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  icon: const Icon(Icons.delete_forever_rounded),
                  onPressed: () {
                    context.read<ChatListBloc>().add(DeleteAllChatsEvent());
                  },
                ),
              ],
            ),
          ),
        ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: state.chats.length,
              itemBuilder: (context, index) {
                final chat = state.chats[index];
                final lastMessage =
                    chat.messages.isNotEmpty ? chat.messages.last : null;
                final formattedDate =
                    lastMessage?.timestamp != null
                        ? timeago.format(lastMessage!.timestamp, locale: 'es')
                        : "Sin mensajes";

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "/asistente_legal",
                        arguments: chat.id,
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      radius: 24,
                      child: Text(
                        chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                    title: Text(
                      chat.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      formattedDate,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey,
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
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text(
          "Nuevo caso",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        shape: const StadiumBorder(),
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
            Image.asset('assets/legalito_no_cases.png', height: 140),
            const SizedBox(height: 24),
            const Text(
              "¡Aún no tienes casos!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Cuando empieces a chatear con Legalito, tus casos aparecerán aquí ordenaditos 🍊",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, "/asistente_legal"),
              icon: const Icon(Icons.chat),
              label: const Text("Empezar ahora"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
