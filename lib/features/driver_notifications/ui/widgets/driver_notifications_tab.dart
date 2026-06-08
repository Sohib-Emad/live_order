import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/core/constants/app_design.dart';

class DriverNotificationsTab extends StatelessWidget {
  final List<Shipment> orders;

  const DriverNotificationsTab({
    super.key,
    required this.orders,
  });

  static const _orange = Color(0xFFFFB300);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dynamicNotifications = [];

    for (var order in orders) {
      final orderDateStr = order.preferredDate.contains('T')
          ? order.preferredDate.split('T').first
          : order.preferredDate;

      // New Offer Alert
      if (order.status == 'Waiting Driver') {
        dynamicNotifications.add({
          'title': 'عرض شحن جديد بانتظار قبولك',
          'body':
              'لديك طلب شحن جديد لـ "${order.orderName}". يرجى مراجعته وقبوله بأسرع وقت.',
          'time': orderDateStr,
          'icon': Icons.local_shipping_rounded,
          'color': _orange,
          'sortDate': order.preferredDate,
        });
      }

      // Accepted status
      if (order.status == 'Accepted') {
        dynamicNotifications.add({
          'title': 'تم قبول الشحنة بنجاح',
          'body':
              'قبلت شحنة "${order.orderName}". يرجى التحرك والتنسيق للوصول لموقع الاستلام.',
          'time': orderDateStr,
          'icon': Icons.check_circle_rounded,
          'color': Colors.blueAccent,
          'sortDate': order.preferredDate,
        });
      }

      // Transit Status
      if (order.status == 'In Transit') {
        dynamicNotifications.add({
          'title': 'بدء الرحلة والتوصيل',
          'body':
              'الشحنة "${order.orderName}" قيد التوصيل الآن. تمنياتنا لك برحلة آمنة.',
          'time': orderDateStr,
          'icon': Icons.directions_run_rounded,
          'color': Colors.deepOrangeAccent,
          'sortDate': order.preferredDate,
        });
      }

      // Delivered Status
      if (order.status == 'Delivered') {
        dynamicNotifications.add({
          'title': 'تم توصيل الطلب بنجاح',
          'body':
              'تم توصيل شحنة "${order.orderName}" بنجاح للعميل! رصيدك وتفاصيل الرحلة تم ترحيلها.',
          'time': orderDateStr,
          'icon': Icons.check_circle_rounded,
          'color': const Color(0xFF4CAF50),
          'sortDate': order.preferredDate,
        });
      }

      // Cancelled Status
      if (order.status == 'Cancelled') {
        dynamicNotifications.add({
          'title': 'تم إلغاء شحنة موكلة إليك',
          'body':
              'تم إلغاء طلب شحن "${order.orderName}" من قبل العميل أو الإدارة.',
          'time': orderDateStr,
          'icon': Icons.cancel_rounded,
          'color': Colors.redAccent,
          'sortDate': order.preferredDate,
        });
      }
    }

    dynamicNotifications.sort((a, b) => b['sortDate'].compareTo(a['sortDate']));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
          child: Text(
            'تنبيهات وحالات التوصيل المباشرة',
            style: AppDesign.heading(
              fontSize: 20.sp,
              color: AppDesign.textPrimary,
            ),
          ),
        ),
        const HeightSpace(16),
        Expanded(
          child: dynamicNotifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 56.sp,
                        color: Colors.grey[300],
                      ),
                      const HeightSpace(12),
                      Text(
                        'لا توجد إشعارات حالياً.',
                        style: AppDesign.heading(
                          fontSize: 12.sp,
                          color: AppDesign.textPrimary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  itemCount: dynamicNotifications.length,
                  itemBuilder: (context, index) {
                    final notif = dynamicNotifications[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: AppDesign.border, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38.w,
                            height: 38.w,
                            decoration: BoxDecoration(
                              color: notif['color'].withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              notif['icon'],
                              color: notif['color'],
                              size: 18.sp,
                            ),
                          ),
                          const WidthSpace(14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      notif['title'],
                                      style: AppDesign.heading(
                                        fontSize: 13.sp,
                                        color: AppDesign.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      notif['time'],
                                      style: AppDesign.body(
                                        fontSize: 9.5.sp,
                                        color: AppDesign.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const HeightSpace(4),
                                Text(
                                  notif['body'],
                                  style: AppDesign.body(
                                    fontSize: 11.5.sp,
                                    color: AppDesign.textSecondary,
                                    height: 1.4,
                                  ),
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
