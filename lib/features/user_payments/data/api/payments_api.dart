// lib/features/payments/data/api/payments_api.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentsApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> streamSavedCards(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cards')
        .snapshots();
  }

  Stream<QuerySnapshot> streamTransactions(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> addCard(String userId, Map<String, dynamic> cardData) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cards')
        .add(cardData);
  }

  Future<void> deleteCard(String userId, String cardId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cards')
        .doc(cardId)
        .delete();
  }

  Future<void> addTransaction(String userId, Map<String, dynamic> txData) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .add(txData);
  }
}
