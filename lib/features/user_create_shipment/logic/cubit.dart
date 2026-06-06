// lib/features/create_shipment/logic/cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/features/create_shipment/data/repository/create_shipment_repository.dart';
import 'package:live_order/features/create_shipment/logic/state.dart';

class CreateShipmentCubit extends Cubit<CreateShipmentState> {
  final CreateShipmentRepository _repository;

  CreateShipmentCubit(this._repository) : super(CreateShipmentInitial());

  Future<void> submitShipment(Shipment shipment) async {
    emit(CreateShipmentLoading());
    final result = await _repository.createShipment(shipment);
    result.fold(
      (error) => emit(CreateShipmentError(error)),
      (_) => emit(CreateShipmentSuccess()),
    );
  }
}
