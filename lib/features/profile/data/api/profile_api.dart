import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream current user details from Firestore
  Stream<DocumentSnapshot> streamUserDetails(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // Update user saved address (Home/Work) in Firestore
  Future<void> updateUserAddress(String userId, String key, String newAddress) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .set({key: newAddress}, SetOptions(merge: true));
  }

  // Update driver vehicle info in Firestore
  Future<void> updateDriverVehicleInfo(String userId, String vehicleInfo) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .update({'vehicle_info': vehicleInfo});
  }
}
