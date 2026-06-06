// lib/features/user_tracking/data/repository/tracking_repository.dart

import 'package:live_order/features/user_tracking/data/api/tracking_api.dart';

class TrackingRepository {
  final TrackingApi _api;

  TrackingRepository(this._api);

  Stream<Map<String, dynamic>> streamTrackingData(String shipmentId) {
    return _api.streamTrackingData(shipmentId);
  }

  Stream<Map<String, dynamic>> streamDriverLocation(String driverUid) {
    return _api.streamDriverLocation(driverUid);
  }
}
