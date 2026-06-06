part of 'admin_cubit.dart';

sealed class AdminState {}

final class AdminInitial extends AdminState {}

final class AdminLoading extends AdminState {}

final class AdminLoaded extends AdminState {
  final List<UserProfile> users;
  final List<Shipment> orders;

  AdminLoaded({required this.users, required this.orders});
}

final class AdminActionSuccess extends AdminState {
  final String message;
  AdminActionSuccess({required this.message});
}

final class AdminError extends AdminState {
  final String message;
  AdminError({required this.message});
}
