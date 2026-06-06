// lib/features/user_create_shipment/data/api/create_shipment_api.dart
// All Supabase calls must go through this API layer.
// Do not use SupabaseService.instance.client directly in UI code.

import 'dart:math';
import 'package:live_order/core/services/supabase_service.dart';

class CreateShipmentApi {
  final supabase = SupabaseService.instance.client;

  Future<void> submitShipment(Map<String, dynamic> shipmentData) async {
    final uid = supabase.auth.currentUser?.id;
    final String docId =
        (shipmentData['id'] != null && shipmentData['id'].toString().isNotEmpty)
        ? shipmentData['id'].toString()
        : generateOrderId();

    final dbData = <String, dynamic>{
      'id': docId,
      'order_user_id':
          uid ??
          shipmentData['order_user_id'] ??
          shipmentData['client_id'] ??
          '',
      'client_id':
          uid ??
          shipmentData['client_id'] ??
          shipmentData['order_user_id'] ??
          '',
      'driver_id':
          shipmentData['driver_id']?.toString().isNotEmpty == true
              ? shipmentData['driver_id']
              : (shipmentData['assignedDriver'] != null
                  ? shipmentData['assignedDriver']['uid']
                  ?? shipmentData['assignedDriver']['user_id']
                  ?? ''
                  : ''),
      'order_name':
          shipmentData['cargoType'] ??
          shipmentData['order_name'] ??
          'شحنة بضائع',
      'order_status':
          shipmentData['status'] ??
          shipmentData['order_status'] ??
          'Waiting Driver',
      'pickup_address':
          shipmentData['pickupAddress'] ?? shipmentData['pickup_address'] ?? '',
      'pickup_lat':
          shipmentData['pickupLat'] ?? shipmentData['pickup_lat'] ?? 30.0,
      'pickup_lng':
          shipmentData['pickupLng'] ?? shipmentData['pickup_lng'] ?? 31.0,
      'drop_address':
          shipmentData['dropAddress'] ?? shipmentData['drop_address'] ?? '',
      'drop_lat': shipmentData['dropLat'] ?? shipmentData['drop_lat'] ?? 30.0,
      'drop_lng': shipmentData['dropLng'] ?? shipmentData['drop_lng'] ?? 31.0,
      'order_size': shipmentData['size'] ?? shipmentData['order_size'] ?? 'M',
      'weight': shipmentData['weight'] ?? 1.0,
      'notes': shipmentData['notes'] ?? '',
      'images': shipmentData['images'] ?? [],
      'order_date':
          shipmentData['preferredDate'] ?? shipmentData['order_date'] ?? '',
      'preferred_time_range':
          shipmentData['preferredTimeRange'] ??
          shipmentData['preferred_time_range'] ??
          '',
      'price_estimate':
          shipmentData['priceEstimate'] ??
          shipmentData['price_estimate'] ??
          0.0,
      'payment_method':
          shipmentData['paymentMethod'] ??
          shipmentData['payment_method'] ??
          'عند الاستلام',
      'rating': shipmentData['rating'],
      'review': shipmentData['review'] ?? '',
      'total_price':
          shipmentData['total_price'] ??
          shipmentData['priceEstimate'] ??
          shipmentData['price_estimate'] ??
          0.0,
      'assigned_driver': shipmentData['assignedDriver'],
    };

    await supabase.from('orders').upsert(dbData);
  }

  Future<List<Map<String, dynamic>>> fetchDrivers() async {
    final data = await supabase.from('users').select().eq('role', 'driver');
    return data.cast<Map<String, dynamic>>().toList();
  }

  Future<void> cancelShipment(String orderId) async {
    await supabase
        .from('orders')
        .update({'order_status': 'Cancelled'})
        .eq('id', orderId);
  }

  Stream<Map<String, dynamic>> getOrderStream(String orderId) {
    return supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .map((list) => list.firstWhere((row) => row['id'] == orderId));
  }

  String generateOrderId() {
    final random = Random();
    return '${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(999999)}';
  }
}
