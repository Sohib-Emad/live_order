import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/utils/logger.dart';
import 'package:live_order/features/driver_home/data/repo/driver_repo.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/core/models/shipment.dart';

part 'driver_state.dart';

class DriverCubit extends Cubit<DriverState> {
  final DriverRepo driverRepo;

  StreamSubscription<List<Shipment>>? _ordersSubscription;

  DriverCubit({required this.driverRepo}) : super(DriverInitial());

  Future<void> registerDriver(UserProfile driver) async {
    AppLogger.info('DriverCubit', 'registerDriver called for ${driver.email}');
    emit(DriverLoading());
    final result = await driverRepo.registerDriver(driver);
    result.fold(
      (error) {
        AppLogger.error('DriverCubit', 'registerDriver failed', error);
        emit(DriverError(message: error));
      },
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
    AppLogger.info('DriverCubit', 'acceptShipment called for $shipmentId');
    emit(DriverLoading());
    final result = await driverRepo.acceptShipment(shipmentId);
    result.fold(
      (error) {
        AppLogger.error('DriverCubit', 'acceptShipment failed', error);
        emit(DriverError(message: error));
      },
      (_) => emit(DriverSuccess()),
    );
  }

  Future<void> rejectShipment(String shipmentId) async {
    AppLogger.info('DriverCubit', 'rejectShipment called for $shipmentId');
    emit(DriverLoading());
    final result = await driverRepo.rejectShipment(shipmentId);
    result.fold(
      (error) {
        AppLogger.error('DriverCubit', 'rejectShipment failed', error);
        emit(DriverError(message: error));
      },
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
