// lib/features/user_create_shipment/logic/cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/features/user_create_shipment/data/repository/create_shipment_repository.dart';
import 'package:live_order/features/user_create_shipment/logic/state.dart';

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

  Future<List<UserProfile>> fetchDrivers() async {
    return _repository.getDrivers();
  }

  Future<void> cancelShipment(String orderId) async {
    await _repository.cancelShipment(orderId);
  }

  Stream<Map<String, dynamic>> getOrderStream(String orderId) {
    return _repository.getOrderStream(orderId);
  }

  String generateOrderId() {
    return _repository.generateOrderId();
  }
}
