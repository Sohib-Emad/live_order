import 'package:live_order/core/services/supabase_service.dart';

class DriverApi {
  final supabase = SupabaseService.instance.client;

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

  Future<void> updateShipmentStatus(String shipmentId, String status) async {
    await supabase.from('orders').update({
      'order_status': status,
    }).eq('id', shipmentId);
  }
}
