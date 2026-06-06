part of 'profile_cubit.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileAddressUpdateSuccess extends ProfileState {}

class ProfileVehicleUpdateSuccess extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;
  ProfileError({required this.message});
}
