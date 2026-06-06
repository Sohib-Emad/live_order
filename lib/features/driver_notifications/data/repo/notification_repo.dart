import 'package:live_order/features/driver_notifications/data/api/notification_api.dart';

class NotificationRepo {
  final NotificationApi _notificationApi;

  NotificationRepo(this._notificationApi);

  // Stream current user orders
  Stream<List<Map<String, dynamic>>> streamClientOrders(String userId) {
    return _notificationApi.streamClientOrders(userId);
  }

  // Stream current driver orders
  Stream<List<Map<String, dynamic>>> streamDriverOrders(String driverId) {
    return _notificationApi.streamDriverOrders(driverId);
  }
}
