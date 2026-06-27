// lib/features/user_drivers/data/repository/drivers_repository.dart

import 'package:dartz/dartz.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/features/user_drivers/data/api/drivers_api.dart';

class DriversRepository {
  final DriversApi _api;

  DriversRepository(this._api);

  Future<Either<String, List<UserProfile>>> getDriversList() async {
    try {
      final list = await _api.getDriversList();
      return Right(list.map((json) => UserProfile.fromJson(json)).toList());
    } catch (e) {
      return Left('Failed to load drivers: $e');
    }
  }

  Future<Either<String, void>> reportDriver({
    required String driverId,
    required String driverName,
    required String reporterId,
    required String reason,
  }) async {
    try {
      await _api.reportDriver(
        driverId: driverId,
        driverName: driverName,
        reporterId: reporterId,
        reason: reason,
      );
      return const Right(null);
    } catch (e) {
      return Left('Failed to report driver: $e');
    }
  }

  String? getCurrentUserId() => _api.getCurrentUserId();
}
