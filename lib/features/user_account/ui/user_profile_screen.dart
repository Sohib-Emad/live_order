import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/services/supabase_service.dart';
import 'package:live_order/core/di/di.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/core/utils/animated_snack_dialog.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/features/user_account/logic/cubit/user_cubit.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/features/user_account/ui/widget/profile_header.dart';
import 'package:live_order/features/user_account/ui/widget/profile_stats.dart';
import 'package:live_order/features/user_account/ui/widget/profile_info_row.dart';
import 'package:live_order/features/user_account/ui/widget/profile_setting_row.dart';
import 'package:live_order/features/user_account/ui/widget/profile_action_button.dart';
import 'package:live_order/features/user_account/ui/widget/edit_profile_dialog.dart';
import 'package:live_order/features/user_account/ui/widget/notification_settings_dialog.dart';
import 'package:live_order/features/user_account/ui/widget/support_info_dialog.dart';
import 'package:live_order/features/user_account/ui/widget/logout_confirm_dialog.dart';

class UserProfileScreen extends StatefulWidget {
  final UserProfile user;

  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late UserCubit _userCubit;

  Map<String, dynamic> _stats = {
    'completed_orders': 0,
    'active_orders': 0,
    'total_spent': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _userCubit = getIt<UserCubit>();
    _userCubit.loadUserData(widget.user.uid);
    _userCubit.loadUserStats(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<UserCubit, UserState>(
          bloc: _userCubit,
          listener: (context, state) {
            if (state is UserStatsLoaded) {
              setState(() {
                _stats = state.stats;
              });
            }
            if (state is UserActivityLoaded) {
              _showActivityDialog(context, state.activity);
            }
            if (state is UserNotificationSettingsUpdateSuccess) {
              showAnimatedSnackDialog(
                context,
                message: state.message,
                type: AnimatedSnackBarType.success,
              );
            }
            if (state is UserDataUpdateSuccess) {
              showAnimatedSnackDialog(
                context,
                message: state.message,
                type: AnimatedSnackBarType.success,
              );
              _userCubit.loadUserStats(widget.user.uid);
            }
            if (state is UserError) {
              showAnimatedSnackDialog(
                context,
                message: state.message,
                type: AnimatedSnackBarType.error,
              );
            }
          },
          builder: (context, state) {
            return Scaffold(
              backgroundColor: AppDesign.surface,
              body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    ProfileHeader(
                      name: widget.user.name,
                      email: widget.user.email,
                      role: widget.user.role,
                    ),
                    ProfileStats(
                      stats: _stats,
                      role: widget.user.role,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'معلومات الحساب',
                            style: AppDesign.heading(fontSize: 14.0),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: AppDesign.border),
                            ),
                            child: Column(
                              children: [
                                ProfileInfoRow(
                                  label: 'اسم المستخدم',
                                  value: widget.user.name,
                                  icon: Icons.person_outline_rounded,
                                ),
                                const Divider(
                                  color: AppDesign.border,
                                  height: 24,
                                ),
                                ProfileInfoRow(
                                  label: 'البريد الإلكتروني',
                                  value: widget.user.email,
                                  icon: Icons.email_outlined,
                                ),
                                const Divider(
                                  color: AppDesign.border,
                                  height: 24,
                                ),
                                ProfileInfoRow(
                                  label: 'نوع الحساب',
                                  value: _roleLabel(widget.user.role),
                                  icon: Icons.account_circle_outlined,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24.h),
                          Text(
                            'الإعدادات والتحكم',
                            style: AppDesign.heading(fontSize: 14.0),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: AppDesign.border),
                            ),
                            child: Column(
                              children: [
                                ProfileSettingRow(
                                  icon: Icons.edit_outlined,
                                  label: 'تعديل البيانات الشخصية',
                                  onTap: () => _showEditDialog(context),
                                ),
                                const Divider(
                                  color: AppDesign.border,
                                  height: 1,
                                ),
                                ProfileSettingRow(
                                  icon: Icons.lock_outline_rounded,
                                  label: 'تغيير كلمة المرور',
                                  onTap: () => _showChangePasswordDialog(context),
                                ),
                                const Divider(
                                  color: AppDesign.border,
                                  height: 1,
                                ),
                                ProfileSettingRow(
                                  icon: Icons.notifications_none_rounded,
                                  label: 'إعدادات الإشعارات',
                                  onTap: () => _showNotificationSettings(context),
                                ),
                                const Divider(
                                  color: AppDesign.border,
                                  height: 1,
                                ),
                                ProfileSettingRow(
                                  icon: Icons.history_rounded,
                                  label: 'سجل النشاط والطلبات',
                                  onTap: () => _showActivityHistory(context),
                                ),
                                const Divider(
                                  color: AppDesign.border,
                                  height: 1,
                                ),
                                ProfileSettingRow(
                                  icon: Icons.help_outline_rounded,
                                  label: 'الدعم الفني والمساعدة',
                                  onTap: () => _showSupportInfo(context),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24.h),
                          ProfileActionButton(
                            icon: Icons.logout_rounded,
                            label: 'تسجيل الخروج',
                            backgroundColor: Colors.red.shade50,
                            borderColor: Colors.red.shade100,
                            iconColor: Colors.red.shade700,
                            textColor: Colors.red.shade700,
                            onTap: () => _showLogoutConfirmDialog(context),
                          ),

                          SizedBox(height: 12.h),
                          ProfileActionButton(
                            icon: Icons.delete_forever_rounded,
                            label: 'حذف الحساب نهائياً',
                            backgroundColor: Colors.grey.shade100,
                            borderColor: Colors.grey.shade200,
                            iconColor: Colors.grey.shade600,
                            textColor: Colors.grey.shade600,
                            onTap: () {
                              showAnimatedSnackDialog(
                                context,
                                message: 'هذه الميزة محمية. يرجى التواصل مع الدعم الفني للمساعدة.',
                                type: AnimatedSnackBarType.warning,
                              );
                            },
                          ),

                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => EditProfileDialog(
        initialName: widget.user.name,
        initialEmail: widget.user.email,
        onSave: (name, email) {
          _userCubit.updatePersonalInfo(widget.user.uid, name, email);
        },
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final emailController = TextEditingController(text: widget.user.email);
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'تغيير كلمة المرور',
            style: AppDesign.heading(fontSize: 16.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'سيتم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني.',
                style: AppDesign.body(
                  color: AppDesign.textSecondary,
                  fontSize: 13.0,
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesign.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await SupabaseService.instance.client.auth
                      .resetPasswordForEmail(emailController.text.trim());
                  if (!mounted) return;
                  showAnimatedSnackDialog(
                    context,
                    message: 'تم إرسال رابط تغيير كلمة المرور إلى بريدك الإلكتروني!',
                    type: AnimatedSnackBarType.success,
                  );
                } catch (e) {
                  if (!mounted) return;
                  showAnimatedSnackDialog(
                    context,
                    message: 'فشل إرسال الرابط: $e',
                    type: AnimatedSnackBarType.error,
                  );
                }
              },
              child: const Text('إرسال الرابط'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => NotificationSettingsDialog(
        userCubit: _userCubit,
        userId: widget.user.uid,
      ),
    );
  }

  void _showActivityHistory(BuildContext context) {
    _userCubit.loadUserActivity(widget.user.uid);
  }

  void _showSupportInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const SupportInfoDialog(),
    );
  }

  void _showActivityDialog(BuildContext context, List<Map<String, dynamic>> activity) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'سجل النشاط والطلبات',
            style: AppDesign.heading(fontSize: 16.0),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: activity.isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Center(
                      child: Text(
                        'لا يوجد نشاط مسجل بعد.',
                        style: AppDesign.body(
                          color: AppDesign.textSecondary,
                          fontSize: 13.0,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: activity.length,
                    separatorBuilder: (_, _) => const Divider(
                      color: AppDesign.border,
                      height: 16,
                    ),
                    itemBuilder: (context, index) {
                      final item = activity[index];
                      return Row(
                        children: [
                          Icon(
                            _activityIcon(item['action'] ?? ''),
                            size: 20.sp,
                            color: AppDesign.primary,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['description'] ?? item['action'] ?? '',
                                  style: AppDesign.body(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13.0,
                                  ),
                                ),
                                if (item['timestamp'] != null)
                                  Text(
                                    _formatTimestamp(item['timestamp']),
                                    style: AppDesign.body(
                                      color: AppDesign.textSecondary,
                                      fontSize: 11.0,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesign.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 10.h,
                ),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'إغلاق',
                style: AppDesign.body(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _activityIcon(String action) {
    switch (action) {
      case 'order_created':
        return Icons.shopping_cart_outlined;
      case 'order_completed':
        return Icons.check_circle_outline;
      case 'order_cancelled':
        return Icons.cancel_outlined;
      case 'login':
        return Icons.login_rounded;
      case 'profile_updated':
        return Icons.edit_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  String _formatTimestamp(dynamic ts) {
    if (ts == null) return '';
    final dt = ts is String ? DateTime.tryParse(ts) : null;
    if (dt == null) return ts.toString();
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'driver':
        return 'سائق';
      case 'admin':
        return 'مدير';
      default:
        return 'عميل';
    }
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => LogoutConfirmDialog(
        onLogout: () async {
          await SupabaseService.instance.client.auth.signOut();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.loginScreen,
              (route) => false,
            );
          }
        },
      ),
    );
  }
}
