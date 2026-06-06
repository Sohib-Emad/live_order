import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddOrderApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String? get currentUid => _firebaseAuth.currentUser?.uid;

  Future<void> createOrder(Map<String, dynamic> data, String docId) async {
    await _firestore.collection('orders').doc(docId).set(data);
  }

  Future<QuerySnapshot> getAvailableDrivers() async {
    return await _firestore
        .collection('users')
        .where('role', isEqualTo: 'driver')
        .where('driver_status', isEqualTo: 'active')
        .where('is_available', isEqualTo: true)
        .get();
  }

  Future<void> updateShipmentRating({
    required String shipmentId,
    required double rating,
    required String review,
  }) async {
    await _firestore.collection('orders').doc(shipmentId).update({
      'rating': rating,
      'review': review,
      'order_status': 'Delivered',
    });
  }

  Future<DocumentSnapshot> getDriverDoc(String driverId) async {
    return await _firestore.collection('users').doc(driverId).get();
  }

  Future<void> updateDriverStats(String driverId, double nextRating, int nextTrips) async {
    await _firestore.collection('users').doc(driverId).update({
      'rating': nextRating,
      'trips_count': nextTrips,
    });
  }
}
