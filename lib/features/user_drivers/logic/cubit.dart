// lib/features/user_drivers/logic/cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/features/user_drivers/data/repository/drivers_repository.dart';
import 'package:live_order/features/user_drivers/logic/state.dart';

class DriversCubit extends Cubit<DriversState> {
  final DriversRepository _repository;

  DriversCubit(this._repository) : super(DriversInitial());

  Future<void> loadDrivers() async {
    emit(DriversLoading());
    try {
      final list = await _repository.getDriversList();
      emit(DriversLoaded(list));
    } catch (e) {
      emit(DriversError(e.toString()));
    }
  }
}
