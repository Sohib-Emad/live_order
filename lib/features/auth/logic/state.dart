import 'package:equatable/equatable.dart';
import 'package:live_order/features/auth/models/auth_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthRegisterSuccess extends AuthState {
  const AuthRegisterSuccess();
}

class AuthSuccess extends AuthState {
  final AuthModel authModel;

  const AuthSuccess(this.authModel);

  @override
  List<Object?> get props => [authModel];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
