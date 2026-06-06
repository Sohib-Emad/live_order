import 'package:dartz/dartz.dart';
import 'package:live_order/features/user_account/data/api/user_api.dart';

class UserRepository {
  final UserApi userApi;
  UserRepository({required this.userApi});

  Future<Either<String, Map<String, dynamic>>> getUserData(String userId) async {
    try {
      final data = await userApi.getUserData(userId);
      return Right(data);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, void>> updatePersonalInfo(
    String userId,
    String name,
    String email,
  ) async {
    try {
      await userApi.updateUserData(userId, {
        'name': name,
        'email': email,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, void>> updateProfileImage(String userId, String imageUrl) async {
    try {
      await userApi.updateProfileImage(userId, imageUrl);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Map<String, dynamic>>> getUserStats(String userId) async {
    try {
      final stats = await userApi.getUserStats(userId);
      return Right(stats);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, void>> updateContactInfo(
    String userId,
    String phone,
    String address,
  ) async {
    try {
      await userApi.updateContactInfo(userId, phone, address);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, void>> deleteAccount(String userId) async {
    try {
      await userApi.deleteAccount(userId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<Map<String, dynamic>>>> getUserActivity(String userId) async {
    try {
      final activity = await userApi.getUserActivity(userId);
      return Right(activity);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, void>> updateNotificationSettings(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    try {
      await userApi.updateNotificationSettings(userId, settings);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
