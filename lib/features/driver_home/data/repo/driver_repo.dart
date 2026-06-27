import 'package:dartz/dartz.dart';
import 'package:live_order/features/driver_home/data/api/driver_api.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/core/models/shipment.dart';

class DriverRepo {
  final DriverApi _driverApi;

  DriverRepo(this._driverApi);

  String? get currentUid => _driverApi.currentUid;

  Future<Either<String, void>> registerDriver(UserProfile driver) async {
    try {
      await _driverApi.registerDriver(driver.toJson(), driver.uid);
      return const Right(null);
    } catch (e) {
      return Left('فشل تسجيل حساب السائق: $e');
    }
  }

  Future<Either<String, UserProfile>> getDriverDetails(String uid) async {
    try {
      final data = await _driverApi.getDriverDetails(uid);
      if (data != null && data['uid'] != null) {
        return Right(UserProfile.fromJson({...data, 'uid': uid}));
      }
      return const Left('لم يتم العثور على بيانات السائق');
    } catch (e) {
      return Left('فشل جلب بيانات السائق: $e');
    }
  }

  Stream<List<Shipment>> streamDriverOrders(String driverId) {
    return _driverApi.streamDriverOrders(driverId).map((list) => list
        .map((data) => Shipment.fromJson({...data, 'id': data['id']}))
        .toList());
  }

  Stream<List<Map<String, dynamic>>> streamChatMessages(String chatId) {
    return _driverApi.streamChatMessages(chatId);
  }

  Future<Either<String, void>> updateDriverStatus(String uid, bool isAvailable) async {
    try {
      await _driverApi.updateDriverStatus(uid, isAvailable);
      return const Right(null);
    } catch (e) {
      return Left('فشل تحديث حالة السائق: $e');
    }
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
