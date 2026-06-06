import 'dart:async';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/utils/animated_snack_dialog.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/features/driver/logic/cubit/driver_cubit.dart';
import 'package:live_order/features/add_order/models/order_model.dart';
import 'package:live_order/features/add_order/models/user_model.dart';

// Decoupled features imports
import 'package:live_order/features/chat/ui/widgets/driver_chats_tab.dart';
import 'package:live_order/features/notification/ui/widgets/driver_notifications_tab.dart';
import 'package:live_order/features/offers/ui/widgets/driver_offers_tab.dart';
import 'package:live_order/features/profile/ui/widgets/driver_profile_tab.dart';
import 'package:live_order/features/driver/ui/widgets/shipment_card.dart';

class DriverHomeScreen extends StatefulWidget {
  final UserModel driver;
  const DriverHomeScreen({super.key, required this.driver});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int _currentIndex = 0;
  late bool _isAvailable;

  static const _bg = Color(0xFFF5F5F0);
  static const _dark = Color(0xFF1A1A1A);
  static const _orange = Color(0xFFFF6B00);

  int _lastSeenNotificationCount = 0;
  bool _hasInitialCountSet = false;
  final Map<String, String> _lastKnownOrderStatuses = {};
  
  // Tracks unread counts per chat - updated without setState for the list
  final Map<String, int> _unreadChats = {};
  // Tracks only the total for the nav badge - only this triggers setState
  int _totalUnreadChats = 0;
  final Map<String, StreamSubscription<QuerySnapshot>> _chatSubscriptions = {};
  StreamSubscription<List<OrderModel>>? _ordersSubscription;
  
  // Cached stream - never recreated on setState, prevents StreamBuilder re-subscription
  late final Stream<List<OrderModel>> _ordersStream;

