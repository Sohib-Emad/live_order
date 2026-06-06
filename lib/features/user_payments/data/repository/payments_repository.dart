// lib/features/payments/data/repository/payments_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_order/features/payments/data/api/payments_api.dart';
import 'package:live_order/features/payments/data/model/payment_models.dart';

class PaymentsRepository {
  final PaymentsApi _api;

  PaymentsRepository(this._api);

  Stream<List<SavedCard>> streamSavedCards(String userId) {
    return _api.streamSavedCards(userId).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SavedCard.fromJson(data, doc.id);
      }).toList();
    });
  }

  Stream<List<PaymentTransaction>> streamTransactions(String userId) {
    return _api.streamTransactions(userId).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final timestampVal = data['timestamp'];
        String timestampStr;
        if (timestampVal is Timestamp) {
          timestampStr = timestampVal.toDate().toIso8601String();
        } else {
          timestampStr = DateTime.now().toIso8601String();
        }
        final updatedData = Map<String, dynamic>.from(data)..['timestamp'] = timestampStr;
        return PaymentTransaction.fromJson(updatedData, doc.id);
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
      'timestamp': FieldValue.serverTimestamp(),
      'status': tx.status,
      'category': tx.category,
    };
    await _api.addTransaction(userId, txData);
  }
}
