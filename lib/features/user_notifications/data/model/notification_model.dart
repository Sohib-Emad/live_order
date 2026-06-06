// lib/features/notifications/data/model/notification_model.dart

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String category; // 'status' | 'promo' | 'payment' | 'system'
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.category,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json, String docId) {
    return AppNotification(
      id: docId,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      category: json['category'] ?? 'status',
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
      'isRead': isRead,
    };
  }
}
