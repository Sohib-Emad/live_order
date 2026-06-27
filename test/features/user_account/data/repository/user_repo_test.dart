import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:live_order/core/services/supabase_service.dart';
import 'package:live_order/features/user_account/data/api/user_api.dart';
import 'package:live_order/features/user_account/data/repo/user_repo.dart';

class MockUserApi extends UserApi {
  Map<String, dynamic>? _getUserDataResult;
  bool _shouldThrow = false;
  String _throwMessage = '';

  void setGetUserDataSuccess(Map<String, dynamic> data) {
    _getUserDataResult = data;
    _shouldThrow = false;
  }

  void setGetUserDataError(String message) {
    _shouldThrow = true;
    _throwMessage = message;
  }

  void setUpdateSuccess() {
    _shouldThrow = false;
  }

  void setUpdateError(String message) {
    _shouldThrow = true;
    _throwMessage = message;
  }

  @override
  Future<Map<String, dynamic>> getUserData(String userId) async {
    if (_shouldThrow) throw Exception(_throwMessage);
    return _getUserDataResult ?? {};
  }

  @override
  Future<void> updateUserData(
      String userId, Map<String, dynamic> data) async {
    if (_shouldThrow) throw Exception(_throwMessage);
  }
}

void main() {
  group('UserRepository', () {
    late MockUserApi mockApi;
    late UserRepository repo;

    setUpAll(() {
      SupabaseService.initializeWithClient(
        SupabaseClient('http://localhost:54321', 'fake-anon-key'),
      );
    });

    setUp(() {
      mockApi = MockUserApi();
      repo = UserRepository(userApi: mockApi);
    });

    group('getProfile', () {
      test('returns Right with data on success', () async {
        final userData = {
          'uid': 'user1',
          'name': 'Test User',
          'email': 'test@test.com',
          'role': 'client',
        };
        mockApi.setGetUserDataSuccess(userData);

        final result = await repo.getUserData('user1');

        expect(result.isRight(), true);
        result.fold((_) => null, (data) {
          expect(data['uid'], 'user1');
          expect(data['name'], 'Test User');
        });
      });

      test('returns Left with error on failure', () async {
        mockApi.setGetUserDataError('network error');

        final result = await repo.getUserData('user1');

        expect(result.isLeft(), true);
        result.fold((error) {
          expect(error, contains('network error'));
        }, (_) => null);
      });
    });

    group('updatePersonalInfo', () {
      test('returns Right null on success', () async {
        mockApi.setUpdateSuccess();

        final result =
            await repo.updatePersonalInfo('user1', 'New Name', 'new@test.com');

        expect(result.isRight(), true);
      });

      test('returns Left with error on failure', () async {
        mockApi.setUpdateError('database error');

        final result =
            await repo.updatePersonalInfo('user1', 'New Name', 'new@test.com');

        expect(result.isLeft(), true);
        result.fold((error) {
          expect(error, contains('database error'));
        }, (_) => null);
      });
    });
  });
}
