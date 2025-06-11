import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:legalito/database_helper.dart';
import 'login_service.dart';
import 'package:legalito/chat/chat.dart';

// Events
abstract class LoginEvent {}

class LoginWithEmailAndPassword extends LoginEvent {
  final String email;
  final String password;

  LoginWithEmailAndPassword({required this.email, required this.password});
}

class SignUpWithEmailAndPassword extends LoginEvent {
  final String email;
  final String password;

  SignUpWithEmailAndPassword({required this.email, required this.password});
}

class SendEmailVerification extends LoginEvent {}

// States
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginError extends LoginState {
  final String error;

  LoginError(this.error);
}

Future<void> _saveLoginStatus(bool isLoggedIn) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', isLoggedIn);
}

// BLoC
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginService _loginService;

  LoginBloc(this._loginService) : super(LoginInitial()) {
    on<LoginWithEmailAndPassword>(_onLoginWithEmailAndPassword);
    on<SignUpWithEmailAndPassword>(_onSignUpWithEmailAndPassword);
    on<SendEmailVerification>(_onSendEmailVerification);
  }

  void _onLoginWithEmailAndPassword(
      LoginWithEmailAndPassword event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      await _loginService.signInWithEmailAndPassword(
          event.email, event.password);
      await _fetchAndSaveChats();
      await _saveLoginStatus(true);
      emit(LoginSuccess());
    } on FirebaseAuthException catch (e) {
      emit(LoginError(e.message ?? 'An unknown error occurred'));
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }

  void _onSignUpWithEmailAndPassword(
      SignUpWithEmailAndPassword event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      await _loginService.signUpWithEmailAndPassword(
          event.email, event.password);
      await _saveLoginStatus(true);
      emit(LoginSuccess());
    } on FirebaseAuthException catch (e) {
      emit(LoginError(e.message ?? 'An unknown error occurred'));
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }

  void _onSendEmailVerification(
      SendEmailVerification event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      await _loginService.sendEmailVerification();
      emit(LoginSuccess()); // Or a specific state for email verification sent
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }

  Future<void> _fetchAndSaveChats() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final ref = FirebaseDatabase.instance.ref('users/$userId/chats');
        final snapshot = await ref.get();

        if (snapshot.exists) {
          final chatsData = snapshot.value as Map<dynamic, dynamic>;
          final databaseHelper = DatabaseHelper();

          for (final chatEntry in chatsData.entries) {
            final chatId = chatEntry.key as String;
            final chatData = chatEntry.value as Map<dynamic, dynamic>;

            final chat = Chat.fromFirebase(chatId, chatData);

            await databaseHelper.insertChat(chat);
          }
        }
      } catch (e) {
        // Handle error during fetching or saving chats (e.g., log it)
        print('Error fetching and saving chats: $e');
      }
    }
  }
}
