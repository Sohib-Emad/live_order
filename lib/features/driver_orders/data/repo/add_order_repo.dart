import 'package:dartz/dartz.dart';
import 'package:live_order/features/driver_orders/data/api/add_order_api.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/core/models/user_profile.dart';

class AddOrderRepo {
  final AddOrderApi _addOrderApi;

  AddOrderRepo(this._addOrderApi);

  String? get currentUid => _addOrderApi.currentUid;

  Future<Either<String, void>> createOrder(Shipment order) async {
    try {
      final uid = currentUid;
      if (uid == null) {
        return const Left('يجب تسجيل الدخول أولاً لإضافة الطلب');
      }

      final docId = '${DateTime.now().millisecondsSinceEpoch}_$uid';
      final finalOrder = order.copyWith(
        id: docId,
        clientId: uid,
        preferredDate: order.preferredDate.isNotEmpty
            ? order.preferredDate
            : DateTime.now().toIso8601String(),
        status: 'Waiting Driver',
      );

      await _addOrderApi.createOrder(finalOrder.toJson(), docId);
      return const Right(null);
    } catch (e) {
      return Left('فشل إضافة الطلب: $e');
    }
  }

  Future<Either<String, List<UserProfile>>> getAvailableDrivers() async {
    try {
      final data = await _addOrderApi.getAvailableDrivers();
      final drivers = data.map((row) => UserProfile.fromJson(row)).toList();
      return Right(drivers);
    } catch (e) {
      return Left('فشل جلب السائقين المتاحين: $e');
    }
  }

  Future<Either<String, void>> rateDriverAndComplete({
    required String shipmentId,
    required String driverId,
    required double newRating,
    required String review,
  }) async {
    try {
      // 1. Update the order with rating and review
      await _addOrderApi.updateShipmentRating(
        shipmentId: shipmentId,
        rating: newRating,
        review: review,
      );

      // 2. Fetch driver current rating details to calculate the cumulative average
      final driverData = await _addOrderApi.getDriverDoc(driverId);
      if (driverData != null) {
        final driver = UserProfile.fromJson(driverData);

        final double currentRating = driver.rating;
        final int currentTrips = driver.totalDeliveries;

        // Calculate new cumulative dynamic rating
        final int nextTrips = currentTrips + 1;
        final double nextRating =
            ((currentRating * currentTrips) + newRating) / nextTrips;

        // 3. Update driver document in users collection
        await _addOrderApi.updateDriverStats(driverId, nextRating, nextTrips);
      }

      return const Right(null);
    } catch (e) {
      return Left('فشل تسجيل التقييم: $e');
    }
  }
}
