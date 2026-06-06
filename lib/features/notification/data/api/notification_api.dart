import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream current user orders to parse dynamic notifications
  Stream<QuerySnapshot> streamClientOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('order_user_id', isEqualTo: userId)
        .snapshots();
  }

  // Stream current driver orders to parse dynamic notifications
  Stream<QuerySnapshot> streamDriverOrders(String driverId) {
    return _firestore
        .collection('orders')
        .where('driver_id', isEqualTo: driverId)
        .snapshots();
  }
}
