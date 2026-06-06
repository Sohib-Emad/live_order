// lib/features/user_notifications/data/api/notifications_api.dart

import 'package:live_order/core/services/supabase_service.dart';

class NotificationsApi {
  final supabase = SupabaseService.instance.client;

  Stream<List<Map<String, dynamic>>> streamNotifications(String userId) {
    return supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .map((list) => list.where((row) => row['user_id'] == userId).toList());
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await supabase
        .from('notifications')
        .update({'isRead': true})
        .eq('id', notificationId)
        .eq('user_id', userId);
  }
}
