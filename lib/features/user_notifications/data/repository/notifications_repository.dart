// lib/features/notifications/data/repository/notifications_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_order/features/notifications/data/api/notifications_api.dart';
import 'package:live_order/features/notifications/data/model/notification_model.dart';

class NotificationsRepository {
  final NotificationsApi _api;

  NotificationsRepository(this._api);

  Stream<List<AppNotification>> streamNotifications(String userId) {
    return _api.streamNotifications(userId).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final timestampVal = data['timestamp'];
        String timestampStr;
        if (timestampVal is Timestamp) {
          timestampStr = timestampVal.toDate().toIso8601String();
        } else {
          timestampStr = DateTime.now().toIso8601String();
        }
        final updatedData = Map<String, dynamic>.from(data)..['timestamp'] = timestampStr;
        return AppNotification.fromJson(updatedData, doc.id);
      }).toList();
    });
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _api.markAsRead(userId, notificationId);
  }
}
