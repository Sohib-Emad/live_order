// lib/features/user_rewards/data/api/rewards_api.dart

import 'package:live_order/core/services/supabase_service.dart';

class RewardsApi {
  final supabase = SupabaseService.instance.client;

  Stream<Map<String, dynamic>> streamRewardsData(String userId) {
    return supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .map((list) => list.firstWhere((row) => row['uid'] == userId));
  }

  Stream<List<Map<String, dynamic>>> streamRewardTransactions(String userId) {
    return supabase
        .from('reward_transactions')
        .stream(primaryKey: ['id'])
        .map((list) => list.where((row) => row['user_id'] == userId).toList());
  }

  Future<void> addRewardTransaction(String userId, Map<String, dynamic> txData, int pointsChange) async {
    final userData = await supabase
        .from('users')
        .select()
        .eq('uid', userId)
        .single() as Map<String, dynamic>?;

    if (userData == null) {
      throw Exception('User not found');
    }

    final int currentPoints = userData['reward_points'] as int? ?? 0;

    txData['user_id'] = userId;
    await supabase.from('reward_transactions').insert(txData);

    await supabase.from('users').update({
      'reward_points': currentPoints + pointsChange,
    }).eq('uid', userId);
  }
}
