// lib/features/rewards/data/api/rewards_api.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class RewardsApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot> streamRewardsData(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }

  Stream<QuerySnapshot> streamRewardTransactions(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('reward_transactions')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> addRewardTransaction(String userId, Map<String, dynamic> txData, int pointsChange) async {
    final userDoc = _firestore.collection('users').doc(userId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);
      if (!snapshot.exists) {
        throw Exception('User not found');
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final int currentPoints = data['reward_points'] as int? ?? 0;

      // 1. Add transaction
      final txRef = userDoc.collection('reward_transactions').doc();
      transaction.set(txRef, txData);

      // 2. Update user's points
      transaction.update(userDoc, {
        'reward_points': currentPoints + pointsChange,
      });
    });
  }
}
