import 'package:live_order/core/services/supabase_service.dart';

class AddOrderApi {
  final supabase = SupabaseService.instance.client;

  String? get currentUid => supabase.auth.currentUser?.id;

  Future<void> createOrder(Map<String, dynamic> data, String docId) async {
    final dbData = <String, dynamic>{
      'id': docId,
      'order_user_id': data['order_user_id'] ?? data['client_id'] ?? '',
      'client_id': data['client_id'] ?? data['order_user_id'] ?? '',
      'driver_id':
          data['driver_id'] ??
          (data['assignedDriver'] != null ? data['assignedDriver']['uid'] : ''),
      'order_name': data['cargoType'] ?? data['order_name'] ?? 'شحنة بضائع',
      'order_status':
          data['status'] ?? data['order_status'] ?? 'Waiting Driver',
      'pickup_address': data['pickupAddress'] ?? data['pickup_address'] ?? '',
      'pickup_lat': data['pickupLat'] ?? data['pickup_lat'] ?? 30.0,
      'pickup_lng': data['pickupLng'] ?? data['pickup_lng'] ?? 31.0,
      'drop_address': data['dropAddress'] ?? data['drop_address'] ?? '',
      'drop_lat': data['dropLat'] ?? data['drop_lat'] ?? 30.0,
      'drop_lng': data['dropLng'] ?? data['drop_lng'] ?? 31.0,
      'order_size': data['size'] ?? data['order_size'] ?? 'M',
      'weight': data['weight'] ?? 1.0,
      'notes': data['notes'] ?? '',
      'images': data['images'] ?? [],
      'order_date': data['preferredDate'] ?? data['order_date'] ?? '',
      'preferred_time_range':
          data['preferredTimeRange'] ?? data['preferred_time_range'] ?? '',
      'price_estimate': data['priceEstimate'] ?? data['price_estimate'] ?? 0.0,
      'payment_method':
          data['paymentMethod'] ?? data['payment_method'] ?? 'عند الاستلام',
      'rating': data['rating'],
      'review': data['review'] ?? '',
      'total_price':
          data['total_price'] ??
          data['priceEstimate'] ??
          data['price_estimate'] ??
          0.0,
      'assigned_driver': data['assignedDriver'],
    };
    await supabase.from('orders').upsert(dbData);
  }

  Future<List<Map<String, dynamic>>> getAvailableDrivers() async {
    return await supabase
        .from('users')
        .select()
        .eq('role', 'driver')
        .eq('driver_status', 'active')
        .eq('is_available', true);
  }

  Future<void> updateShipmentRating({
    required String shipmentId,
    required double rating,
    required String review,
  }) async {
    await supabase
        .from('orders')
        .update({
          'rating': rating,
          'review': review,
          'order_status': 'Delivered',
        })
        .eq('id', shipmentId);
  }

  Future<Map<String, dynamic>?> getDriverDoc(String driverId) async {
    return await supabase.from('users').select().eq('uid', driverId).single();
  }

  Future<void> updateDriverStats(
    String driverId,
    double nextRating,
    int nextTrips,
  ) async {
    await supabase
        .from('users')
        .update({'rating': nextRating, 'trips_count': nextTrips})
        .eq('uid', driverId);
  }

  Stream<List<Map<String, dynamic>>> streamOrder(String orderId) {
    return supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .map((list) => list.where((r) => r['id'] == orderId).toList());
  }

  Stream<List<Map<String, dynamic>>> streamUser(String userId) {
    return supabase
        .from('users')
        .stream(primaryKey: ['uid'])
        .map((list) => list.where((r) => r['uid'] == userId).toList());
  }
}
