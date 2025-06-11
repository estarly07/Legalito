import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:legalito/chat/chat.dart';
import 'package:legalito/chat/chat_list/bloc/chat_list_state.dart';
import 'package:legalito/database_helper.dart';
import 'package:legalito/chat/chat_list/bloc/chat_list_event.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final DatabaseHelper _databaseHelper;

  ChatListBloc(this._databaseHelper) : super(ChatListLoading()) {
    on<FetchChats>(_onFetchChats);
    on<DeleteAllChatsEvent>(_onDeleteAllChats);
  }

  Future<void> _onFetchChats(
    FetchChats event,
    Emitter<ChatListState> emit,
  ) async {
    emit(ChatListLoading());
    try {
      await emit.forEach<List<Chat>>(
        _databaseHelper.getChatsStream(),
        onData: (chats) => ChatListLoaded(chats),
        onError: (error, stackTrace) =>
            ChatListError('Failed to fetch chats: ${error.toString()}'),
      );
    } catch (e) {
      emit(ChatListError('Failed to fetch chats: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteAllChats(
    DeleteAllChatsEvent event,
    Emitter<ChatListState> emit,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseDatabase.instance.ref('users/${user.uid}/chats').remove();
      }
      await _databaseHelper.deleteAllChats();
      add(FetchChats()); // Refresh the chat list after deletion
    } catch (e) {
      emit(ChatListError('Failed to delete chats: ${e.toString()}'));
    }
  }
}
