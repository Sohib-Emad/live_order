// lib/features/user_rewards/data/repository/rewards_repository.dart

import 'package:live_order/features/user_rewards/data/api/rewards_api.dart';
import 'package:live_order/features/user_rewards/data/model/reward_models.dart';

class RewardsRepository {
  final RewardsApi _api;

  RewardsRepository(this._api);

  Stream<int> streamPoints(String userId) {
    return _api.streamRewardsData(userId).map((data) {
      return data['reward_points'] as int? ?? 0;
    });
  }

  Stream<List<RewardTransaction>> streamTransactions(String userId) {
    return _api.streamRewardTransactions(userId).map((list) {
      return list.map((data) {
        final timestampVal = data['timestamp'];
        String timestampStr;
        if (timestampVal is DateTime) {
          timestampStr = timestampVal.toIso8601String();
        } else {
          timestampStr = DateTime.now().toIso8601String();
        }
        final updatedData = Map<String, dynamic>.from(data)..['timestamp'] = timestampStr;
        return RewardTransaction.fromJson(updatedData, data['id'] as String);
      }).toList();
    });
  }

  Future<void> addTransaction(String userId, RewardTransaction tx) async {
    final pointsChange = tx.type == 'earn' ? tx.points : -tx.points;
    final txData = {
      'points': tx.points,
      'title': tx.title,
      'type': tx.type,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _api.addRewardTransaction(userId, txData, pointsChange);
  }
}
