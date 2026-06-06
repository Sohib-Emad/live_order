// lib/features/user_create_shipment/data/repository/create_shipment_repository.dart

import 'package:dartz/dartz.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/features/user_create_shipment/data/api/create_shipment_api.dart';

class CreateShipmentRepository {
  final CreateShipmentApi _api;

  CreateShipmentRepository(this._api);

  Future<Either<String, void>> createShipment(Shipment shipment) async {
    try {
      await _api.submitShipment(shipment.toJson());
      return const Right(null);
    } catch (e) {
      return Left('Failed to create shipment: $e');
    }
  }

  Future<List<UserProfile>> getDrivers() async {
    final list = await _api.fetchDrivers();
    return list.map((json) => UserProfile.fromJson(json)).toList();
  }

  Future<void> cancelShipment(String orderId) async {
    await _api.cancelShipment(orderId);
  }

  Stream<Map<String, dynamic>> getOrderStream(String orderId) {
    return _api.getOrderStream(orderId);
  }

  String generateOrderId() {
    return _api.generateOrderId();
  }
}
