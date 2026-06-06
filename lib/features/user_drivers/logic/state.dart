// lib/features/drivers_list/logic/state.dart

import 'package:live_order/core/models/user_profile.dart';

abstract class DriversState {}

class DriversInitial extends DriversState {}

class DriversLoading extends DriversState {}

class DriversLoaded extends DriversState {
  final List<UserProfile> drivers;
  DriversLoaded(this.drivers);
}

class DriversError extends DriversState {
  final String message;
  DriversError(this.message);
}
