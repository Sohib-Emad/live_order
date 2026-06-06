// lib/features/market_chat/data/model/chat_message.dart

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final String? attachmentUrl;
  final String? attachmentType; // 'image', 'location', 'document'
  final double? latitude;
  final double? longitude;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.attachmentUrl,
    this.attachmentType,
    this.latitude,
    this.longitude,
  });

  bool get isAttachment => attachmentType != null;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      text: json['text'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      attachmentUrl: json['attachmentUrl'],
      attachmentType: json['attachmentType'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
