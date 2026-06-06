import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/features/auth/models/auth_model.dart';
import 'package:live_order/core/utils/logger.dart';
import 'package:live_order/features/auth/repo/auth_repo.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AuthCubit({required this.authRepo}) : super(AuthInitial());

  void login(String email, String password) async {
    AppLogger.info('AuthCubit', 'login called for $email');
    emit(AuthLoadind());
    final result = await authRepo.login(email: email, password: password);
    if (isClosed) return;
    return result.fold(
      (error) {
        AppLogger.error('AuthCubit', 'login failed', error);
        emit(AuthError(message: error));
      },
      (authModel) {
        AppLogger.info('AuthCubit', 'login succeeded for ${authModel.email}');
        emit(AuthSuccess(authModel));
      },
    );
  }

  void register({
    required String role,
    required String username,
    required String email,
    required String password,
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
    AppLogger.info('AuthCubit', 'register called for $email (role: $role)');
    emit(AuthLoadind());
    final result = await authRepo.register(
      email: email,
      password: password,
      username: username,
      role: role,
      phone: phone,
      address: address,
      vehicleType: vehicleType,
      vehiclePlate: vehiclePlate,
      vehicleCapacity: vehicleCapacity,
      nationalId: nationalId,
      licenseNumber: licenseNumber,
      driverImage: driverImage,
      idFrontImage: idFrontImage,
      idBackImage: idBackImage,
      licenseImage: licenseImage,
      vehicleImage: vehicleImage,
    );
    if (isClosed) return;
    return result.fold(
      (error) {
        AppLogger.error('AuthCubit', 'register failed', error);
        emit(AuthError(message: error));
      },
      (_) {
        AppLogger.info('AuthCubit', 'register succeeded for $email');
        emit(AuthRegisterSuccess());
      },
    );
  }
}
