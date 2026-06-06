// lib/features/user_tracking/logic/cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/features/user_tracking/data/repository/tracking_repository.dart';
import 'package:live_order/features/user_tracking/logic/state.dart';

class TrackingCubit extends Cubit<TrackingState> {
  final TrackingRepository _repository;
  StreamSubscription? _subscription;
  StreamSubscription? _driverLocationSubscription;

  TrackingCubit(this._repository) : super(TrackingInitial());

  void startTracking(String shipmentId, Shipment initialShipment) {
    final driverUid = initialShipment.assignedDriver?.uid;
    emit(TrackingStreaming(initialShipment));

    _subscription?.cancel();
    _subscription = _repository.streamTrackingData(shipmentId).listen((data) {
      if (data['id'] != null) {
        final shipment = Shipment.fromJson(data);
        _subscribeToDriverLocation(shipment);
        emit(TrackingStreaming(shipment));
      }
    }, onError: (err) {
      emit(TrackingError(err.toString()));
    });

    if (driverUid != null && driverUid.isNotEmpty) {
      _subscribeToDriverLocation(initialShipment);
    }
  }

  void _subscribeToDriverLocation(Shipment shipment) {
    final driverUid = shipment.assignedDriver?.uid;
    if (driverUid == null || driverUid.isEmpty) return;

    _driverLocationSubscription?.cancel();
    _driverLocationSubscription = _repository.streamDriverLocation(driverUid).listen((userData) {
      if (userData['uid'] == null) return;
      final currentState = state;
      if (currentState is TrackingStreaming) {
        final s = currentState.shipment;
        final driver = s.assignedDriver;
        if (driver != null) {
          final newLat = (userData['current_lat'] as num?)?.toDouble();
          final newLng = (userData['current_long'] as num?)?.toDouble();
          if (newLat != null) driver.currentLat = newLat;
          if (newLng != null) driver.currentLong = newLng;
          emit(TrackingStreaming(s));
        }
      }
    }, onError: (_) {});
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _driverLocationSubscription?.cancel();
    return super.close();
  }
}
