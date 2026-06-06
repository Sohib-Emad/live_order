part of 'notification_cubit.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final int unreadCount;
  final int totalCount;
  NotificationsLoaded({required this.unreadCount, required this.totalCount});
}

class NotificationAlertTriggered extends NotificationState {
  final String message;
  final bool isSuccess;
  NotificationAlertTriggered({required this.message, required this.isSuccess});
}
