// lib/features/user_payments/data/repository/payments_repository.dart

import 'package:live_order/features/user_payments/data/api/payments_api.dart';
import 'package:live_order/features/user_payments/data/model/payment_models.dart';

class PaymentsRepository {
  final PaymentsApi _api;

  PaymentsRepository(this._api);

  Stream<List<SavedCard>> streamSavedCards(String userId) {
    return _api.streamSavedCards(userId).map((list) {
      return list.map((data) => SavedCard.fromJson(data, data['id'] as String)).toList();
    });
  }

  Stream<List<PaymentTransaction>> streamTransactions(String userId) {
    return _api.streamTransactions(userId).map((list) {
      return list.map((data) {
        final timestampVal = data['timestamp'];
        String timestampStr;
        if (timestampVal is DateTime) {
          timestampStr = timestampVal.toIso8601String();
        } else {
          timestampStr = DateTime.now().toIso8601String();
        }
        final updatedData = Map<String, dynamic>.from(data)..['timestamp'] = timestampStr;
        return PaymentTransaction.fromJson(updatedData, data['id'] as String);
      }).toList();
    });
  }

  Future<void> addCard(String userId, SavedCard card) async {
    await _api.addCard(userId, card.toJson());
  }

  Future<void> deleteCard(String userId, String cardId) async {
    await _api.deleteCard(userId, cardId);
  }

  Future<void> addTransaction(String userId, PaymentTransaction tx) async {
    final txData = {
      'amount': tx.amount,
      'title': tx.title,
      'timestamp': DateTime.now().toIso8601String(),
      'status': tx.status,
      'category': tx.category,
    };
    await _api.addTransaction(userId, txData);
  }
}
