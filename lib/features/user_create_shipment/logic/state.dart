// lib/features/create_shipment/logic/state.dart

abstract class CreateShipmentState {}

class CreateShipmentInitial extends CreateShipmentState {}

class CreateShipmentLoading extends CreateShipmentState {}

class CreateShipmentSuccess extends CreateShipmentState {}

class CreateShipmentError extends CreateShipmentState {
  final String message;
  CreateShipmentError(this.message);
}
