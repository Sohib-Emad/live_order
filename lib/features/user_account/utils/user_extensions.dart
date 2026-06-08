import 'package:flutter/material.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/core/services/supabase_service.dart';

extension UserExtensions on UserProfile {
  bool get isRegularClient => role == 'client';

  String get nameInitials {
    if (name.isEmpty) return 'ع';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  bool get isAccountActive =>       email.isNotEmpty && uid.isNotEmpty;

  int get membershipDays {
    return DateTime.now().difference(createdAt).inDays;
  }

  Future<void> navigateToProfile(BuildContext context) {
    return Navigator.pushNamed(context, 
      AppRoutes.userProfileScreen,
      arguments: this,
    );
  }

  Map<String, dynamic> toProfileJson() {
    return {
      'user_id': uid,
      'name': name,
      'email': email,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'name_initials': nameInitials,
    };
  }
}

extension UserAuthExtensions on BuildContext {
  String? getCurrentUserId() => SupabaseService.instance.client.auth.currentUser?.id;

  String? getCurrentUserEmail() => SupabaseService.instance.client.auth.currentUser?.email;

  Future<void> signOutAndNavigate() async {
    await SupabaseService.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(this, AppRoutes.loginScreen, (route) => false);
    }
  }
}
