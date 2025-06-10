import 'package:bloc/bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:legalito/chat/chat.dart';
import 'package:legalito/chat/legal_assistant/gemini_chat_service.dart';
import 'package:uuid/uuid.dart';
import 'package:legalito/database_helper.dart';
import 'package:legalito/message.dart';

abstract class LegalAssistantEvent {
  const LegalAssistantEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class LoadChatEvent extends LegalAssistantEvent {
  final String chatId;

  const LoadChatEvent(this.chatId);

  @override
  List<Object> get props => [];
}

class SendMessageEvent extends LegalAssistantEvent {
  final String message;

  const SendMessageEvent(this.message);

  @override
  List<Object> get props => [message];
}

/// STATES

abstract class LegalAssistantState {
  const LegalAssistantState();

  @override
  List<Object> get props => [];
}

class LegalAssistantInitial extends LegalAssistantState {}

class LegalAssistantLoading extends LegalAssistantState {}

class LegalAssistantLoaded extends LegalAssistantState {
  final List<Message> messages;

  const LegalAssistantLoaded(this.messages);

  @override
  List<Object> get props => [messages];
}

class LegalAssistantError extends LegalAssistantState {
  final String error;

  const LegalAssistantError(this.error);

  @override
  List<Object> get props => [error];
}

/// BLOC

class LegalAssistantBloc
    extends Bloc<LegalAssistantEvent, LegalAssistantState> {
  final DatabaseHelper _databaseHelper;
  Chat? _currentChat;

  LegalAssistantBloc(this._databaseHelper) : super(LegalAssistantInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<LoadChatEvent>(_onLoadChat);
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<LegalAssistantState> emit,
  ) async {
    try {
      if (_currentChat == null) {
        // Create a new chat if none exists
        final String newChatId = const Uuid().v4();
        final newChat = Chat(
          id: newChatId,
          name: event.message, // First message is the chat name
          messages: [],
        );
        await _databaseHelper.insertChat(newChat);
        _currentChat = newChat; // Set the current chat
      }

      final List<Message> currentMessages =
          state is LegalAssistantLoaded
              ? List.from((state as LegalAssistantLoaded).messages)
              : [];

      // Add user message to the current chat in the database

      // Agregamos el mensaje del usuario
      final userMessage = Message(
        text: "Usuario: ${event.message}",
        isUser: true,
        timestamp: DateTime.now(),
      );
      currentMessages.add(userMessage);
      emit(LegalAssistantLoaded(currentMessages));
      await _databaseHelper.addMessageToChat(_currentChat!.id, userMessage);
      emit(LegalAssistantLoading());

      final List<Content> history =
          currentMessages.map((msg) {
            // Determine the role based on who sent the message
            final String role = msg.isUser ? 'user' : 'model';
            // Extract the text content, removing the prefix "Usuario: " or "Legalito: "
            final String text = msg.text.replaceFirst(
              msg.isUser ? "Usuario: " : "Legalito: ",
              "",
            );
            // Create a Content object with the determined role and text
            return Content(role, [TextPart(text)]);
          }).toList();

      final response =
          history.isEmpty
              ? await GeminiChatService().ask(event.message)
              : await GeminiChatService().sendMessageWithContext(
                history:
                    history.length > 10
                        ? history.sublist(history.length - 10)
                        : history, // Limit to last 10 exchanges (20 messages in Content format)
                newMessage: event.message,
              );

      final geminiMessage = Message(
        text: "Legalito: $response",
        isUser: false,
        timestamp: DateTime.now(),
      );
      currentMessages.add(geminiMessage);

      // Add assistant message to the current chat in the database
      await _databaseHelper.addMessageToChat(_currentChat!.id, geminiMessage);
      emit(LegalAssistantLoaded(currentMessages));
    } catch (e) {
      emit(LegalAssistantError('Error al consultar a Legalito: $e'));
    }
  }

  Future<void> _onLoadChat(
    LoadChatEvent event,
    Emitter<LegalAssistantState> emit,
  ) async {
    try {
      emit(LegalAssistantLoading());
      final Chat? chat = await _databaseHelper.getChat(event.chatId);

      if (chat != null) {
        _currentChat = chat;
        emit(LegalAssistantLoaded(chat.messages));
      } else {
        // Handle case where chat is not found (e.g., emit an error state or navigate back)
        emit(LegalAssistantError('Chat not found'));
      }
    } catch (e) {
      emit(LegalAssistantError('Error loading chat: $e'));
    }
  }
}
