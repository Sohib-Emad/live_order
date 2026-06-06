// lib/features/tracking/logic/cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/features/tracking/data/repository/tracking_repository.dart';
import 'package:live_order/features/tracking/logic/state.dart';

class TrackingCubit extends Cubit<TrackingState> {
  final TrackingRepository _repository;
  StreamSubscription? _subscription;

  TrackingCubit(this._repository) : super(TrackingInitial());

  void startTracking(String shipmentId, Shipment initialShipment) {
    emit(TrackingStreaming(initialShipment));
    _subscription?.cancel();
    _subscription = _repository.streamTrackingData(shipmentId).listen((doc) {
      if (doc.exists && doc.data() != null) {
        final shipment = Shipment.fromJson(doc.data() as Map<String, dynamic>);
        emit(TrackingStreaming(shipment));
      }
    }, onError: (err) {
      emit(TrackingError(err.toString()));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
