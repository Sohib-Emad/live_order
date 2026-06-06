part of 'user_cubit.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

// الحالة الأولية
class UserInitial extends UserState {
  const UserInitial();
}

// جاري التحميل
class UserLoading extends UserState {
  const UserLoading();
}

// تم جلب البيانات بنجاح
class UserDataLoaded extends UserState {
  final Map<String, dynamic> userData;

  const UserDataLoaded(this.userData);

  @override
  List<Object?> get props => [userData];
}

// تم جلب الإحصائيات بنجاح
class UserStatsLoaded extends UserState {
  final Map<String, dynamic> stats;

  const UserStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

// تم تحديث البيانات بنجاح
class UserDataUpdateSuccess extends UserState {
  final String message;

  const UserDataUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// تم تحديث الصورة الشخصية بنجاح
class UserProfileImageUpdateSuccess extends UserState {
  final String message;

  const UserProfileImageUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// تم تحديث بيانات الاتصال بنجاح
class UserContactInfoUpdateSuccess extends UserState {
  final String message;

  const UserContactInfoUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// تم تحديث إعدادات الإشعارات بنجاح
class UserNotificationSettingsUpdateSuccess extends UserState {
  final String message;

  const UserNotificationSettingsUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// تم جلب سجل النشاط بنجاح
class UserActivityLoaded extends UserState {
  final List<Map<String, dynamic>> activity;

  const UserActivityLoaded(this.activity);

  @override
  List<Object?> get props => [activity];
}

// حدث خطأ
class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}

// تم حذف الحساب بنجاح
class UserAccountDeletedSuccess extends UserState {
  final String message;

  const UserAccountDeletedSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
