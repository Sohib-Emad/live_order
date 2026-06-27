import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_order/features/admin/data/repo/admin_repo.dart';
import 'package:live_order/features/admin/data/api/admin_api.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAdminApi implements AdminApi {
  @override
  late final SupabaseClient supabase;

  final _usersCtrl = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _ordersCtrl =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  bool _updateStatusThrows = false;
  String _updateErrorMessage = '';

  void emitUsers(List<Map<String, dynamic>> data) => _usersCtrl.add(data);
  void emitOrders(List<Map<String, dynamic>> data) => _ordersCtrl.add(data);
  void throwOnUpdateStatus(String message) {
    _updateStatusThrows = true;
    _updateErrorMessage = message;
  }

  @override
  Stream<List<Map<String, dynamic>>> streamAllUsers() => _usersCtrl.stream;

  @override
  Stream<List<Map<String, dynamic>>> streamAllOrders() => _ordersCtrl.stream;

  @override
  Future<void> updateDriverStatus(String userId, String status) async {
    if (_updateStatusThrows) throw Exception(_updateErrorMessage);
  }

  void dispose() {
    _usersCtrl.close();
    _ordersCtrl.close();
  }
}

void main() {
  group('AdminRepo', () {
    late MockAdminApi mockApi;
    late AdminRepo repository;

    setUp(() {
      mockApi = MockAdminApi();
      repository = AdminRepo(mockApi);
    });

    tearDown(() {
      mockApi.dispose();
    });

    group('streamAllUsers', () {
      test('maps raw data to UserProfile objects', () async {
        final users = <UserProfile>[];
        final sub = repository.streamAllUsers().listen(users.addAll);

        mockApi.emitUsers([
          {
            'uid': 'user_1',
            'name': 'Test User',
            'email': 'test@test.com',
            'role': 'client',
            'created_at': '2026-01-01T00:00:00.000',
          },
        ]);
        await Future<void>.delayed(Duration.zero);

        expect(users.length, 1);
        expect(users[0].uid, 'user_1');
        expect(users[0].name, 'Test User');
        expect(users[0].email, 'test@test.com');
        await sub.cancel();
      });

      test('handles empty list', () async {
        final users = <UserProfile>[];
        final sub = repository.streamAllUsers().listen(users.addAll);

        mockApi.emitUsers([]);
        await Future<void>.delayed(Duration.zero);

        expect(users, isEmpty);
        await sub.cancel();
      });

      test('maps uid from id field when uid is missing', () async {
        final users = <UserProfile>[];
        final sub = repository.streamAllUsers().listen(users.addAll);

        mockApi.emitUsers([
          {
            'id': 'id_based',
            'name': 'ID User',
            'email': 'id@test.com',
            'role': 'driver',
          },
        ]);
        await Future<void>.delayed(Duration.zero);

        expect(users[0].uid, 'id_based');
        await sub.cancel();
      });
    });

    group('streamAllOrders', () {
      test('maps raw data to Shipment objects', () async {
        final shipments = <Shipment>[];
        final sub = repository.streamAllOrders().listen(shipments.addAll);

        mockApi.emitOrders([
          {
            'id': 'order_1',
            'pickupAddress': 'Pickup Location',
            'pickupLat': 25.0,
            'pickupLng': 47.0,
            'dropAddress': 'Drop Location',
            'dropLat': 22.0,
            'dropLng': 40.0,
            'cargoType': 'Test Cargo',
            'size': 'M',
            'weight': 10.0,
            'notes': '',
            'images': <String>[],
            'preferredDate': '2026-07-15',
            'preferredTimeRange': '10:00-12:00',
            'priceEstimate': 200.0,
            'status': 'Waiting Driver',
          },
        ]);
        await Future<void>.delayed(Duration.zero);

        expect(shipments.length, 1);
        expect(shipments[0].id, 'order_1');
        expect(shipments[0].cargoType, 'Test Cargo');
        expect(shipments[0].status, 'Waiting Driver');
        await sub.cancel();
      });

      test('handles empty list', () async {
        final shipments = <Shipment>[];
        final sub = repository.streamAllOrders().listen(shipments.addAll);

        mockApi.emitOrders([]);
        await Future<void>.delayed(Duration.zero);

        expect(shipments, isEmpty);
        await sub.cancel();
      });
    });

    group('approveDriver', () {
      test('returns Right on success', () async {
        final result = await repository.approveDriver('driver_1');
        expect(result.isRight(), isTrue);
      });

      test('returns Left with error message on failure', () async {
        mockApi.throwOnUpdateStatus('DB error');

        final result = await repository.approveDriver('driver_1');
        expect(result.isLeft(), isTrue);
        result.fold(
          (l) => expect(l, contains('DB error')),
          (r) => fail('expected Left'),
        );
      });
    });

    group('updateDriverBlockStatus', () {
      test('returns Right on success', () async {
        final result =
            await repository.updateDriverBlockStatus('driver_1', 'blocked');
        expect(result.isRight(), isTrue);
      });

      test('returns Left with error message on failure', () async {
        mockApi.throwOnUpdateStatus('Network error');

        final result =
            await repository.updateDriverBlockStatus('driver_1', 'blocked');
        expect(result.isLeft(), isTrue);
        result.fold(
          (l) => expect(l, contains('Network error')),
          (r) => fail('expected Left'),
        );
      });
    });
  });
}
