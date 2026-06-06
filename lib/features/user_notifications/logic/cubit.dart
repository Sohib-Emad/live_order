// lib/features/notifications/logic/cubit.dart

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/features/notifications/data/model/notification_model.dart';
import 'package:live_order/features/notifications/data/repository/notifications_repository.dart';
import 'package:live_order/features/notifications/logic/state.dart';

class MarketNotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repository;
  StreamSubscription<List<AppNotification>>? _subscription;

  MarketNotificationsCubit(this._repository) : super(NotificationsInitial());

  Future<void> loadNotifications() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'client_1';
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
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'client_1';
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
