import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/features/admin/data/repo/admin_repo.dart';
import 'package:live_order/features/add_order/models/user_model.dart';
import 'package:live_order/features/add_order/models/order_model.dart';

part 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepo adminRepo;

  StreamSubscription<List<UserModel>>? _usersSubscription;
  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  List<UserModel> _allUsers = [];
  List<OrderModel> _allOrders = [];

  AdminCubit({required this.adminRepo}) : super(AdminInitial());

  void initAdminDashboard() {
    emit(AdminLoading());

    _usersSubscription?.cancel();
    _usersSubscription = adminRepo.streamAllUsers().listen((users) {
      _allUsers = users;
      _emitLoadedState();
    }, onError: (error) {
      emit(AdminError(message: error.toString()));
    });

    _ordersSubscription?.cancel();
    _ordersSubscription = adminRepo.streamAllOrders().listen((orders) {
      _allOrders = orders;
      _emitLoadedState();
    }, onError: (error) {
      emit(AdminError(message: error.toString()));
    });
  }

  void _emitLoadedState() {
    emit(AdminLoaded(users: _allUsers, orders: _allOrders));
  }

  Future<void> approveDriver(String driverId) async {
    final result = await adminRepo.approveDriver(driverId);
    result.fold(
      (error) => emit(AdminError(message: error)),
      (_) => emit(AdminActionSuccess(message: 'تم تفعيل حساب السائق بنجاح وإتاحته للعملاء!')),
    );
    _emitLoadedState();
  }

  Future<void> toggleUserBlock(UserModel user) async {
    final nextStatus = user.driverStatus == 'blocked' ? 'active' : 'blocked';
    final result = await adminRepo.updateDriverBlockStatus(user.userId, nextStatus);
    result.fold(
      (error) => emit(AdminError(message: error)),
      (_) => emit(AdminActionSuccess(
        message: nextStatus == 'blocked'
            ? 'تم حظر المستخدم بنجاح!'
            : 'تم إلغاء الحظر وتفعيل الحساب!',
      )),
    );
    _emitLoadedState();
  }

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    _ordersSubscription?.cancel();
    return super.close();
  }
}
