// lib/features/user_tracking/logic/state.dart

import 'package:equatable/equatable.dart';
import 'package:live_order/core/models/shipment.dart';

abstract class TrackingState extends Equatable {
  const TrackingState();

  @override
  List<Object?> get props => [];
}

class TrackingInitial extends TrackingState {
  const TrackingInitial();
}

class TrackingLoading extends TrackingState {
  const TrackingLoading();
}

class TrackingStreaming extends TrackingState {
  final Shipment shipment;

  const TrackingStreaming(this.shipment);

  @override
  List<Object?> get props => [shipment];
}

class TrackingError extends TrackingState {
  final String message;

  const TrackingError(this.message);

  @override
  List<Object?> get props => [message];
}
