import '../../../domain/confirmation/data_comparison.dart';

enum MessageSender {
  user,
  interlocutor,
}

class DetectedInfo {
  const DetectedInfo({
    required this.title,
    required this.items,
    this.itemKinds = const {},
    this.confirmedKeys = const {},
    this.isConfirmed = false,
  });

  final String title;
  final Map<String, String> items;
  final Map<String, DataKind> itemKinds;
  final Set<String> confirmedKeys;
  final bool isConfirmed;

  bool isKeyConfirmed(String key) => isConfirmed || confirmedKeys.contains(key);

  DataKind kindFor(String key) => itemKinds[key] ?? DataKind.amount;

  DetectedInfo copyWith({
    String? title,
    Map<String, String>? items,
    Map<String, DataKind>? itemKinds,
    Set<String>? confirmedKeys,
    bool? isConfirmed,
  }) {
    return DetectedInfo(
      title: title ?? this.title,
      items: items ?? this.items,
      itemKinds: itemKinds ?? this.itemKinds,
      confirmedKeys: confirmedKeys ?? this.confirmedKeys,
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
