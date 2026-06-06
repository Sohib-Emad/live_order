import 'package:live_order/core/services/supabase_service.dart';

class HomeApi {
  final supabase = SupabaseService.instance.client;

  Stream<List<Map<String, dynamic>>> streamUserDetails(String uid) {
    return supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .map((list) => list.where((row) => row['uid'] == uid).toList());
  }

  Stream<List<Map<String, dynamic>>> streamClientOrders(String userId) {
    return supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .map((list) => list.where((row) => row['order_user_id'] == userId).toList());
  }

  Future<void> updateUserAddress(String userId, String key, String newAddress) async {
    await supabase
        .from('users')
        .update({key: newAddress})
        .eq('uid', userId);
  }
}
