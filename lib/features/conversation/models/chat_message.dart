enum MessageSender {
  user,
  interlocutor,
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.detectedValue,
    this.isConfirmed = false,
  });

  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final String? detectedValue;
  final bool isConfirmed;

  ChatMessage copyWith({
    String? id,
    String? text,
    MessageSender sender,
    DateTime? timestamp,
    String? detectedValue,
    bool? isConfirmed,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      detectedValue: detectedValue ?? this.detectedValue,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
}
