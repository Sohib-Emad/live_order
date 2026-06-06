import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/features/driver/data/repo/driver_repo.dart';
import 'package:live_order/features/add_order/models/user_model.dart';
import 'package:live_order/features/add_order/models/order_model.dart';

part 'driver_state.dart';

class DriverCubit extends Cubit<DriverState> {
  final DriverRepo driverRepo;

  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  DriverCubit({required this.driverRepo}) : super(DriverInitial());

  Future<void> registerDriver(UserModel driver) async {
    emit(DriverLoading());
    final result = await driverRepo.registerDriver(driver);
    result.fold(
      (error) => emit(DriverError(message: error)),
      (_) => emit(DriverSuccess()),
    );
  }

  Future<void> getDriverDetails(String uid) async {
    emit(DriverLoading());
    final result = await driverRepo.getDriverDetails(uid);
    result.fold(
      (error) => emit(DriverError(message: error)),
      (driver) => emit(DriverDetailsLoaded(driver: driver)),
    );
  }

  void streamDriverOrders(String driverId) {
    emit(DriverLoading());
    _ordersSubscription?.cancel();
    _ordersSubscription = driverRepo.streamDriverOrders(driverId).listen((orders) {
      emit(DriverOrdersLoaded(orders: orders));
    }, onError: (error) {
      emit(DriverError(message: error.toString()));
    });
  }

  Future<void> acceptShipment(String shipmentId) async {
    emit(DriverLoading());
    final result = await driverRepo.acceptShipment(shipmentId);
    result.fold(
      (error) => emit(DriverError(message: error)),
      (_) => emit(DriverSuccess()),
    );
  }

  Future<void> rejectShipment(String shipmentId) async {
    emit(DriverLoading());
    final result = await driverRepo.rejectShipment(shipmentId);
    result.fold(
      (error) => emit(DriverError(message: error)),
      (_) => emit(DriverSuccess()),
    );
  }

  Future<void> updateShipmentStatus(String shipmentId, String status) async {
    emit(DriverLoading());
    final result = await driverRepo.updateShipmentStatus(shipmentId, status);
    result.fold(
      (error) => emit(DriverError(message: error)),
      (_) => emit(DriverSuccess()),
    );
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
