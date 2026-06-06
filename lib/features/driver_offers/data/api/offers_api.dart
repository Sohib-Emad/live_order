import 'package:live_order/core/services/supabase_service.dart';

class OffersApi {
  final supabase = SupabaseService.instance.client;

  // Stream active offers for a driver
  Stream<List<Map<String, dynamic>>> streamDriverOffers(String driverId) {
    return supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .map((list) => list
            .where((r) => r['driver_id'] == driverId && r['order_status'] == 'Waiting Driver')
            .toList());
  }

  // Update offer status (e.g. Accepted or Cancelled/Rejected)
  Future<void> updateOfferStatus(String orderId, String status) async {
    await supabase.from('orders').update({
      'order_status': status,
    }).eq('id', orderId);
  }
}
