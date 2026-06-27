import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/core/services/supabase_service.dart';
import 'package:live_order/core/utils/logger.dart';
import 'package:live_order/features/session/data/repo/home_repo.dart';
import 'package:live_order/features/session/logic/home_logic_helper.dart';
import 'package:live_order/features/session/logic/state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo homeRepo;

  StreamSubscription<List<Map<String, dynamic>>>? _userSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _ordersSubscription;
  final Map<String, StreamSubscription<List<Map<String, dynamic>>>> _chatSubscriptions = {};

  UserProfile? _currentUser;
  List<Shipment> _currentOrders = [];
  final Map<String, int> _unreadChats = {};
  int _totalUnreadChats = 0;
  final Map<String, String> _lastKnownOrderStatuses = {};
  int _lastSeenNotificationCount = 0;
  bool _hasInitialCountSet = false;

  HomeCubit({required this.homeRepo}) : super(HomeInitial());

  String _currentUid = '';

  // Initialize and stream all active Supabase changes
  void initHome() {
    final uid = homeRepo.getCurrentUid();
    if (uid == null) {
      emit(HomeError(message: 'لم يتم تسجيل الدخول'));
      return;
    }
    _currentUid = uid;
    AppLogger.info('HomeCubit', 'initHome called for uid: $uid');
    emit(HomeLoading());
    _subscribeToUser();
    _subscribeToOrders();
  }

  String get currentUid => _currentUid;

  void _subscribeToUser() {
    _userSubscription?.cancel();
    _userSubscription = homeRepo.streamUserDetails(_currentUid).listen((usersList) {
      if (usersList.isNotEmpty) {
        final data = usersList.first;
        _currentUser = UserProfile.fromJson(data);
        _emitCurrentState();
      } else {
        AppLogger.error('HomeCubit', 'User record not found for uid: $_currentUid');
        emit(HomeError(message: 'الحساب غير موجود في النظام'));
      }
    }, onError: (error) {
      AppLogger.error('HomeCubit', 'User stream error', error);
      Future.delayed(const Duration(seconds: 3), _subscribeToUser);
    });
  }

  void _subscribeToOrders() {
    _ordersSubscription?.cancel();
    _ordersSubscription = homeRepo.streamClientOrders(_currentUid).listen((ordersList) {
      _currentOrders = ordersList
          .map((row) => Shipment.fromJson(row))
          .toList();

      _syncChatListeners();
      _checkForStatusChanges();
      _emitCurrentState();
    }, onError: (error) {
      AppLogger.error('HomeCubit', 'Orders stream error', error);
      Future.delayed(const Duration(seconds: 3), _subscribeToOrders);
    });
  }

  void _syncChatListeners() {
    final currentChatIds = <String>{};
    for (var order in _currentOrders) {
      if (order.driverId.isNotEmpty) {
        final chatId = '${order.clientId}_${order.driverId}';
        currentChatIds.add(chatId);
        if (!_chatSubscriptions.containsKey(chatId)) {
          _chatSubscriptions[chatId] = homeRepo.streamChatMessages(chatId).listen((messages) {
                final myUid = _currentUid;
                final unreadCount = messages.where((data) {
                  final senderId = data['sender_id'];
                  final isRead = data['is_read'] ?? false;
                  return senderId != myUid && isRead == false;
                }).length;

                _unreadChats[chatId] = unreadCount;
                _calculateTotalUnreadChats();
              });
        }
      }
    }

    final toRemove = <String>[];
    _chatSubscriptions.forEach((chatId, sub) {
      if (!currentChatIds.contains(chatId)) {
        sub.cancel();
        toRemove.add(chatId);
      }
    });

    for (var chatId in toRemove) {
      _chatSubscriptions.remove(chatId);
      _unreadChats.remove(chatId);
    }
    _calculateTotalUnreadChats();
  }

  void _calculateTotalUnreadChats() {
    final newTotal = _unreadChats.values.fold(0, (a, b) => a + b);
    if (newTotal != _totalUnreadChats) {
      _totalUnreadChats = newTotal;
      _emitCurrentState();
    }
  }

  void _checkForStatusChanges() {
    for (var order in _currentOrders) {
      final previousStatus = _lastKnownOrderStatuses[order.id];
      if (previousStatus != null && previousStatus != order.status) {
        final alertMessage = HomeLogicHelper.getNotificationMessage(order.orderName, order.status);
        if (alertMessage.isNotEmpty) {
          emit(HomeStatusAlert(
            alertMessage: alertMessage,
            isSuccess: order.status == 'Delivered',
          ));
        }
      }
      _lastKnownOrderStatuses[order.id] = order.status;
    }
  }

  void markNotificationsAsSeen() {
    int totalNotificationsCount = 0;
    for (var order in _currentOrders) {
      totalNotificationsCount += 1;
      if (order.status != 'Waiting Driver') {
        totalNotificationsCount += 1;
      }
    }
    _lastSeenNotificationCount = totalNotificationsCount;
    _emitCurrentState();
  }

  int get unreadNotificationsCount {
    int totalNotificationsCount = 0;
    for (var order in _currentOrders) {
      totalNotificationsCount += 1;
      if (order.status != 'Waiting Driver') {
        totalNotificationsCount += 1;
      }
    }
    if (!_hasInitialCountSet) {
      _lastSeenNotificationCount = totalNotificationsCount;
      _hasInitialCountSet = true;
    }
    return (totalNotificationsCount - _lastSeenNotificationCount).clamp(0, 99);
  }

  void _emitCurrentState() {
    if (_currentUser != null) {
      emit(HomeLoaded(
        user: _currentUser!,
        orders: _currentOrders,
        totalUnreadChats: _totalUnreadChats,
        unreadNotificationsCount: unreadNotificationsCount,
      ));
    }
  }

  Future<void> signOut() async {
    await SupabaseService.instance.client.auth.signOut();
  }

  // Update user saved address (Home/Work) in Firestore
  Future<void> updateAddress(String userId, String key, String newAddress) async {
    try {
      await homeRepo.updateUserAddress(userId, key, newAddress);
      emit(HomeAddressUpdateSuccess());
      _emitCurrentState();
    } catch (e) {
      AppLogger.error('HomeCubit', 'updateAddress failed', e);
      emit(HomeError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    _ordersSubscription?.cancel();
    for (var sub in _chatSubscriptions.values) {
      sub.cancel();
    }
    return super.close();
  }
}
