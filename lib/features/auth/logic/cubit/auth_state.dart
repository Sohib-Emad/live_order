part of 'auth_cubit.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoadind extends AuthState {}

final class AuthRegisterSuccess extends AuthState {} // ✅ جديدة


final class AuthSuccess extends AuthState {
  final AuthModel authModel;

  AuthSuccess(this.authModel);
}

final class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}
