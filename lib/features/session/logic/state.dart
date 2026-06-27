import 'package:equatable/equatable.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/core/models/shipment.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final UserProfile user;
  final List<Shipment> orders;
  final int totalUnreadChats;
  final int unreadNotificationsCount;

  const HomeLoaded({
    required this.user,
    required this.orders,
    required this.totalUnreadChats,
    required this.unreadNotificationsCount,
  });

  @override
  List<Object?> get props => [user, orders, totalUnreadChats, unreadNotificationsCount];
}

class HomeAddressUpdateSuccess extends HomeState {
  const HomeAddressUpdateSuccess();
}

class HomeStatusAlert extends HomeState {
  final String alertMessage;
  final bool isSuccess;

  const HomeStatusAlert({required this.alertMessage, required this.isSuccess});

  @override
  List<Object?> get props => [alertMessage, isSuccess];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
