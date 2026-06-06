import 'package:live_order/features/session/data/api/home_api.dart';

class HomeRepo {
  final HomeApi _homeApi;

  HomeRepo(this._homeApi);

  // Stream current user details from Supabase
  Stream<List<Map<String, dynamic>>> streamUserDetails(String uid) {
    return _homeApi.streamUserDetails(uid);
  }

  // Stream orders where order_user_id equals userId
  Stream<List<Map<String, dynamic>>> streamClientOrders(String userId) {
    return _homeApi.streamClientOrders(userId);
  }

  // Update user saved address (Home/Work) in Supabase
  Future<void> updateUserAddress(String userId, String key, String newAddress) async {
    await _homeApi.updateUserAddress(userId, key, newAddress);
  }
}
