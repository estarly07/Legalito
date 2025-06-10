import 'package:legalito/chat/chat.dart';

abstract class ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<Chat> chats;

  ChatListLoaded(this.chats);
}

class ChatListError extends ChatListState {
  final String message;

  ChatListError(this.message);
}
