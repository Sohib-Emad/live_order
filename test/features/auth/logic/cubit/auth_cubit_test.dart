import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:live_order/core/services/supabase_service.dart';
import 'package:live_order/features/auth/logic/cubit/auth_cubit.dart';
import 'package:live_order/features/auth/logic/state.dart';
import 'package:live_order/features/auth/models/auth_model.dart';
import 'package:live_order/features/auth/repo/auth_repo.dart';

class MockAuthRepo extends AuthRepo {
  Either<String, AuthModel>? _loginResult;
  Either<String, String>? _registerResult;

  void setLoginSuccess(AuthModel model) => _loginResult = Right(model);
  void setLoginError(String message) => _loginResult = Left(message);
  void setRegisterSuccess() => _registerResult = const Right('success');
  void setRegisterError(String message) => _registerResult = Left(message);

  @override
  Future<Either<String, AuthModel>> login({
    required String email,
    required String password,
  }) async {
    return _loginResult ?? Left('no result configured');
  }

  @override
  Future<Either<String, String>> register({
    required String email,
    required String password,
    required String username,
    required String role,
    String? phone,
    String? address,
    String? vehicleType,
    String? vehiclePlate,
    String? vehicleCapacity,
    String? nationalId,
    String? licenseNumber,
    File? driverImage,
    File? idFrontImage,
    File? idBackImage,
    File? licenseImage,
    File? vehicleImage,
  }) async {
    return _registerResult ?? Left('no result configured');
  }
}

void main() {
  group('AuthCubit', () {
    late MockAuthRepo mockRepo;
    late AuthCubit cubit;

    setUpAll(() {
      SupabaseService.initializeWithClient(
        SupabaseClient('http://localhost:54321', 'fake-anon-key'),
      );
    });

    setUp(() {
      mockRepo = MockAuthRepo();
      cubit = AuthCubit(authRepo: mockRepo);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is AuthInitial', () {
      expect(cubit.state, const AuthInitial());
    });

    group('login', () {
      test('emits AuthLoading then AuthSuccess on success', () async {
        final model = AuthModel(
          email: 'user@test.com',
          password: 'pass123',
          uid: 'uid_1',
        );
        mockRepo.setLoginSuccess(model);

        final states = <AuthState>[];
        final sub = cubit.stream.listen(states.add);

        cubit.login('user@test.com', 'pass123');
        await Future<void>.delayed(Duration.zero);

        expect(states.length, 2);
        expect(states[0], const AuthLoading());
        expect(states[1], AuthSuccess(model));
        await sub.cancel();
      });

      test('emits AuthLoading then AuthError on failure', () async {
        mockRepo.setLoginError('Invalid credentials');

        final states = <AuthState>[];
        final sub = cubit.stream.listen(states.add);

        cubit.login('user@test.com', 'wrong');
        await Future<void>.delayed(Duration.zero);

        expect(states.length, 2);
        expect(states[0], const AuthLoading());
        expect(states[1], const AuthError(message: 'Invalid credentials'));
        await sub.cancel();
      });
    });

    group('register', () {
      test('emits AuthLoading then AuthRegisterSuccess on success', () async {
        mockRepo.setRegisterSuccess();

        final states = <AuthState>[];
        final sub = cubit.stream.listen(states.add);

        cubit.register(
          role: 'client',
          username: 'newuser',
          email: 'new@test.com',
          password: 'pass123',
        );
        await Future<void>.delayed(Duration.zero);

        expect(states.length, 2);
        expect(states[0], const AuthLoading());
        expect(states[1], const AuthRegisterSuccess());
        await sub.cancel();
      });

      test('emits AuthLoading then AuthError on failure', () async {
        mockRepo.setRegisterError('Email already exists');

        final states = <AuthState>[];
        final sub = cubit.stream.listen(states.add);

        cubit.register(
          role: 'client',
          username: 'newuser',
          email: 'new@test.com',
          password: 'pass123',
        );
        await Future<void>.delayed(Duration.zero);

        expect(states.length, 2);
        expect(states[0], const AuthLoading());
        expect(states[1], const AuthError(message: 'Email already exists'));
        await sub.cancel();
      });
    });
  });
}
