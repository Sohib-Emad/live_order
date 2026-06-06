import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/features/add_order/models/user_model.dart';
import 'package:live_order/features/home/logic/cubit/home_cubit.dart';
import 'package:live_order/features/home/ui/widgets/client_home_tab.dart';
import 'package:live_order/features/home/ui/widgets/client_orders_tab.dart';
import 'package:live_order/features/chat/ui/widgets/client_chats_tab.dart';
import 'package:live_order/features/notification/ui/widgets/client_notifications_tab.dart';
import 'package:live_order/features/profile/ui/widgets/client_profile_tab.dart';

class ClientHomeScreen extends StatefulWidget {
  final UserModel clientUser;

  const ClientHomeScreen({super.key, required this.clientUser});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is HomeStatusAlert) {
          AnimatedSnackBar.material(
            state.alertMessage,
            type: state.isSuccess ? AnimatedSnackBarType.success : AnimatedSnackBarType.info,
            mobileSnackBarPosition: MobileSnackBarPosition.top,
            desktopSnackBarPosition: DesktopSnackBarPosition.topRight,
            duration: const Duration(seconds: 4),
          ).show(context);
        }
      },
      buildWhen: (previous, current) => current is HomeLoaded,
      builder: (context, state) {
        if (state is! HomeLoaded) {
          return const Scaffold(
            backgroundColor: Color(0xFF111318),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
              ),
            ),
          );
        }

        final user = state.user;
        final orders = state.orders;
        final activeOrdersList = orders
            .where((o) => o.orderStatus != 'Delivered' && o.orderStatus != 'Cancelled')
            .toList();
        final completedOrders = orders.where((o) => o.orderStatus == 'Delivered').length;

        int totalNotificationsCount = 0;
        for (var order in orders) {
          totalNotificationsCount += 1;
          if (order.orderStatus != 'Waiting Driver') {
            totalNotificationsCount += 1;
          }
        }

        final unreadCount = state.unreadNotificationsCount;
        final unreadChatsCount = state.totalUnreadChats;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: const Color(0xFF111318),
            body: SafeArea(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  ClientHomeTab(
                    clientUser: user,
                    activeList: activeOrdersList,
                    unreadNotificationsCount: unreadCount,
                    totalNotificationsCount: totalNotificationsCount,
                    onNotificationTap: () {
                      setState(() => _currentIndex = 3);
                      context.read<HomeCubit>().markNotificationsAsSeen();
                    },
                  ),
                  ClientOrdersTab(allOrders: orders),
                  ClientChatsTab(allOrders: orders),
                  ClientNotificationsTab(orders: orders),
                  ClientProfileTab(clientUser: user, completedCount: completedOrders),
                ],
              ),
            ),
            bottomNavigationBar: _buildBottomNav(unreadChatsCount, unreadCount, totalNotificationsCount),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav(int unreadChats, int unreadNotifs, int totalNotificationsCount) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2028),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(0, Icons.home_rounded, 'الرئيسية', 0, totalNotificationsCount),
          _navItem(1, Icons.inventory_2_rounded, 'طلباتي', 0, totalNotificationsCount),
          _navItem(2, Icons.chat_bubble_rounded, 'المحادثات', unreadChats, totalNotificationsCount),
          _navItem(3, Icons.notifications_rounded, 'الإشعارات', unreadNotifs, totalNotificationsCount),
          _navItem(4, Icons.person_rounded, 'حسابي', 0, totalNotificationsCount),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, int badge, int totalNotificationsCount) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          if (index == 3) {
            context.read<HomeCubit>().markNotificationsAsSeen();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14.w : 10.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(22.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 21.sp,
                ),
                if (badge > 0)
                  Positioned(
                    right: -5.w,
                    top: -5.h,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(minWidth: 14.w, minHeight: 14.w),
                      child: Center(
                        child: Text(
                          '$badge',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 7.5.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected) ...[
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
