import 'package:cloud_firestore/cloud_firestore.dart';

class DriverApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerDriver(Map<String, dynamic> data, String uid) async {
    await _firestore.collection('users').doc(uid).set(data);
  }

  Future<DocumentSnapshot> getDriverDetails(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  Stream<QuerySnapshot> streamDriverOrders(String driverId) {
    return _firestore
        .collection('orders')
        .where('driver_id', isEqualTo: driverId)
        .snapshots();
  }

  Future<void> updateShipmentStatus(String shipmentId, String status) async {
    await _firestore.collection('orders').doc(shipmentId).update({
      'order_status': status,
    });
  }
}
