// lib/features/user_drivers/logic/state.dart

import 'package:equatable/equatable.dart';
import 'package:live_order/core/models/user_profile.dart';

abstract class DriversState extends Equatable {
  const DriversState();

  @override
  List<Object?> get props => [];
}

class DriversInitial extends DriversState {
  const DriversInitial();
}

class DriversLoading extends DriversState {
  const DriversLoading();
}

class DriversLoaded extends DriversState {
  final List<UserProfile> drivers;

  const DriversLoaded(this.drivers);

  @override
  List<Object?> get props => [drivers];
}

class DriversError extends DriversState {
  final String message;

  const DriversError(this.message);

  @override
  List<Object?> get props => [message];
}
