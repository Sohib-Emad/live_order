part of 'admin_cubit.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminLoaded extends AdminState {
  final List<UserProfile> users;
  final List<Shipment> orders;

  const AdminLoaded({required this.users, required this.orders});

  @override
  List<Object?> get props => [users, orders];
}

class AdminActionSuccess extends AdminState {
  final String message;

  const AdminActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AdminError extends AdminState {
  final String message;

  const AdminError({required this.message});

  @override
  List<Object?> get props => [message];
}
