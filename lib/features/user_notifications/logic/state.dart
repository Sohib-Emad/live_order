// lib/features/user_notifications/logic/state.dart

import 'package:live_order/features/user_notifications/data/model/notification_model.dart';
export 'package:live_order/features/user_notifications/data/model/notification_model.dart';

abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<AppNotification> notifications;
  NotificationsLoaded(this.notifications);
}

class NotificationsError extends NotificationsState {
  final String message;
  NotificationsError(this.message);
}
