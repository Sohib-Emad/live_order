import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:live_order/core/di/di.dart';
import 'package:live_order/core/utils/animated_snack_dialog.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/features/add_order/models/order_model.dart';
import 'package:live_order/features/add_order/models/user_model.dart';
import 'package:live_order/features/admin/logic/cubit/admin_cubit.dart';

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

class _AdminDashboardBodyState extends State<AdminDashboardBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E1E1E),
          elevation: 0,
          title: Text(
            'لوحة تحكم المدير العام',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFFFB300)),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  context.go('/loginScreen');
                }
              },
            ),
          ],
        ),
        body: SafeArea(
          child: BlocConsumer<AdminCubit, AdminState>(
            listener: (context, state) {
              if (state is AdminActionSuccess) {
                showAnimatedSnackDialog(
                  context,
                  message: state.message,
                  type: AnimatedSnackBarType.success,
                );
              }
              if (state is AdminError) {
                showAnimatedSnackDialog(
                  context,
                  message: state.message,
                  type: AnimatedSnackBarType.error,
                );
              }
            },
            buildWhen: (previous, current) => current is AdminLoaded || current is AdminLoading,
            builder: (context, state) {
              if (state is AdminLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
                  ),
                );
              }

              if (state is AdminLoaded) {
                final users = state.users;
                final orders = state.orders;

                final totalUsers = users.length;
                final totalDrivers = users.where((u) => u.role == 'driver').length;
                final pendingDrivers = users
                    .where((u) => u.role == 'driver' && u.driverStatus == 'pending')
                    .toList();
                final totalOrders = orders.length;

                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.w),
                      color: const Color(0xFF1E1E1E),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildStatCard(
                                label: 'إجمالي الحسابات',
                                value: totalUsers.toString(),
                                icon: Icons.people_rounded,
                                color: Colors.blue,
                              ),
                              const WidthSpace(12),
                              _buildStatCard(
                                label: 'إجمالي السائقين',
                                value: totalDrivers.toString(),
                                icon: Icons.local_shipping_rounded,
                                color: const Color(0xFFFFB300),
                              ),
                            ],
                          ),
                          const HeightSpace(12),
                          Row(
                            children: [
                              _buildStatCard(
                                label: 'سائقين قيد الانتظار',
                                value: pendingDrivers.length.toString(),
                                icon: Icons.hourglass_empty_rounded,
                                color: Colors.orange,
                              ),
                              const WidthSpace(12),
                              _buildStatCard(
                                label: 'إجمالي الشحنات',
                                value: totalOrders.toString(),
                                icon: Icons.receipt_long_rounded,
                                color: const Color(0xFF4CAF50),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: const Color(0xFF1E1E1E),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: const Color(0xFFFFB300),
                        unselectedLabelColor: Colors.grey[400],
                        indicatorColor: const Color(0xFFFFB300),
                        indicatorWeight: 3.h,
                        tabs: const [
                          Tab(text: 'طلبات التفعيل'),
                          Tab(text: 'إدارة الحسابات'),
                          Tab(text: 'مراقبة الشحنات'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPendingDriversTab(context, pendingDrivers),
                          _buildUsersManagementTab(context, users),
                          _buildOrdersMonitorTab(orders),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.04), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 18.sp),
            ),
            const WidthSpace(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(fontSize: 9.5.sp, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingDriversTab(BuildContext context, List<UserModel> pendingList) {
    if (pendingList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 56.sp,
              color: Colors.grey[700],
            ),
            const HeightSpace(12),
            Text(
              'كل طلبات السائقين مفعلة! لا توجد طلبات معلقة.',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(20.w),
      itemCount: pendingList.length,
      itemBuilder: (context, index) {
        final driver = pendingList[index];
        return Container(
          margin: EdgeInsets.only(bottom: 14.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const HeightSpace(4),
                    Text(
                      driver.email,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[400],
                      ),
                    ),
                    const HeightSpace(8),
                    Text(
                      'المركبة: ${driver.vehicleInfo ?? "سيارة نقل"}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFFFFB300),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (driver.nationalId != null || driver.licenseNumber != null) ...[
                      const HeightSpace(4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (driver.nationalId != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.credit_card_rounded,
                                  size: 10.sp,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'الرقم القومي: ${driver.nationalId}',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.grey[400],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          if (driver.licenseNumber != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.assignment_ind_rounded,
                                  size: 10.sp,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'الرخصة: ${driver.licenseNumber}',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.grey[400],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB300),
                  foregroundColor: const Color(0xFF121212),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                ),
                onPressed: () => context.read<AdminCubit>().approveDriver(driver.userId),
                icon: const Icon(Icons.check_rounded, size: 16),
                label: Text(
                  'تفعيل الحساب',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsersManagementTab(BuildContext context, List<UserModel> usersList) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(20.w),
      itemCount: usersList.length,
      itemBuilder: (context, index) {
        final user = usersList[index];
        final isBlocked = user.driverStatus == 'blocked';

        return Container(
          margin: EdgeInsets.only(bottom: 14.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const WidthSpace(8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: user.role == 'admin'
                                ? Colors.red.withOpacity(0.2)
                                : user.role == 'driver'
                                    ? const Color(0xFFFFB300).withOpacity(0.2)
                                    : Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            user.role == 'admin'
                                ? 'مدير'
                                : user.role == 'driver'
                                    ? 'سائق'
                                    : 'عميل',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: user.role == 'admin'
                                  ? Colors.red
                                  : user.role == 'driver'
                                      ? const Color(0xFFFFB300)
                                      : Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const HeightSpace(4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: Colors.grey[400],
                      ),
                    ),
                    if (user.role == 'driver') ...[
                      const HeightSpace(6),
                      Text(
                        'المركبة: ${user.vehicleInfo ?? "سيارة نقل"}',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: const Color(0xFFFFB300),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user.nationalId != null || user.licenseNumber != null) ...[
                        const HeightSpace(4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (user.nationalId != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.credit_card_rounded,
                                    size: 10.sp,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      'بطاقة: ${user.nationalId}',
                                      style: TextStyle(
                                        fontSize: 9.5.sp,
                                        color: Colors.grey[400],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            if (user.licenseNumber != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.assignment_ind_rounded,
                                    size: 10.sp,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      'رخصة: ${user.licenseNumber}',
                                      style: TextStyle(
                                        fontSize: 9.5.sp,
                                        color: Colors.grey[400],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              if (user.role != 'admin')
                TextButton.icon(
                  onPressed: () => context.read<AdminCubit>().toggleUserBlock(user),
                  icon: Icon(
                    isBlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                    color: isBlocked ? const Color(0xFF4CAF50) : Colors.redAccent,
                    size: 16.sp,
                  ),
                  label: Text(
                    isBlocked ? 'تفعيل' : 'حظر الحساب',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isBlocked ? const Color(0xFF4CAF50) : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrdersMonitorTab(List<OrderModel> ordersList) {
    if (ordersList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 56.sp,
              color: Colors.grey[700],
            ),
            const HeightSpace(12),
            Text(
              'لا توجد شحنات مسجلة في النظام حتى الآن.',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(20.w),
      itemCount: ordersList.length,
      itemBuilder: (context, index) {
        final order = ordersList[index];

        return Container(
          margin: EdgeInsets.only(bottom: 14.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderName,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: order.orderStatus == 'Delivered'
                          ? Colors.green.withOpacity(0.12)
                          : const Color(0xFFFFB300).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Text(
                      order.orderStatus,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        color: order.orderStatus == 'Delivered' ? Colors.green : const Color(0xFFFFB300),
                      ),
                    ),
                  ),
                ],
              ),
              const HeightSpace(8),
              Divider(color: Colors.white.withOpacity(0.05)),
              const HeightSpace(6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المرسل UID: ${order.orderUserId.length > 6 ? "${order.orderUserId.substring(0, 6)}..." : order.orderUserId}',
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey[400]),
                  ),
                  Text(
                    'السائق UID: ${order.driverId.isNotEmpty ? (order.driverId.length > 6 ? "${order.driverId.substring(0, 6)}..." : order.driverId) : "لم يحدد بعد"}',
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey[400]),
                  ),
                ],
              ),
              const HeightSpace(6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الحجم: ${order.orderSize == "small" ? "صغير" : order.orderSize == "medium" ? "متوسط" : "كبير"}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: const Color(0xFFFFB300),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'التاريخ: ${order.orderDate.split('T').first}',
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey[400]),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
