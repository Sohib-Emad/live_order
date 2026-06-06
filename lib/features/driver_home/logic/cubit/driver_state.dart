part of 'driver_cubit.dart';

sealed class DriverState {}

final class DriverInitial extends DriverState {}

final class DriverLoading extends DriverState {}

final class DriverSuccess extends DriverState {}

final class DriverDetailsLoaded extends DriverState {
  final UserModel driver;
  DriverDetailsLoaded({required this.driver});
}

final class DriverOrdersLoaded extends DriverState {
  final List<OrderModel> orders;
  DriverOrdersLoaded({required this.orders});
}

final class DriverError extends DriverState {
  final String message;
  DriverError({required this.message});
}
