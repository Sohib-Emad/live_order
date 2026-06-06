import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_order/features/home/data/api/home_api.dart';

class HomeRepo {
  final HomeApi _homeApi;

  HomeRepo(this._homeApi);

  // Stream current user details from Firestore
  Stream<DocumentSnapshot> streamUserDetails(String uid) {
    return _homeApi.streamUserDetails(uid);
  }

  // Stream orders where order_user_id equals userId
  Stream<QuerySnapshot> streamClientOrders(String userId) {
    return _homeApi.streamClientOrders(userId);
  }

  // Update user saved address (Home/Work) in Firestore
  Future<void> updateUserAddress(String userId, String key, String newAddress) async {
    await _homeApi.updateUserAddress(userId, key, newAddress);
  }
}
