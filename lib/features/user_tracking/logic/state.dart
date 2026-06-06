// lib/features/tracking/logic/state.dart

import 'package:live_order/core/models/shipment.dart';

abstract class TrackingState {}

class TrackingInitial extends TrackingState {}

class TrackingLoading extends TrackingState {}

class TrackingStreaming extends TrackingState {
  final Shipment shipment;
  TrackingStreaming(this.shipment);
}

class TrackingError extends TrackingState {
  final String message;
  TrackingError(this.message);
}
