import 'package:dartz/dartz.dart';
import 'package:live_order/features/admin/data/api/admin_api.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/core/models/shipment.dart';

class AdminRepo {
  final AdminApi _adminApi;

  AdminRepo(this._adminApi);

  Stream<List<UserProfile>> streamAllUsers() {
    return _adminApi.streamAllUsers().map((list) => list
        .map((data) => UserProfile.fromJson({...data, 'uid': data['uid'] ?? data['id']}))
        .toList());
  }

  Stream<List<Shipment>> streamAllOrders() {
    return _adminApi.streamAllOrders().map((list) => list
        .map((data) => Shipment.fromJson({...data, 'id': data['id']}))
        .toList());
  }

  Future<Either<String, void>> approveDriver(String driverId) async {
    try {
      await _adminApi.updateDriverStatus(driverId, 'active');
      return const Right(null);
    } catch (e) {
      return Left('فشل تفعيل السائق: $e');
    }
  }

  Future<Either<String, void>> updateDriverBlockStatus(String driverId, String status) async {
    try {
      await _adminApi.updateDriverStatus(driverId, status);
      return const Right(null);
    } catch (e) {
      return Left('فشل تحديث حالة السائق: $e');
    }
  }
}
