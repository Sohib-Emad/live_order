part of 'add_order_cubit.dart';

abstract class AddOrderState extends Equatable {
  const AddOrderState();

  @override
  List<Object?> get props => [];
}

class AddOrderInitial extends AddOrderState {
  const AddOrderInitial();
}

class AddOrderLoading extends AddOrderState {
  const AddOrderLoading();
}

class AddOrderSuccess extends AddOrderState {
  const AddOrderSuccess();
}

class DriversLoaded extends AddOrderState {
  final List<UserProfile> drivers;

  const DriversLoaded({required this.drivers});

  @override
  List<Object?> get props => [drivers];
}

class AddOrderError extends AddOrderState {
  final String message;

  const AddOrderError({required this.message});

  @override
  List<Object?> get props => [message];
}
