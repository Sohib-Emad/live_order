// lib/features/user_notifications/data/repository/notifications_repository.dart

import 'package:live_order/features/user_notifications/data/api/notifications_api.dart';
import 'package:live_order/features/user_notifications/data/model/notification_model.dart';

class NotificationsRepository {
  final NotificationsApi _api;

  NotificationsRepository(this._api);

  Stream<List<AppNotification>> streamNotifications(String userId) {
    return _api.streamNotifications(userId).map((list) {
      return list.map((data) {
        final timestampVal = data['timestamp'];
        String timestampStr;
        if (timestampVal is DateTime) {
          timestampStr = timestampVal.toIso8601String();
        } else {
          timestampStr = DateTime.now().toIso8601String();
        }
        final updatedData = Map<String, dynamic>.from(data)..['timestamp'] = timestampStr;
        return AppNotification.fromJson(updatedData, data['id'] as String);
      }).toList();
    });
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _api.markAsRead(userId, notificationId);
  }
}
