// lib/features/tracking/data/api/tracking_api.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class TrackingApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot> streamTrackingData(String shipmentId) {
    return _firestore.collection('orders').doc(shipmentId).snapshots();
  }
}
