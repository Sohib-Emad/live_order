// lib/features/rewards/data/model/reward_models.dart

class RewardTransaction {
  final String id;
  final int points;
  final String title;
  final String type; // 'earn' | 'redeem'
  final DateTime timestamp;

  RewardTransaction({
    required this.id,
    required this.points,
    required this.title,
    required this.type,
    required this.timestamp,
  });

  factory RewardTransaction.fromJson(Map<String, dynamic> json, String docId) {
    return RewardTransaction(
      id: docId,
      points: json['points'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'] ?? 'earn',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'points': points,
      'title': title,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
