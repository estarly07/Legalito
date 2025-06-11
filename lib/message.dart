class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  // Helper for Firestore and SQLite
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp':
          timestamp.toIso8601String(), // Store as string for compatibility
    };
  }

  // Helper for Firestore and SQLite
  factory Message.fromMap(Map<dynamic, dynamic> map) {
    return Message(
      text: map['text'],
      isUser: map['isUser'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
