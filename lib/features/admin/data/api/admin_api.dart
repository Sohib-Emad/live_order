import 'package:live_order/core/services/supabase_service.dart';

class AdminApi {
  final supabase = SupabaseService.instance.client;

  Stream<List<Map<String, dynamic>>> streamAllUsers() {
    return supabase
        .from('users')
        .stream(primaryKey: ['id']);
  }

  Stream<List<Map<String, dynamic>>> streamAllOrders() {
    return supabase
        .from('orders')
        .stream(primaryKey: ['id']);
  }

  Future<void> updateDriverStatus(String userId, String status) async {
    await supabase.rpc('admin_update_user_status', params: {
      'p_uid': userId,
      'p_status': status,
    });
  }
}