  void _updateUnreadChat(String chatId, int unreadCount) {
    if (_unreadChats[chatId] == unreadCount) return;
    _unreadChats[chatId] = unreadCount;
    final newTotal = _unreadChats.values.fold(0, (a, b) => a + b);
    if (newTotal != _totalUnreadChats) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _totalUnreadChats = newTotal;
          });
        }
      });
    }
  }

  void _syncChatListeners(List<OrderModel> orders) {
    final currentChatIds = <String>{};
    for (var order in orders) {
      if (order.driverId.isNotEmpty) {
        final chatId = '${order.orderUserId}_${order.driverId}';
        currentChatIds.add(chatId);
        if (!_chatSubscriptions.containsKey(chatId)) {
          _chatSubscriptions[chatId] = FirebaseFirestore.instance
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .snapshots()
              .listen((msgSnapshot) {
                final myUid = FirebaseAuth.instance.currentUser?.uid;
                final unreadCount = msgSnapshot.docs.where((doc) {
                  final data = doc.data();
                  final senderId = data['sender_id'];
                  final isRead = data['is_read'] ?? false;
                  return senderId != myUid && isRead == false;
                }).length;

                _updateUnreadChat(chatId, unreadCount);
              });
        }
      }
    }

    final toRemove = <String>[];
    _chatSubscriptions.forEach((chatId, sub) {
      if (!currentChatIds.contains(chatId)) {
        sub.cancel();
        toRemove.add(chatId);
      }
    });

    for (var chatId in toRemove) {
      _chatSubscriptions.remove(chatId);
      _unreadChats.remove(chatId);
      // Recompute total after removal
      final newTotal = _unreadChats.values.fold(0, (a, b) => a + b);
      if (newTotal != _totalUnreadChats) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _totalUnreadChats = newTotal);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _isAvailable = widget.driver.isAvailable;
    _requestNotificationPermissions();
    
    // Cache the main orders stream - MUST be done once in initState
    _ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('driver_id', isEqualTo: widget.driver.userId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => OrderModel.fromJson(d.data(), docId: d.id))
              .toList(),
        );
        
    // Start listening to orders to sync chat unread counts in background
    _ordersSubscription = _ordersStream.listen((orders) {
      _syncChatListeners(orders);
    });
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    for (var sub in _chatSubscriptions.values) {
      sub.cancel();
    }
    super.dispose();
  }

  void _requestNotificationPermissions() async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (_) {}
  }

  void _toggleAvailability(bool val) async {
    setState(() => _isAvailable = val);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.driver.userId)
          .update({'is_available': val});
      if (mounted) {
        showAnimatedSnackDialog(
          context,
          message: val
              ? 'أنت الآن متاح لاستقبال الطلبات'
              : 'تم إيقاف استقبال الطلبات',
          type: AnimatedSnackBarType.info,
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderModel>>(
      stream: _ordersStream,
      builder: (context, snapshot) {
        final orders = snapshot.data ?? [];
        final offers = orders
            .where((o) => o.orderStatus == 'Waiting Driver')
            .toList();
        final activeOrdersList = orders
            .where(
              (o) =>
                  o.orderStatus == 'Accepted' || o.orderStatus == 'In Transit',
            )
            .toList();
        final completedOrdersList = orders
            .where((o) => o.orderStatus == 'Delivered')
            .toList();

        final activeOrdersCount = activeOrdersList.length;
        final completedOrdersCount = completedOrdersList.length;

        int totalNotificationsCount = orders.length;

        // Detect status changes to trigger real-time in-app notification banners!
        for (var order in orders) {
          final previousStatus = _lastKnownOrderStatuses[order.orderId];
          if (previousStatus != null && previousStatus != order.orderStatus) {
            _triggerInAppNotification(order, previousStatus);
          } else if (previousStatus == null &&
              _hasInitialCountSet &&
              order.orderStatus == 'Waiting Driver') {
            _triggerInAppNotification(order, 'None');
          }
          _lastKnownOrderStatuses[order.orderId] = order.orderStatus;
        }

        if (!_hasInitialCountSet) {
          _lastSeenNotificationCount = totalNotificationsCount;
          _hasInitialCountSet = true;
        }

        final unreadCount = (_currentIndex == 3)
            ? 0
            : (totalNotificationsCount - _lastSeenNotificationCount).clamp(
                0,
                99,
              );

        final unreadChatsCount = _totalUnreadChats.clamp(0, 99);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: _bg,
            body: SafeArea(
              child: BlocListener<DriverCubit, DriverState>(
                listener: (ctx, state) {
                  if (state is DriverSuccess) {
                    showAnimatedSnackDialog(
                      ctx,
                      message: 'تم تحديث حالة الشحنة بنجاح!',
                      type: AnimatedSnackBarType.success,
                    );
                  } else if (state is DriverError) {
                    showAnimatedSnackDialog(
                      ctx,
                      message: state.message,
                      type: AnimatedSnackBarType.error,
                    );
                  }
                },
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(_orange),
                        ),
                      )
                    : IndexedStack(
                        index: _currentIndex,
                        children: [
                          _buildHomeTab(
                            orders,
                            activeOrdersList,
                            activeOrdersCount,
                            completedOrdersCount,
                          ),
                          DriverOffersTab(offers: offers),
                          DriverChatsTab(allOrders: orders),
                          DriverNotificationsTab(orders: orders),
                          DriverProfileTab(
                            driver: widget.driver,
                            completedCount: completedOrdersCount,
                          ),
                        ],
                      ),
              ),
            ),
            bottomNavigationBar: Container(
              margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              decoration: BoxDecoration(
                color: _dark,
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    0,
                    Icons.home_rounded,
                    'الرئيسية',
                    0,
                    totalNotificationsCount,
                  ),
                  _buildNavItem(
                    1,
                    Icons.local_shipping_rounded,
                    'العروض',
                    0,
                    totalNotificationsCount,
                  ),
                  _buildNavItem(
                    2,
                    Icons.chat_bubble_rounded,
                    'المحادثات',
                    unreadChatsCount,
                    totalNotificationsCount,
                  ),
                  _buildNavItem(
                    3,
                    Icons.notifications_rounded,
                    'الإشعارات',
                    unreadCount,
                    totalNotificationsCount,
                  ),
                  _buildNavItem(
                    4,
                    Icons.person_rounded,
                    'حسابي',
                    0,
                    totalNotificationsCount,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    int badgeCount,
    int totalNotificationsCount,
  ) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          if (index == 3) {
            _lastSeenNotificationCount = totalNotificationsCount;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14.w : 10.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? _orange : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey[500],
                  size: 20.sp,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -4.w,
                    top: -4.h,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 14.w,
                        minHeight: 14.w,
                      ),
                      child: Center(
                        child: Text(
                          '$badgeCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 7.5.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected) ...[
              const WidthSpace(6),
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

  void _triggerInAppNotification(OrderModel order, String oldStatus) {
    String message = '';
    AnimatedSnackBarType snackBarType = AnimatedSnackBarType.info;

    if (order.orderStatus == 'Waiting Driver') {
      message =
          'لديك عرض توصيل جديد لشحنة "${order.orderName}"! يرجى مراجعته وقبوله.';
      snackBarType = AnimatedSnackBarType.info;
    } else if (order.orderStatus == 'Cancelled') {
      message = 'تم إلغاء الشحنة "${order.orderName}" من قبل العميل.';
      snackBarType = AnimatedSnackBarType.error;
    }

    if (message.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AnimatedSnackBar.material(
          message,
          type: snackBarType,
          mobileSnackBarPosition: MobileSnackBarPosition.top,
          desktopSnackBarPosition: DesktopSnackBarPosition.topRight,
          duration: const Duration(seconds: 4),
        ).show(context);
      });
    }
  }

  // ── Tab 1: HOME DASHBOARD ────────────────────────────────────────────────────
  Widget _buildHomeTab(
    List<OrderModel> allOrders,
    List<OrderModel> activeList,
    int activeCount,
    int completedCount,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً بك كابتن،',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const HeightSpace(4),
                    Text(
                      widget.driver.name,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: _dark,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                _RatingBadge(rating: widget.driver.rating),
              ],
            ),
          ),
          const HeightSpace(20),

          // Availability Card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: _dark,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isAvailable
                              ? const Color(0xFF4CAF50)
                              : Colors.grey[600],
                        ),
                      ),
                      const WidthSpace(8),
                      Text(
                        _isAvailable
                            ? 'متاح لتلقي طلبات الشحن'
                            : 'غير متصل حالياً',
                        style: TextStyle(
                          color: _isAvailable
                              ? const Color(0xFF4CAF50)
                              : Colors.grey[450],
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch.adaptive(
                      value: _isAvailable,
                      onChanged: _toggleAvailability,
                      activeColor: _orange,
                      activeTrackColor: _orange.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const HeightSpace(16),

          // Statistics
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                _StatCard(
                  label: 'رحلات جارية',
                  value: activeCount.toString(),
                  icon: Icons.directions_run_rounded,
                  color: _orange,
                ),
                const WidthSpace(12),
                _StatCard(
                  label: 'رحلات مكتملة',
                  value: completedCount.toString(),
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF4CAF50),
                ),
              ],
            ),
          ),
          const HeightSpace(24),

          // Quick Action / Tips Card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أدوات القيادة السريعة',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: _dark,
                  ),
                ),
                const HeightSpace(12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_dark, Color(0xFF333333)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: _orange,
                            size: 20.sp,
                          ),
                          const WidthSpace(8),
                          Text(
                            'تعليمات السلامة والتسليم',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const HeightSpace(8),
                      Text(
                        'يرجى دائماً التأكد من تطابق تفاصيل الشحنة ونوعها عند نقطة الاستلام قبل بدء التوصيل، والتواصل مع العميل لتأكيد الحضور.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11.sp,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const HeightSpace(24),

          // Active list summary
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الشحنات الجارية والنشطة',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: _dark,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 2; // Switch to Chats
                    });
                  },
                  child: const Text(
                    'تفاصيل',
                    style: TextStyle(
                      color: _orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const HeightSpace(8),

          activeList.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          size: 48.sp,
                          color: Colors.grey[300],
                        ),
                        const HeightSpace(10),
                        Text(
                          'لا توجد رحلات قيد التوصيل حالياً.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  itemCount: activeList.length > 2 ? 2 : activeList.length,
                  itemBuilder: (context, index) {
                    return ShipmentCard(order: activeList[index]);
                  },
                ),
          const HeightSpace(20),
        ],
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────────

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB300).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Icon(Icons.star_rounded, color: const Color(0xFFFFB300), size: 14.sp),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: const Color(0xFFFFB300),
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            const WidthSpace(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
