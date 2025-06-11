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

  factory Chat.fromFirebase(String chatId, Map<dynamic, dynamic> chatData) {
    // Safely get the name, assuming it's a String
    final String? name = chatData['name'] as String?;

    // Safely get the messages list, assuming it's a List of dynamic items
    final dynamic messagesData = chatData['messages'];
    List<Message> messagesList = [];

    if (messagesData is List) {
      // Iterate through the list of messages
      for (final messageItem in messagesData) {
        // Safely cast each item to a Map<String, dynamic>
        if (messageItem is Map) {
          try {
            // Attempt to create a Message object from the map
            // You might need to adjust Message.fromMap or create a new Message.fromFirebase
            // that handles the dynamic types from Firebase.
            messagesList
                .add(Message.fromMap(Map<String, dynamic>.from(messageItem)));
          } catch (e) {
            // Handle potential errors during message parsing
            print('Error parsing message data: $e');
          }
        }
      }
    }

    // Return the Chat object
    return Chat(
      id: chatId,
      name: name ?? 'Sin nombre', // Provide a default name if needed
      messages: messagesList,
    );
  }
}
