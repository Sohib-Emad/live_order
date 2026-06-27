// lib/features/user_drivers/logic/cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/features/user_drivers/data/repository/drivers_repository.dart';
import 'package:live_order/features/user_drivers/logic/state.dart';

class DriversCubit extends Cubit<DriversState> {
  final DriversRepository _repository;

  DriversCubit(this._repository) : super(const DriversInitial());

  Future<void> loadDrivers() async {
    emit(const DriversLoading());
    final result = await _repository.getDriversList();
    result.fold(
      (error) => emit(DriversError(error)),
      (list) => emit(DriversLoaded(list)),
    );
  }

  Future<void> reportDriver(String driverId, String driverName, String reason) async {
    final reporterId = _repository.getCurrentUserId() ?? 'client_1';
    final result = await _repository.reportDriver(
      driverId: driverId,
      driverName: driverName,
      reporterId: reporterId,
      reason: reason,
    );
    result.fold(
      (error) => emit(DriversError(error)),
      (_) {},
    );
  }
}
