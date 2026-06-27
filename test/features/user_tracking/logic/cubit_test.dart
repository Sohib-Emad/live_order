import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_order/features/user_tracking/logic/cubit.dart';
import 'package:live_order/features/user_tracking/logic/state.dart';
import 'package:live_order/features/user_tracking/data/repository/tracking_repository.dart';
import '../../../helpers/test_data.dart';

class MockTrackingRepository implements TrackingRepository {
  final _trackingCtrl = StreamController<Map<String, dynamic>>.broadcast();
  final _driverLocationCtrl = StreamController<Map<String, dynamic>>.broadcast();

  void addTrackingData(Map<String, dynamic> data) => _trackingCtrl.add(data);
  void addTrackingError(Object error) => _trackingCtrl.addError(error);

  @override
  Stream<Map<String, dynamic>> streamTrackingData(String shipmentId) =>
      _trackingCtrl.stream;

  @override
  Stream<Map<String, dynamic>> streamDriverLocation(String driverUid) =>
      _driverLocationCtrl.stream;

  void dispose() {
    _trackingCtrl.close();
    _driverLocationCtrl.close();
  }
}

void main() {
  group('TrackingCubit', () {
    late MockTrackingRepository repository;
    late TrackingCubit cubit;

    setUp(() {
      repository = MockTrackingRepository();
      cubit = TrackingCubit(repository);
    });

    tearDown(() {
      cubit.close();
      repository.dispose();
    });

    test('initial state is TrackingInitial', () {
      expect(cubit.state, isA<TrackingInitial>());
    });

    group('startTracking', () {
      test('emits TrackingStreaming with initial shipment immediately', () {
        final driver = sampleUserProfile(uid: 'driver_1', role: 'driver');
        final shipment = sampleShipment(id: 'track_1', assignedDriver: driver);

        cubit.startTracking('track_1', shipment);

        expect(cubit.state, isA<TrackingStreaming>());
        expect((cubit.state as TrackingStreaming).shipment.id, 'track_1');
      });

      test('updates shipment from stream data', () async {
        final driver = sampleUserProfile(uid: 'driver_1', role: 'driver');
        final shipment = sampleShipment(id: 'track_1', assignedDriver: driver);
        cubit.startTracking('track_1', shipment);

        await Future<void>.delayed(Duration.zero);

        repository.addTrackingData({
          'id': 'track_1',
          'pickupAddress': 'Updated Address',
          'pickupLat': 25.0,
          'pickupLng': 47.0,
          'dropAddress': 'Drop Updated',
          'dropLat': 22.0,
          'dropLng': 40.0,
          'cargoType': 'Electronics',
          'size': 'M',
          'weight': 10.0,
          'notes': '',
          'images': <String>[],
          'preferredDate': '2026-07-15',
          'preferredTimeRange': '10:00-12:00',
          'priceEstimate': 200.0,
          'status': 'In Transit',
        });
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state, isA<TrackingStreaming>());
        final state = cubit.state as TrackingStreaming;
        expect(state.shipment.pickupAddress, 'Updated Address');
        expect(state.shipment.status, 'In Transit');
      });

      test('emits TrackingError on stream error', () async {
        final shipment = sampleShipment(id: 'track_1');
        cubit.startTracking('track_1', shipment);

        await Future<void>.delayed(Duration.zero);

        repository.addTrackingError('Connection lost');
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state, isA<TrackingError>());
        expect((cubit.state as TrackingError).message, 'Connection lost');
      });
    });
  });
}
