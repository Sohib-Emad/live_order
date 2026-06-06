import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:live_order/features/add_order/models/user_model.dart';
import 'package:live_order/core/routing/app_routes.dart';

extension UserExtensions on UserModel {
  /// التحقق من أن المستخدم عميل عادي (لا يوجد أدوار خاصة)
  bool get isRegularClient => role == 'client';

  /// الحصول على اختصار اسم المستخدم
  String get nameInitials {
    if (name.isEmpty) return 'ع';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// التحقق من أن المستخدم يملك حساب فعال
  bool get isAccountActive => !email.isEmpty && userId.isNotEmpty;

  /// حساب مدة العضوية بالأيام
  int get membershipDays {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// التنقل إلى شاشة الملف الشخصي
  Future<void> navigateToProfile(BuildContext context) {
    return context.pushNamed(
      AppRoutes.userProfileScreen,
      extra: this,
    );
  }

  /// تحويل نموذج المستخدم إلى JSON
  Map<String, dynamic> toProfileJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'name_initials': nameInitials,
    };
  }
}

extension UserAuthExtensions on FirebaseAuth {
  /// الحصول على معرف المستخدم الحالي
  String? getCurrentUserId() => currentUser?.uid;

  /// التحقق من تسجيل دخول المستخدم
  bool get isUserLoggedIn => currentUser != null;

  /// الحصول على بريد المستخدم الحالي
  String? getCurrentUserEmail() => currentUser?.email;

  /// تسجيل الخروج والانتقال إلى صفحة تسجيل الدخول
  Future<void> signOutAndNavigate(BuildContext context) async {
    await signOut();
    if (context.mounted) {
      context.go(AppRoutes.loginScreen);
    }
  }
}
