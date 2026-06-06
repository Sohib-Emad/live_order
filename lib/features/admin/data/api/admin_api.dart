import 'package:cloud_firestore/cloud_firestore.dart';

class AdminApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> streamAllUsers() {
    return _firestore.collection('users').snapshots();
  }

  Stream<QuerySnapshot> streamAllOrders() {
    return _firestore.collection('orders').snapshots();
  }

  Future<void> updateDriverStatus(String userId, String status) async {
    await _firestore.collection('users').doc(userId).update({
      'driver_status': status,
    });
  }
}
