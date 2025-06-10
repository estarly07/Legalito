import 'package:legalito/message.dart'; // Assuming Message class is in message.dart

class Chat {
  final String id; // UUID
  final String name; // First user message
  final List<Message> messages;

  Chat({
    required this.id,
    required this.name,
    required this.messages,
  });

  // Helper for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'messages': messages.map((msg) => msg.toMap()).toList(),
    };
  }

  // Helper for Firestore
  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'],
      name: map['name'],
      messages: (map['messages'] as List<dynamic>)
          .map((msg) => Message.fromMap(msg as Map<String, dynamic>))
          .toList(),
    );
  }
}