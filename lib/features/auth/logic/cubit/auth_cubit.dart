import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/features/auth/models/auth_model.dart';
import 'package:live_order/features/auth/repo/auth_repo.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AuthCubit({required this.authRepo}) : super(AuthInitial());

  void login(String email, String password) async {
    emit(AuthLoadind());
    final result = await authRepo.login(email: email, password: password);
    if (isClosed) return;
    return result.fold(
      (error) {
        emit(AuthError(message: error));
      },
      (authModel) {
        emit(AuthSuccess(authModel));
      },
    );
  }


  void register({
    required String username,
    required String email,
    required String password,
    required String role,
    String? vehicleInfo,
    String? nationalId,
    String? licenseNumber,
  }) async {
    emit(AuthLoadind());
    final result = await authRepo.register(
      email: email,
      password: password,
      username: username,
      role: role,
      vehicleInfo: vehicleInfo,
      nationalId: nationalId,
      licenseNumber: licenseNumber,
    );
    if (isClosed) return;
    return result.fold(
      (error) {
        emit(AuthError(message: error));
      },
      (_) {
        emit(AuthRegisterSuccess());
      },
    );
  }
}
