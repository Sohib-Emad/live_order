// lib/features/user_tracking/data/api/tracking_api.dart

import 'package:live_order/core/services/supabase_service.dart';

class TrackingApi {
  final supabase = SupabaseService.instance.client;

  Stream<Map<String, dynamic>> streamTrackingData(String shipmentId) {
    return supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .map((list) => list.firstWhere((row) => row['id'] == shipmentId));
  }

  Stream<Map<String, dynamic>> streamDriverLocation(String driverUid) {
    return supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .map((list) => list.firstWhere(
          (row) => row['uid'] == driverUid,
          orElse: () => <String, dynamic>{},
        ));
  }
}
