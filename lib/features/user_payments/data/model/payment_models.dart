// lib/features/payments/data/model/payment_models.dart

class SavedCard {
  final String id;
  final String cardHolder;
  final String cardNumber;
  final String expiryDate;
  final String cardType; // 'visa' | 'mastercard'

  SavedCard({
    required this.id,
    required this.cardHolder,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardType,
  });

  factory SavedCard.fromJson(Map<String, dynamic> json, String docId) {
    return SavedCard(
      id: docId,
      cardHolder: json['cardHolder'] ?? '',
      cardNumber: json['cardNumber'] ?? '',
      expiryDate: json['expiryDate'] ?? '',
      cardType: json['cardType'] ?? 'visa',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardHolder': cardHolder,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'cardType': cardType,
    };
  }
}

class PaymentTransaction {
  final String id;
  final double amount;
  final String title;
  final DateTime timestamp;
  final String status; // 'Completed' | 'Pending' | 'Failed'
  final String category; // 'cargo' | 'refund' | 'rewards'

  PaymentTransaction({
    required this.id,
    required this.amount,
    required this.title,
    required this.timestamp,
    required this.status,
    required this.category,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json, String docId) {
    return PaymentTransaction(
      id: docId,
      amount: (json['amount'] ?? 0.0).toDouble(),
      title: json['title'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'Completed',
      category: json['category'] ?? 'cargo',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'title': title,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'category': category,
    };
  }
}
