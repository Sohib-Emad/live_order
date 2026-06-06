import 'package:live_order/core/services/supabase_service.dart';

class NotificationApi {
  final supabase = SupabaseService.instance.client;

  // Stream current user orders to parse dynamic notifications
  Stream<List<Map<String, dynamic>>> streamClientOrders(String userId) {
    return supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .map((list) => list.where((r) => r['order_user_id'] == userId).toList());
  }

  // Stream current driver orders to parse dynamic notifications
  Stream<List<Map<String, dynamic>>> streamDriverOrders(String driverId) {
    return supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .map((list) => list.where((r) => r['driver_id'] == driverId).toList());
  }
}
