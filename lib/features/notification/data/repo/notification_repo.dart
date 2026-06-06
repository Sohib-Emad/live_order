import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_order/features/notification/data/api/notification_api.dart';

class NotificationRepo {
  final NotificationApi _notificationApi;

  NotificationRepo(this._notificationApi);

  // Stream current user orders
  Stream<QuerySnapshot> streamClientOrders(String userId) {
    return _notificationApi.streamClientOrders(userId);
  }

  // Stream current driver orders
  Stream<QuerySnapshot> streamDriverOrders(String driverId) {
    return _notificationApi.streamDriverOrders(driverId);
  }
}
