part of 'offers_cubit.dart';

abstract class OffersState {}

class OffersInitial extends OffersState {}

class OffersLoading extends OffersState {}

class OffersSuccess extends OffersState {}

class OffersError extends OffersState {
  final String message;
  OffersError({required this.message});
}
