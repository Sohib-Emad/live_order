// lib/features/user_notifications/logic/cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/services/supabase_service.dart';
import 'package:live_order/features/user_notifications/data/repository/notifications_repository.dart';
import 'package:live_order/features/user_notifications/logic/state.dart';

class MarketNotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repository;
  StreamSubscription<List<AppNotification>>? _subscription;

  MarketNotificationsCubit(this._repository) : super(NotificationsInitial());

  Future<void> loadNotifications() async {
    final uid = SupabaseService.instance.client.auth.currentUser?.id ?? 'client_1';
    emit(NotificationsLoading());

    _subscription?.cancel();
    _subscription = _repository.streamNotifications(uid).listen(
      (notifications) {
        emit(NotificationsLoaded(notifications));
      },
      onError: (e) {
        emit(NotificationsError(e.toString()));
      },
    );
  }

  Future<void> markAsRead(String notificationId) async {
    final uid = SupabaseService.instance.client.auth.currentUser?.id ?? 'client_1';
    try {
      await _repository.markAsRead(uid, notificationId);
    } catch (e) {
      emit(NotificationsError('Failed to mark read: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
