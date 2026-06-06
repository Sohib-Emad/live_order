import 'package:cloud_firestore/cloud_firestore.dart';

class HomeApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream current user details from Firestore
  Stream<DocumentSnapshot> streamUserDetails(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // Stream orders where order_user_id equals userId
  Stream<QuerySnapshot> streamClientOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('order_user_id', isEqualTo: userId)
        .snapshots();
  }

  // Update user saved address (Home/Work) in Firestore
  Future<void> updateUserAddress(String userId, String key, String newAddress) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .set({key: newAddress}, SetOptions(merge: true));
  }
}
