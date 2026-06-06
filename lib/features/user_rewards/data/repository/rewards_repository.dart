// lib/features/rewards/data/repository/rewards_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_order/features/rewards/data/api/rewards_api.dart';
import 'package:live_order/features/rewards/data/model/reward_models.dart';

class RewardsRepository {
  final RewardsApi _api;

  RewardsRepository(this._api);

  Stream<int> streamPoints(String userId) {
    return _api.streamRewardsData(userId).map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        return data['reward_points'] as int? ?? 0;
      }
      return 0;
    });
  }

  Stream<List<RewardTransaction>> streamTransactions(String userId) {
    return _api.streamRewardTransactions(userId).map((snapshot) {
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
        return RewardTransaction.fromJson(updatedData, doc.id);
      }).toList();
    });
  }

  Future<void> addTransaction(String userId, RewardTransaction tx) async {
    final pointsChange = tx.type == 'earn' ? tx.points : -tx.points;
    final txData = {
      'points': tx.points,
      'title': tx.title,
      'type': tx.type,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _api.addRewardTransaction(userId, txData, pointsChange);
  }
}
