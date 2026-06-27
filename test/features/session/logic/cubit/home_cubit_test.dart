import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_order/features/session/data/repo/home_repo.dart';
import 'package:live_order/features/session/logic/cubit/home_cubit.dart';
import 'package:live_order/features/session/logic/state.dart';

class MockHomeRepo implements HomeRepo {
  String? _uid;
  final _userCtrl = StreamController<List<Map<String, dynamic>>>();
  final _ordersCtrl = StreamController<List<Map<String, dynamic>>>();
  bool _updateAddressThrows = false;
  String _updateErrorMessage = '';

  void setCurrentUid(String? uid) => _uid = uid;
  void emitUserData(List<Map<String, dynamic>> data) => _userCtrl.add(data);
  void emitOrders(List<Map<String, dynamic>> data) => _ordersCtrl.add(data);
  void throwOnUpdateAddress(String message) {
    _updateAddressThrows = true;
    _updateErrorMessage = message;
  }

  @override
  String? getCurrentUid() => _uid;

  @override
  Stream<List<Map<String, dynamic>>> streamUserDetails(String uid) =>
      _userCtrl.stream;

  @override
  Stream<List<Map<String, dynamic>>> streamClientOrders(String userId) =>
      _ordersCtrl.stream;

  @override
  Stream<List<Map<String, dynamic>>> streamChatMessages(String chatId) =>
      const Stream.empty();

  @override
  Future<void> updateUserAddress(
      String userId, String key, String newAddress) async {
    if (_updateAddressThrows) throw Exception(_updateErrorMessage);
  }

  void dispose() {
    _userCtrl.close();
    _ordersCtrl.close();
  }
}

void main() {
  group('HomeCubit', () {
    late MockHomeRepo mockRepo;
    late HomeCubit cubit;

    setUp(() {
      mockRepo = MockHomeRepo();
      cubit = HomeCubit(homeRepo: mockRepo);
    });

    tearDown(() async {
      await cubit.close();
      mockRepo.dispose();
    });

    test('initial state is HomeInitial', () {
      expect(cubit.state, const HomeInitial());
    });

    group('initHome', () {
      test('emits HomeError when uid is null', () async {
        mockRepo.setCurrentUid(null);

        final states = <HomeState>[];
        final sub = cubit.stream.listen(states.add);

        cubit.initHome();
        await Future<void>.delayed(Duration.zero);

        expect(states.length, 1);
        expect(states[0], const HomeError(message: 'لم يتم تسجيل الدخول'));
        await sub.cancel();
      });

      test('emits HomeLoading then HomeLoaded on stream data', () async {
        mockRepo.setCurrentUid('user1');

        final states = <HomeState>[];
        final sub = cubit.stream.listen(states.add);

        cubit.initHome();
        await Future<void>.delayed(Duration.zero);

        expect(states.length, 1);
        expect(states[0], const HomeLoading());

        mockRepo.emitUserData([
          {
            'uid': 'user1',
            'name': 'Test User',
            'email': 'test@test.com',
            'role': 'client',
            'created_at': '2026-01-01T00:00:00.000',
          },
        ]);
        await Future<void>.delayed(Duration.zero);

        expect(states.length, 2);
        expect(states[1], isA<HomeLoaded>());
        expect((states[1] as HomeLoaded).user.uid, 'user1');
        expect((states[1] as HomeLoaded).orders, isEmpty);
        await sub.cancel();
      });

      test('emits HomeLoaded with orders after both streams emit', () async {
        mockRepo.setCurrentUid('user1');

        final states = <HomeState>[];
        final sub = cubit.stream.listen(states.add);

        cubit.initHome();
        await Future<void>.delayed(Duration.zero);

        expect(states[0], const HomeLoading());

        mockRepo.emitUserData([
          {
            'uid': 'user1',
            'name': 'Test User',
            'email': 'test@test.com',
            'role': 'client',
            'created_at': '2026-01-01T00:00:00.000',
          },
        ]);
        await Future<void>.delayed(Duration.zero);

        mockRepo.emitOrders([
          {
            'id': 'order1',
            'pickup_address': 'شارع الملك فهد',
            'pickup_lat': 24.7136,
            'pickup_lng': 46.6753,
            'drop_address': 'شارع التحلية',
            'drop_lat': 21.5433,
            'drop_lng': 39.1728,
            'cargo_type': 'أجهزة إلكترونية',
            'size': 'L',
            'weight': 15.5,
            'notes': '',
            'images': <String>[],
            'preferred_date': '2026-07-01',
            'preferred_time_range': '10:00 - 14:00',
            'price_estimate': 150.0,
            'status': 'Waiting Driver',
            'client_id': 'user1',
          },
        ]);
        await Future<void>.delayed(Duration.zero);

        final lastState = states.last as HomeLoaded;
        expect(lastState.orders.length, 1);
        expect(lastState.orders.first.id, 'order1');
        expect(lastState.orders.first.status, 'Waiting Driver');
        await sub.cancel();
      });
    });

    group('updateAddress', () {
      test('emits HomeAddressUpdateSuccess on success', () async {
        final states = <HomeState>[];
        final sub = cubit.stream.listen(states.add);

        await cubit.updateAddress('user1', 'home_address', '123 Main St');
        await Future<void>.delayed(Duration.zero);

        expect(states.length, 1);
        expect(states[0], const HomeAddressUpdateSuccess());
        await sub.cancel();
      });

      test('emits HomeError on failure', () async {
        mockRepo.throwOnUpdateAddress('network error');

        final states = <HomeState>[];
        final sub = cubit.stream.listen(states.add);

        await cubit.updateAddress('user1', 'home_address', '123 Main St');
        await Future<void>.delayed(Duration.zero);

        expect(states.length, 1);
        expect(states[0], isA<HomeError>());
        await sub.cancel();
      });
    });
  });
}
