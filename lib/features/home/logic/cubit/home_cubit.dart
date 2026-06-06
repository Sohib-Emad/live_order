import 'dart:async';
import 'package:live_order/features/add_order/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/features/add_order/models/order_model.dart';
import 'package:live_order/features/home/data/repo/home_repo.dart';
import 'package:live_order/features/home/logic/home_logic_helper.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo homeRepo;

  StreamSubscription<DocumentSnapshot>? _userSubscription;
  StreamSubscription<QuerySnapshot>? _ordersSubscription;
  final Map<String, StreamSubscription<QuerySnapshot>> _chatSubscriptions = {};

  UserModel? _currentUser;
  List<OrderModel> _currentOrders = [];
  final Map<String, int> _unreadChats = {};
  int _totalUnreadChats = 0;
  final Map<String, String> _lastKnownOrderStatuses = {};
  int _lastSeenNotificationCount = 0;
  bool _hasInitialCountSet = false;

  HomeCubit({required this.homeRepo}) : super(HomeInitial());

  // Initialize and stream all active Firestore changes
  void initHome(String uid) {
    emit(HomeLoading());

    // 1. Listen to user details stream
    _userSubscription?.cancel();
    _userSubscription = homeRepo.streamUserDetails(uid).listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          _currentUser = UserModel.fromJson(data, docId: snapshot.id);
          _emitCurrentState();
        }
      }
    }, onError: (error) {
      emit(HomeError(message: error.toString()));
    });

    // 2. Listen to client orders stream
    _ordersSubscription?.cancel();
    _ordersSubscription = homeRepo.streamClientOrders(uid).listen((snapshot) {
      _currentOrders = snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>, docId: doc.id))
          .toList();

      _syncChatListeners();
      _checkForStatusChanges();
      _emitCurrentState();
    }, onError: (error) {
      emit(HomeError(message: error.toString()));
    });
  }

  void _syncChatListeners() {
    final currentChatIds = <String>{};
    for (var order in _currentOrders) {
      if (order.driverId.isNotEmpty) {
        final chatId = '${order.orderUserId}_${order.driverId}';
        currentChatIds.add(chatId);
        if (!_chatSubscriptions.containsKey(chatId)) {
          _chatSubscriptions[chatId] = FirebaseFirestore.instance
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .snapshots()
              .listen((msgSnapshot) {
                final myUid = FirebaseAuth.instance.currentUser?.uid;
                final unreadCount = msgSnapshot.docs.where((doc) {
                  final data = doc.data();
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
      final previousStatus = _lastKnownOrderStatuses[order.orderId];
      if (previousStatus != null && previousStatus != order.orderStatus) {
        final alertMessage = HomeLogicHelper.getNotificationMessage(order.orderName, order.orderStatus);
        if (alertMessage.isNotEmpty) {
          emit(HomeStatusAlert(
            alertMessage: alertMessage,
            isSuccess: order.orderStatus == 'Delivered',
          ));
        }
      }
      _lastKnownOrderStatuses[order.orderId] = order.orderStatus;
    }
  }

  void markNotificationsAsSeen() {
    int totalNotificationsCount = 0;
    for (var order in _currentOrders) {
      totalNotificationsCount += 1;
      if (order.orderStatus != 'Waiting Driver') {
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
      if (order.orderStatus != 'Waiting Driver') {
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

  // Update user saved address (Home/Work) in Firestore
  Future<void> updateAddress(String userId, String key, String newAddress) async {
    try {
      await homeRepo.updateUserAddress(userId, key, newAddress);
      emit(HomeAddressUpdateSuccess());
      _emitCurrentState();
    } catch (e) {
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
