// lib/features/tracking/data/repository/tracking_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_order/features/tracking/data/api/tracking_api.dart';

class TrackingRepository {
  final TrackingApi _api;

  TrackingRepository(this._api);

  Stream<DocumentSnapshot> streamTrackingData(String shipmentId) {
    return _api.streamTrackingData(shipmentId);
  }
}
