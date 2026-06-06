import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/features/add_order/models/order_model.dart';

class ClientNotificationsTab extends StatelessWidget {
  final List<OrderModel> orders;

  const ClientNotificationsTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifs = [];

    for (var order in orders) {
      final dateStr = order.orderDate.contains('T')
          ? order.orderDate.split('T').first
          : order.orderDate;

      notifs.add({
        'title': 'تم تسجيل طلبك بنجاح',
        'body': 'شحنة "${order.orderName}" قيد الانتظار.',
        'time': dateStr,
        'icon': Icons.assignment_turned_in_rounded,
        'color': Colors.grey[600]!,
      });

      if (order.orderStatus != 'Waiting Driver') {
        String title = '';
        String body = '';
        IconData icon = Icons.info_outline_rounded;
        Color color = Colors.blue;

        if (order.orderStatus == 'Accepted') {
          title = 'تم قبول الشحنة';
          body = 'تم قبول شحنتك "${order.orderName}" من قبل الكابتن.';
          icon = Icons.check_circle_rounded;
          color = const Color(0xFF4CAF50);
        } else if (order.orderStatus == 'In Transit') {
          title = 'قيد التوصيل الآن';
          body = 'شحنتك "${order.orderName}" قيد التوصيل حالياً.';
          icon = Icons.local_shipping_rounded;
          color = const Color(0xFFFFB300);
        } else if (order.orderStatus == 'Delivered') {
          title = 'تم توصيل الشحنة بنجاح';
          body = 'شحنتك "${order.orderName}" وصلت للموقع بنجاح.';
          icon = Icons.check_circle_rounded;
          color = const Color(0xFF4CAF50);
        } else if (order.orderStatus == 'Cancelled') {
          title = 'تم إلغاء الشحنة';
          body = 'تم إلغاء طلب شحنتك "${order.orderName}".';
          icon = Icons.cancel_rounded;
          color = Colors.redAccent;
        }

        notifs.add({
          'title': title,
          'body': body,
          'time': dateStr,
          'icon': icon,
          'color': color,
        });
      }
    }

    final dynamicNotifications = notifs.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
          color: const Color(0xFF1E2028),
          child: Row(
            children: [
              Icon(Icons.notifications_rounded, color: const Color(0xFFFFB300), size: 22.sp),
              SizedBox(width: 10.w),
              Text(
                'التنبيهات والإشعارات',
                style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ],
          ),
        ),
        Expanded(
          child: dynamicNotifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none_rounded, size: 56.sp, color: Colors.grey[800]),
                      SizedBox(height: 12.h),
                      Text(
                        'لا توجد تنبيهات بعد',
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey[600], fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  itemCount: dynamicNotifications.length,
                  itemBuilder: (context, index) {
                    final notif = dynamicNotifications[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2028),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Colors.white.withOpacity(0.04)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38.w,
                            height: 38.w,
                            decoration: BoxDecoration(
                              color: notif['color'].withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(notif['icon'], color: notif['color'], size: 18.sp),
                          ),
                          const WidthSpace(14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      notif['title'],
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: Colors.white),
                                    ),
                                    Text(
                                      notif['time'],
                                      style: TextStyle(fontSize: 9.5.sp, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                const HeightSpace(4),
                                Text(
                                  notif['body'],
                                  style: TextStyle(fontSize: 11.5.sp, color: Colors.grey[400], height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
