import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:live_order/features/add_order/data/api/add_order_api.dart';
import 'package:live_order/features/add_order/models/order_model.dart';
import 'package:live_order/features/add_order/models/user_model.dart';

class AddOrderRepo {
  final AddOrderApi _addOrderApi;

  AddOrderRepo(this._addOrderApi);

  String? get currentUid => _addOrderApi.currentUid;

  Future<Either<String, void>> createOrder(OrderModel order) async {
    try {
      final uid = currentUid;
      if (uid == null) {
        return const Left('يجب تسجيل الدخول أولاً لإضافة الطلب');
      }

      final docRef = FirebaseFirestore.instance.collection('orders').doc();
      final finalOrder = order.copyWith(
        orderId: docRef.id,
        orderUserId: uid,
        orderDate: order.orderDate.isNotEmpty
            ? order.orderDate
            : DateTime.now().toIso8601String(),
        orderStatus: 'Waiting Driver',
      );

      await _addOrderApi.createOrder(finalOrder.toJson(), docRef.id);
      return const Right(null);
    } catch (e) {
      return Left('فشل إضافة الطلب: $e');
    }
  }

  Future<Either<String, List<UserModel>>> getAvailableDrivers() async {
    try {
      final snapshot = await _addOrderApi.getAvailableDrivers();
      final drivers = snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>, docId: doc.id))
          .toList();
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
      final driverDoc = await _addOrderApi.getDriverDoc(driverId);
      if (driverDoc.exists && driverDoc.data() != null) {
        final driver = UserModel.fromJson(driverDoc.data() as Map<String, dynamic>, docId: driverDoc.id);

        final double currentRating = driver.rating;
        final int currentTrips = driver.tripsCount;

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
