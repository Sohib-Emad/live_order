import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:live_order/features/profile/data/api/profile_api.dart';

class ProfileRepo {
  final ProfileApi _profileApi;

  ProfileRepo(this._profileApi);

  // Stream current user details from Firestore
  Stream<DocumentSnapshot> streamUserDetails(String uid) {
    return _profileApi.streamUserDetails(uid);
  }

  // Update user saved address (Home/Work) in Firestore
  Future<Either<String, void>> updateUserAddress(String userId, String key, String newAddress) async {
    try {
      await _profileApi.updateUserAddress(userId, key, newAddress);
      return const Right(null);
    } catch (e) {
      return Left('فشل تحديث العنوان: $e');
    }
  }

  // Update driver vehicle info in Firestore
  Future<Either<String, void>> updateDriverVehicleInfo(String userId, String vehicleInfo) async {
    try {
      await _profileApi.updateDriverVehicleInfo(userId, vehicleInfo);
      return const Right(null);
    } catch (e) {
      return Left('فشل تحديث بيانات المركبة: $e');
    }
  }
}
