import 'package:cloud_firestore/cloud_firestore.dart';

class OffersApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream active offers for a driver
  Stream<QuerySnapshot> streamDriverOffers(String driverId) {
    return _firestore
        .collection('orders')
        .where('driver_id', isEqualTo: driverId)
        .where('order_status', isEqualTo: 'Waiting Driver')
        .snapshots();
  }

  // Update offer status (e.g. Accepted or Cancelled/Rejected)
  Future<void> updateOfferStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'order_status': status,
    });
  }
}
