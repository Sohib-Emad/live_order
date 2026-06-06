part of 'user_cubit.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserDataLoaded extends UserState {
  final Map<String, dynamic> userData;

  const UserDataLoaded(this.userData);

  @override
  List<Object?> get props => [userData];
}

class UserStatsLoaded extends UserState {
  final Map<String, dynamic> stats;

  const UserStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class UserDataUpdateSuccess extends UserState {
  final String message;

  const UserDataUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class UserProfileImageUpdateSuccess extends UserState {
  final String message;

  const UserProfileImageUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class UserContactInfoUpdateSuccess extends UserState {
  final String message;

  const UserContactInfoUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class UserNotificationSettingsUpdateSuccess extends UserState {
  final String message;

  const UserNotificationSettingsUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class UserActivityLoaded extends UserState {
  final List<Map<String, dynamic>> activity;

  const UserActivityLoaded(this.activity);

  @override
  List<Object?> get props => [activity];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserAccountDeletedSuccess extends UserState {
  final String message;

  const UserAccountDeletedSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
