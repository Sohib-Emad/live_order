part of 'home_cubit.dart';

sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final UserProfile user;
  final List<Shipment> orders;
  final int totalUnreadChats;
  final int unreadNotificationsCount;

  HomeLoaded({
    required this.user,
    required this.orders,
    required this.totalUnreadChats,
    required this.unreadNotificationsCount,
  });
}

final class HomeAddressUpdateSuccess extends HomeState {}

final class HomeStatusAlert extends HomeState {
  final String alertMessage;
  final bool isSuccess;

  HomeStatusAlert({required this.alertMessage, required this.isSuccess});
}

final class HomeError extends HomeState {
  final String message;
  HomeError({required this.message});
}
