class ChatMessage {
  final String id;
  final String text;
  final bool isUserMessage;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUserMessage,
    required this.timestamp,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      text: map['text'] as String,
      isUserMessage: map['isUserMessage'] as bool,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isUserMessage': isUserMessage,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
