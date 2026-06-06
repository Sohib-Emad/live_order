import 'package:dartz/dartz.dart';
import 'package:live_order/features/driver/data/api/driver_api.dart';
import 'package:live_order/features/add_order/models/user_model.dart';
import 'package:live_order/features/add_order/models/order_model.dart';

class DriverRepo {
  final DriverApi _driverApi;

  DriverRepo(this._driverApi);

  Future<Either<String, void>> registerDriver(UserModel driver) async {
    try {
      await _driverApi.registerDriver(driver.toJson(), driver.userId);
      return const Right(null);
    } catch (e) {
      return Left('فشل تسجيل حساب السائق: $e');
    }
  }

  Future<Either<String, UserModel>> getDriverDetails(String uid) async {
    try {
      final doc = await _driverApi.getDriverDetails(uid);
      if (doc.exists && doc.data() != null) {
        return Right(UserModel.fromJson(doc.data() as Map<String, dynamic>, docId: doc.id));
      }
      return const Left('لم يتم العثور على بيانات السائق');
    } catch (e) {
      return Left('فشل جلب بيانات السائق: $e');
    }
  }

  Stream<List<OrderModel>> streamDriverOrders(String driverId) {
    return _driverApi.streamDriverOrders(driverId).map((snapshot) => snapshot.docs
        .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>, docId: doc.id))
        .toList());
  }

  Future<Either<String, void>> acceptShipment(String shipmentId) async {
    try {
      await _driverApi.updateShipmentStatus(shipmentId, 'Accepted');
      return const Right(null);
    } catch (e) {
      return Left('فشل قبول الشحنة: $e');
    }
  }

  Future<Either<String, void>> rejectShipment(String shipmentId) async {
    try {
      await _driverApi.updateShipmentStatus(shipmentId, 'Cancelled');
      return const Right(null);
    } catch (e) {
      return Left('فشل رفض الشحنة: $e');
    }
  }

  Future<Either<String, void>> updateShipmentStatus(String shipmentId, String status) async {
    try {
      await _driverApi.updateShipmentStatus(shipmentId, status);
      return const Right(null);
    } catch (e) {
      return Left('فشل تحديث حالة الشحنة: $e');
    }
  }
}
