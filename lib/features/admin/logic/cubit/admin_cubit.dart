import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/utils/logger.dart';
import 'package:live_order/features/admin/data/repo/admin_repo.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/core/models/shipment.dart';

part 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepo adminRepo;

  StreamSubscription<List<UserProfile>>? _usersSubscription;
  StreamSubscription<List<Shipment>>? _ordersSubscription;

  List<UserProfile> _allUsers = [];
  List<Shipment> _allOrders = [];

  AdminCubit({required this.adminRepo}) : super(const AdminInitial());

  void _subscribeToUsers() {
    _usersSubscription?.cancel();
    _usersSubscription = adminRepo.streamAllUsers().listen((users) {
      _allUsers = users;
      _emitLoadedState();
    }, onError: (error) {
      AppLogger.error('AdminCubit', 'Users stream error', error);
      Future.delayed(const Duration(seconds: 3), _subscribeToUsers);
    });
  }

  void _subscribeToOrders() {
    _ordersSubscription?.cancel();
    _ordersSubscription = adminRepo.streamAllOrders().listen((orders) {
      _allOrders = orders;
      _emitLoadedState();
    }, onError: (error) {
      AppLogger.error('AdminCubit', 'Orders stream error', error);
      Future.delayed(const Duration(seconds: 3), _subscribeToOrders);
    });
  }

  void initAdminDashboard() {
    AppLogger.info('AdminCubit', 'initAdminDashboard called');
    emit(const AdminLoading());
    _subscribeToUsers();
    _subscribeToOrders();
  }

  void _emitLoadedState() {
    emit(AdminLoaded(users: _allUsers, orders: _allOrders));
  }

  Future<void> approveDriver(String driverId) async {
    AppLogger.info('AdminCubit', 'approveDriver called for $driverId');
    final result = await adminRepo.approveDriver(driverId);
    result.fold(
      (error) {
        AppLogger.error('AdminCubit', 'approveDriver failed', error);
        emit(AdminError(message: error));
      },
      (_) {
        _allUsers = _allUsers.map((u) {
          if (u.uid == driverId) return u.copyWith(driverStatus: 'active');
          return u;
        }).toList();
        _emitLoadedState();
        emit(AdminActionSuccess(message: 'تم تفعيل حساب السائق بنجاح وإتاحته للعملاء!'));
      },
    );
  }

  Future<void> toggleUserBlock(UserProfile user) async {
    final nextStatus = user.driverStatus == 'blocked' ? 'active' : 'blocked';
    final result = await adminRepo.updateDriverBlockStatus(user.uid, nextStatus);
    result.fold(
      (error) => emit(AdminError(message: error)),
      (_) {
        _allUsers = _allUsers.map((u) {
          if (u.uid == user.uid) return u.copyWith(driverStatus: nextStatus);
          return u;
        }).toList();
        _emitLoadedState();
        emit(AdminActionSuccess(
          message: nextStatus == 'blocked'
              ? 'تم حظر المستخدم بنجاح!'
              : 'تم إلغاء الحظر وتفعيل الحساب!',
        ));
      },
    );
  }

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    _ordersSubscription?.cancel();
    return super.close();
  }
}
