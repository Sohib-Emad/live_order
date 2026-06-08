import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:live_order/core/di/di.dart';
import 'package:live_order/core/utils/animated_snack_dialog.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/features/admin/logic/cubit/admin_cubit.dart';
import 'package:live_order/features/admin/ui/widget/admin_stats_card.dart';
import 'package:live_order/features/admin/ui/widget/admin_pending_drivers.dart';
import 'package:live_order/features/admin/ui/widget/admin_user_management.dart';
import 'package:live_order/features/admin/ui/widget/admin_orders_monitor.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AdminCubit>()..initAdminDashboard(),
      child: const AdminDashboardBody(),
    );
  }
}

class AdminDashboardBody extends StatefulWidget {
  const AdminDashboardBody({super.key});

  @override
  State<AdminDashboardBody> createState() => _AdminDashboardBodyState();
}

class _AdminDashboardBodyState extends State<AdminDashboardBody> {
  int _currentIndex = 0;

  // State for filtering orders by a specific user (client/driver)
  String? _selectedUserUidFilter;
  String? _selectedUserNameFilter;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppDesign.surface,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'لوحة تحكم المشرف العام',
            style: AppDesign.heading(
              fontSize: 18.sp,
              color: AppDesign.textPrimary,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppDesign.primary),
              tooltip: 'تسجيل الخروج',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => Directionality(
                    textDirection: TextDirection.rtl,
                    child: AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      title: Text(
                        'تسجيل الخروج',
                        style: AppDesign.heading(
                          color: AppDesign.textPrimary,
                          fontSize: 16.sp,
                        ),
                      ),
                      content: Text(
                        'هل أنت متأكد من رغبتك في تسجيل الخروج من لوحة التحكم؟',
                        style: AppDesign.body(
                          color: AppDesign.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'إلغاء',
                            style: AppDesign.body(
                              color: AppDesign.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppDesign.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            'خروج',
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

                if (confirm == true) {
                  await SupabaseService.instance.client.auth.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.loginScreen,
                      (route) => false,
                    );
                  }
                }
              },
            ),
          ],
        ),
        body: SafeArea(
          child: BlocConsumer<AdminCubit, AdminState>(
            listener: (context, state) {
              if (state is AdminActionSuccess) {
                SystemSound.play(SystemSoundType.click);
                showAnimatedSnackDialog(
                  context,
                  message: state.message,
                  type: AnimatedSnackBarType.success,
                );
              }
              if (state is AdminError) {
                SystemSound.play(SystemSoundType.alert);
                showAnimatedSnackDialog(
                  context,
                  message: state.message,
                  type: AnimatedSnackBarType.error,
                );
              }
            },
            buildWhen: (previous, current) =>
                current is AdminLoaded || current is AdminLoading,
            builder: (context, state) {
              if (state is AdminLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppDesign.primary,
                    ),
                  ),
                );
              }

              if (state is AdminLoaded) {
                final users = state.users;
                final orders = state.orders;

                final totalUsers = users.length;
                final totalDrivers = users
                    .where((u) => u.role == 'driver')
                    .length;
                final pendingDrivers = users
                    .where(
                      (u) => u.role == 'driver' && u.driverStatus == 'pending',
                    )
                    .toList();
                final totalOrders = orders.length;

                return Column(
                  children: [
                    // Active filters banner if filtering by a specific user
                    if (_selectedUserUidFilter != null && _currentIndex == 3)
                      Container(
                        color: AppDesign.primary.withValues(alpha: 0.1),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.filter_list_rounded,
                              color: AppDesign.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'تصفية الشحنات للمستخدم: ${_selectedUserNameFilter ?? _selectedUserUidFilter}',
                                style: AppDesign.body(
                                  color: AppDesign.textPrimary,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedUserUidFilter = null;
                                  _selectedUserNameFilter = null;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: const BoxDecoration(
                                  color: AppDesign.border,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: AppDesign.textPrimary,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    Expanded(
                      child: IndexedStack(
                        index: _currentIndex,
                        children: [
                          _buildHomeTab(
                            totalUsers: totalUsers,
                            totalDrivers: totalDrivers,
                            pendingDriversCount: pendingDrivers.length,
                            totalOrders: totalOrders,
                          ),
                          AdminPendingDrivers(pendingList: pendingDrivers),
                          AdminUserManagement(
                            usersList: users,
                            onViewOrders: (uid, name) {
                              setState(() {
                                _selectedUserUidFilter = uid;
                                _selectedUserNameFilter = name;
                                _currentIndex = 3;
                              });
                            },
                          ),
                          AdminOrdersMonitor(
                            ordersList: orders,
                            initialUserUidFilter: _selectedUserUidFilter,
                            initialUserNameFilter: _selectedUserNameFilter,
                            onClearUserFilter: () {
                              setState(() {
                                _selectedUserUidFilter = null;
                                _selectedUserNameFilter = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppDesign.primary),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: BlocBuilder<AdminCubit, AdminState>(
          builder: (context, state) {
            if (state is AdminLoaded) {
              return Container(
                margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(color: AppDesign.border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home_rounded, 'الرئيسية'),
                    _buildNavItem(
                      1,
                      Icons.pending_actions_rounded,
                      'طلبات التفعيل',
                    ),
                    _buildNavItem(
                      2,
                      Icons.people_alt_rounded,
                      'إدارة الحسابات',
                    ),
                    _buildNavItem(
                      3,
                      Icons.assignment_rounded,
                      'مراقبة الشحنات',
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppDesign.primary : AppDesign.textSecondary,
                size: 22.sp,
              ),
              const HeightSpace(4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppDesign.body(
                  fontSize: 10.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppDesign.primary
                      : AppDesign.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab({
    required int totalUsers,
    required int totalDrivers,
    required int pendingDriversCount,
    required int totalOrders,
  }) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcoming Header (Clean, Simple & Minimalist)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أهلاً بك، المشرف العام ',
                  style: AppDesign.heading(
                    fontSize: 20.sp,
                    color: AppDesign.textPrimary,
                  ),
                ),
                const HeightSpace(4),
                Text(
                  'مرحباً بك في لوحة تحكم نظام Live Order. يمكنك إدارة الحسابات وتفعيل السائقين ومراقبة الشحنات.',
                  style: AppDesign.body(
                    fontSize: 12.sp,
                    color: AppDesign.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const HeightSpace(16),

          // Stats Section Title
          Text(
            'إحصائيات النظام العام',
            style: AppDesign.heading(
              fontSize: 15.sp,
              color: AppDesign.textPrimary,
            ),
          ),
          const HeightSpace(10),

          // Grid-like rows of Stats Cards
          Row(
            children: [
              AdminStatsCard(
                label: 'إجمالي الحسابات',
                value: totalUsers.toString(),
                icon: Icons.people_alt_rounded,
                color: Colors.blueAccent,
              ),
              const WidthSpace(10),
              AdminStatsCard(
                label: 'إجمالي السائقين',
                value: totalDrivers.toString(),
                icon: Icons.local_shipping_rounded,
                color: AppDesign.primary,
              ),
            ],
          ),
          const HeightSpace(10),
          Row(
            children: [
              AdminStatsCard(
                label: 'طلبات تفعيل معلقة',
                value: pendingDriversCount.toString(),
                icon: Icons.pending_actions_rounded,
                color: Colors.amber,
              ),
              const WidthSpace(10),
              AdminStatsCard(
                label: 'إجمالي الشحنات',
                value: totalOrders.toString(),
                icon: Icons.assignment_rounded,
                color: const Color(0xFF16A34A),
              ),
            ],
          ),
          const HeightSpace(24),

          // Quick Actions / Shortcuts Title
          Text(
            'الوصول السريع',
            style: AppDesign.heading(
              fontSize: 15.sp,
              color: AppDesign.textPrimary,
            ),
          ),
          const HeightSpace(10),

          // Shortcut Navigation Cards/Buttons
          _buildShortcutCard(
            title: 'إدارة طلبات تفعيل السائقين',
            subtitle: 'مراجعة وتفعيل السائقين الجدد المنضمين للنظام',
            icon: Icons.pending_actions_rounded,
            color: Colors.amber,
            onTap: () => setState(() => _currentIndex = 1),
          ),
          const HeightSpace(10),
          _buildShortcutCard(
            title: 'إدارة جميع الحسابات',
            subtitle: 'التحكم بالعملاء، السائقين، والمسؤولين وتعديل صلاحياتهم',
            icon: Icons.people_alt_rounded,
            color: Colors.blueAccent,
            onTap: () => setState(() => _currentIndex = 2),
          ),
          const HeightSpace(10),
          _buildShortcutCard(
            title: 'مراقبة وتتبع الشحنات',
            subtitle: 'متابعة تفاصيل الشحنات وحالاتها ومسارات التوصيل',
            icon: Icons.assignment_rounded,
            color: const Color(0xFF16A34A),
            onTap: () => setState(() => _currentIndex = 3),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppDesign.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20.sp),
                const WidthSpace(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppDesign.heading(
                          fontSize: 13.sp,
                          color: AppDesign.textPrimary,
                        ),
                      ),
                      const HeightSpace(2),
                      Text(
                        subtitle,
                        style: AppDesign.body(
                          fontSize: 10.sp,
                          color: AppDesign.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppDesign.textSecondary,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
