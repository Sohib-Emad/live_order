import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/features/user/data/repo/user_repo.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository userRepository;

  UserCubit({required this.userRepository}) : super(const UserInitial());

  // الحصول على بيانات المستخدم
  Future<void> loadUserData(String userId) async {
    emit(const UserLoading());
    final result = await userRepository.getUserData(userId);
    result.fold(
      (error) => emit(UserError(error)),
      (data) => emit(UserDataLoaded(data)),
    );
  }

  // الحصول على الإحصائيات
  Future<void> loadUserStats(String userId) async {
    emit(const UserLoading());
    final result = await userRepository.getUserStats(userId);
    result.fold(
      (error) => emit(UserError(error)),
      (stats) => emit(UserStatsLoaded(stats)),
    );
  }

  // تحديث البيانات الشخصية
  Future<void> updatePersonalInfo(
    String userId,
    String name,
    String email,
  ) async {
    emit(const UserLoading());
    final result = await userRepository.updatePersonalInfo(userId, name, email);
    result.fold(
      (error) => emit(UserError(error)),
      (_) => emit(const UserDataUpdateSuccess('تم تحديث البيانات بنجاح!')),
    );
  }

  // تحديث الصورة الشخصية
  Future<void> updateProfileImage(String userId, String imageUrl) async {
    emit(const UserLoading());
    final result = await userRepository.updateProfileImage(userId, imageUrl);
    result.fold(
      (error) => emit(UserError(error)),
      (_) => emit(const UserProfileImageUpdateSuccess('تم تحديث الصورة الشخصية بنجاح!')),
    );
  }

  // تحديث بيانات الاتصال
  Future<void> updateContactInfo(
    String userId,
    String phone,
    String address,
  ) async {
    emit(const UserLoading());
    final result = await userRepository.updateContactInfo(userId, phone, address);
    result.fold(
      (error) => emit(UserError(error)),
      (_) => emit(const UserContactInfoUpdateSuccess('تم تحديث بيانات الاتصال بنجاح!')),
    );
  }

  // تحديث إعدادات الإشعارات
  Future<void> updateNotificationSettings(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    emit(const UserLoading());
    final result = await userRepository.updateNotificationSettings(userId, settings);
    result.fold(
      (error) => emit(UserError(error)),
      (_) => emit(const UserNotificationSettingsUpdateSuccess('تم تحديث الإعدادات بنجاح!')),
    );
  }

  // الحصول على سجل النشاط
  Future<void> loadUserActivity(String userId) async {
    emit(const UserLoading());
    final result = await userRepository.getUserActivity(userId);
    result.fold(
      (error) => emit(UserError(error)),
      (activity) => emit(UserActivityLoaded(activity)),
    );
  }

  // حذف الحساب
  Future<void> deleteAccount(String userId) async {
    emit(const UserLoading());
    final result = await userRepository.deleteAccount(userId);
    result.fold(
      (error) => emit(UserError(error)),
      (_) => emit(const UserAccountDeletedSuccess('تم حذف الحساب بنجاح!')),
    );
  }
}
