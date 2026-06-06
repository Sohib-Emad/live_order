part of 'add_order_cubit.dart';

sealed class AddOrderState {}

final class AddOrderInitial extends AddOrderState {}

final class AddOrderLoading extends AddOrderState {}

final class AddOrderSuccess extends AddOrderState {}

final class DriversLoaded extends AddOrderState {
  final List<UserModel> drivers;
  DriversLoaded({required this.drivers});
}

final class AddOrderError extends AddOrderState {
  final String message;
  AddOrderError({required this.message});
}
