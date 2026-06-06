import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/features/add_order/models/order_model.dart';
import 'package:live_order/features/add_order/models/user_model.dart';
import 'package:live_order/features/home/logic/home_logic_helper.dart';

class ClientHomeTab extends StatelessWidget {
  final UserModel clientUser;
  final List<OrderModel> activeList;
  final int unreadNotificationsCount;
  final int totalNotificationsCount;
  final VoidCallback onNotificationTap;

  const ClientHomeTab({
    super.key,
    required this.clientUser,
    required this.activeList,
    required this.unreadNotificationsCount,
    required this.totalNotificationsCount,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E2028), Color(0xFF111318)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مرحباً بك',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          clientUser.name,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: onNotificationTap,
                          child: Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                              ),
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_rounded,
                                  color: Colors.grey[400],
                                  size: 19.sp,
                                ),
                                if (unreadNotificationsCount > 0)
                                  Positioned(
                                    right: 6.w,
                                    top: 6.h,
                                    child: Container(
                                      width: 8.w,
                                      height: 8.w,
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Text(
                              clientUser.name.isNotEmpty
                                  ? clientUser.name[0].toUpperCase()
                                  : 'ع',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // ── Hero CTA Card ─────────────────────────────────────────────
                GestureDetector(
                  onTap: () => context.pushNamed(AppRoutes.addOrderScreen),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB300).withOpacity(0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'إرسال شحنة جديدة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'ابدأ رحلة توصيل شحنتك الآن',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11.sp,
                                ),
                              ),
                              SizedBox(height: 14.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 18.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                                child: Text(
                                  'ابدأ الآن',
                                  style: TextStyle(
                                    color: const Color(0xFFFF8F00),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.local_shipping_rounded,
                          color: Colors.white.withOpacity(0.25),
                          size: 80.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // ── Recent Active Shipments ─────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'أحدث الشحنات',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          activeList.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.h),
                    child: Column(
                      children: [
                        Container(
                          width: 70.w,
                          height: 70.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.inbox_rounded,
                            size: 32.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          'لا توجد شحنات نشطة حالياً',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        GestureDetector(
                          onTap: () =>
                              context.pushNamed(AppRoutes.addOrderScreen),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                              ),
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            child: Text(
                              'أرسل شحنتك الأولى',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: activeList.length > 3 ? 3 : activeList.length,
                  itemBuilder: (context, index) {
                    return _buildShipmentCard(context, activeList[index]);
                  },
                ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildShipmentCard(BuildContext context, OrderModel order) {
    final statusColor = HomeLogicHelper.getStatusColor(order.orderStatus);
    final statusLabel = HomeLogicHelper.getStatusLabel(order.orderStatus);
    return GestureDetector(
      onTap: () => context.pushNamed(AppRoutes.orderDetailsScreen, extra: order),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2028),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB300).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: const Icon(Icons.shopping_bag_rounded, color: Color(0xFFFFB300), size: 20),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderName,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    order.orderDate.split('T').first,
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
