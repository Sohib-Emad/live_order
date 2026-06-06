// lib/features/create_shipment/data/repository/create_shipment_repository.dart

import 'package:dartz/dartz.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/features/create_shipment/data/api/create_shipment_api.dart';

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
}
