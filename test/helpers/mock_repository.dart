import 'package:dartz/dartz.dart';

/// Base class for creating mock repositories in Cubit tests.
///
/// Extend this class and use [result] or [futureResult] inside your
/// overridden methods to return a controlled success or error value.
abstract class MockRepository<T> {
  Either<String, T>? _result;

  /// Manually set the full [Either] value to return.
  void setResult(Either<String, T> result) => _result = result;

  /// Configure the mock to return a successful result with [value].
  void setSuccess(T value) => _result = Right(value);

  /// Configure the mock to return an error with [message].
  void setError(String message) => _result = Left(message);

  /// The pre-configured result. Throws if no result has been set.
  Either<String, T> get result {
    final r = _result;
    if (r == null) {
      throw StateError(
        'No result configured. Call setResult(), setSuccess(), or setError() first.',
      );
    }
    return r;
  }

  /// Convenience getter that wraps [result] in a [Future].
  Future<Either<String, T>> get futureResult async => result;
}
