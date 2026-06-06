// lib/features/user_rate_driver/logic/state.dart

abstract class RateDriverState {}

class RateDriverInitial extends RateDriverState {}

class RateDriverSubmitting extends RateDriverState {}

class RateDriverSuccess extends RateDriverState {}

class RateDriverError extends RateDriverState {
  final String message;
  RateDriverError(this.message);
}
