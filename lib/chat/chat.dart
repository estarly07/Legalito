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

  // Helper for Firebase Realtime Database
  factory Chat.fromFirebase(String chatId, Map<dynamic, dynamic> chatData) {
    // Assuming the Firebase structure for messages is a map where keys are message IDs
    // or indices and values are the message data.
    // You might need to adjust this based on your actual Firebase structure.
    final List<Message> messagesList = [];
    final dynamic messagesData = chatData['messages'];
    if (messagesData is Map<dynamic, dynamic>) {
      // Iterate through the map entries to handle dynamic keys
      messagesData.entries.forEach((entry) {
        // Assuming Message has a fromMap constructor that can handle dynamic keys/values
        Map<dynamic, dynamic> value = entry.value;
        messagesList.add(Message.fromMap(value));
      });
    }

    return Chat(
      id: chatId,
      name: chatData['name'] as String,
      messages: messagesList,
    );
  }
}
