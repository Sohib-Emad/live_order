import 'package:dartz/dartz.dart';
import 'package:live_order/features/admin/data/api/admin_api.dart';
import 'package:live_order/features/add_order/models/user_model.dart';
import 'package:live_order/features/add_order/models/order_model.dart';

class AdminRepo {
  final AdminApi _adminApi;

  AdminRepo(this._adminApi);

  Stream<List<UserModel>> streamAllUsers() {
    return _adminApi.streamAllUsers().map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>, docId: doc.id))
        .toList());
  }

  Stream<List<OrderModel>> streamAllOrders() {
    return _adminApi.streamAllOrders().map((snapshot) => snapshot.docs
        .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>, docId: doc.id))
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
