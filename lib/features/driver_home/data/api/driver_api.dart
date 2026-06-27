import 'package:live_order/core/services/supabase_service.dart';

class DriverApi {
  final supabase = SupabaseService.instance.client;

  String? get currentUid => supabase.auth.currentUser?.id;

  Future<void> registerDriver(Map<String, dynamic> data, String uid) async {
    await supabase.from('users').upsert({'uid': uid, ...data});
  }

  Future<Map<String, dynamic>?> getDriverDetails(String uid) async {
    return await supabase.from('users').select().eq('uid', uid).single();
  }

  Stream<List<Map<String, dynamic>>> streamDriverOrders(String driverId) {
    return supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .map((list) => list.where((r) => r['driver_id'] == driverId).toList());
  }

  Stream<List<Map<String, dynamic>>> streamChatMessages(String chatId) {
    return supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .map((list) => list.where((r) => r['chat_id'] == chatId).toList());
  }

  Future<void> updateDriverStatus(String uid, bool isAvailable) async {
    await supabase.from('users').update({'is_available': isAvailable}).eq('uid', uid);
  }

  Future<void> updateShipmentStatus(String shipmentId, String status) async {
    await supabase.from('orders').update({
      'order_status': status,
    }).eq('id', shipmentId);
  }
}
