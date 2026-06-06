import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/features/notification/data/repo/notification_repo.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepo notificationRepo;

  int _lastSeenCount = 0;
  bool _hasInitialSet = false;

  NotificationCubit({required this.notificationRepo}) : super(NotificationInitial());

  void initNotificationTracker(int initialTotal) {
    if (!_hasInitialSet) {
      _lastSeenCount = initialTotal;
      _hasInitialSet = true;
    }
    emit(NotificationsLoaded(
      unreadCount: (initialTotal - _lastSeenCount).clamp(0, 99),
      totalCount: initialTotal,
    ));
  }

  void markNotificationsAsSeen(int currentTotal) {
    _lastSeenCount = currentTotal;
    _hasInitialSet = true;
    emit(NotificationsLoaded(unreadCount: 0, totalCount: currentTotal));
  }
}
