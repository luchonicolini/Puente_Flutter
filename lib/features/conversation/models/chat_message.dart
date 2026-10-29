enum MessageSender {
  user,
  interlocutor,
}

class DetectedInfo {
  const DetectedInfo({
    required this.title,
    required this.items,
    this.isConfirmed = false,
  });

  final String title;
  final Map<String, String> items;
  final bool isConfirmed;

  DetectedInfo copyWith({
    String? title,
    Map<String, String>? items,
    bool? isConfirmed,
  }) {
    return DetectedInfo(
      title: title ?? this.title,
      items: items ?? this.items,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.timeFormatted = '9:41',
    this.detectedInfo,
  });

  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final String timeFormatted;
  final DetectedInfo? detectedInfo;

  ChatMessage copyWith({
    String? id,
    String? text,
    MessageSender? sender,
    DateTime? timestamp,
    String? timeFormatted,
    DetectedInfo? detectedInfo,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      timeFormatted: timeFormatted ?? this.timeFormatted,
      detectedInfo: detectedInfo ?? this.detectedInfo,
    );
  }
}
