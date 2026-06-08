import 'dart:math' show cos, sqrt, pi;
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/di/di.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/utils/animated_snack_dialog.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/features/driver_orders/logic/cubit/add_order_cubit.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/features/driver_orders/ui/widget/order_status_badge.dart';
import 'package:live_order/features/driver_orders/ui/widget/order_info_row.dart';
import 'package:live_order/features/driver_orders/ui/widget/order_location_card.dart';
import 'package:live_order/features/driver_orders/ui/widget/order_section_title.dart';
import 'package:live_order/features/driver_orders/ui/widget/order_stepper_row.dart';
import 'package:live_order/features/driver_orders/ui/widget/order_location_detail_row.dart';
import 'package:live_order/features/driver_orders/ui/widget/order_metadata_row.dart';
import 'package:live_order/features/driver_orders/ui/widget/order_chat_button.dart';
import 'package:live_order/features/driver_orders/ui/widget/premium_order_map_widget.dart';
import 'package:live_order/features/driver_orders/ui/widget/interactive_rating_card.dart';

class OrderDetailsBody extends StatelessWidget {
  final Shipment order;
  final bool isDriver;

  const OrderDetailsBody({super.key, required this.order, this.isDriver = false});

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = pi / 180;
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * sqrt(a);
  }

  int _getActiveStep() {
    switch (order.status) {
      case 'Waiting Driver':
      case 'نشط':
        return 0;
      case 'Accepted':
      case 'قيد التجهيز':
        return 1;
      case 'In Transit':
      case 'قيد التوصيل':
        return 2;
      case 'Delivered':
      case 'مكتمل':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final distance = _calculateDistance(
      order.dropLat,
      order.dropLng,
      order.pickupLat,
      order.pickupLng,
    );
    final activeStep = _getActiveStep();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F0),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF1A1A1A),
                  size: 18,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          centerTitle: true,
          title: Text(
            isDriver ? 'تفاصيل الشحنة' : 'تفاصيل الطلب',
            style: AppDesign.heading(color: AppDesign.textPrimary, fontSize: 18).copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
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
                                'رقم تعريف الشحنة',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const HeightSpace(4),
                              Row(
                                children: [
                                  Text(
                                    order.id.length > 8
                                        ? '#${order.id.substring(0, 8)}...'
                                        : '#${order.id}',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF1A1A1A),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const WidthSpace(8),
                                  GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(
                                        ClipboardData(text: order.id),
                                      );
                                      showAnimatedSnackDialog(
                                        context,
                                        message: 'تم نسخ معرف الطلب!',
                                        type: AnimatedSnackBarType.success,
                                      );
                                    },
                                    child: Icon(
                                      Icons.copy_rounded,
                                      color: AppDesign.primary,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          OrderStatusBadge(status: order.status),
                        ],
                      ),
                      const HeightSpace(16),
                      Divider(color: Colors.grey[200], thickness: 1),
                      const HeightSpace(12),
                      Row(
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB300).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: const Icon(
                              Icons.shopping_bag_rounded,
                              color: Color(0xFFFFB300),
                              size: 22,
                            ),
                          ),
                          const WidthSpace(16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'محتوى الشحنة',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                const HeightSpace(2),
                                Text(
                                  order.orderName,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const HeightSpace(20),

                if (order.driverId.isNotEmpty) ...[
                  OrderChatButton(
                    isDriver: isDriver,
                    clientId: order.clientId,
                    driverId: order.driverId,
                    orderName: order.orderName,
                  ),
                  const HeightSpace(20),
                ],

                if (isDriver) ...[
                  OrderSectionTitle(
                    title: 'بيانات الشحنة',
                    icon: Icons.inventory_2_rounded,
                  ),
                  const HeightSpace(12),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        OrderInfoRow(
                          icon: Icons.crop_free_rounded,
                          label: 'حجم الشحنة',
                          value: order.size == 'small'
                              ? 'صغير'
                              : order.size == 'medium'
                              ? 'متوسط'
                              : 'كبير/ثقيل',
                        ),
                        const HeightSpace(10),
                        OrderInfoRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'تاريخ الطلب',
                          value: order.preferredDate.split('T').first,
                        ),
                        const HeightSpace(10),
                        OrderInfoRow(
                          icon: Icons.flag_rounded,
                          label: 'حالة الطلب',
                          value: order.status == 'Waiting Driver'
                              ? 'بانتظار السائق'
                              : order.status == 'Accepted'
                              ? 'مقبول'
                              : order.status == 'In Transit'
                              ? 'قيد التوصيل'
                              : order.status == 'Delivered'
                              ? 'تم التوصيل'
                              : order.status == 'Cancelled'
                              ? 'ملغي'
                              : order.status,
                        ),
                      ],
                    ),
                  ),
                  const HeightSpace(20),

                  OrderSectionTitle(
                    title: 'موقع الاستلام (العميل)',
                    icon: Icons.person_pin_circle_rounded,
                  ),
                  const HeightSpace(12),
                  OrderLocationCard(
                    lat: order.dropLat,
                    lng: order.dropLng,
                    color: const Color(0xFF1A1A1A),
                    icon: Icons.person_pin_circle_rounded,
                    label: 'موقع العميل (نقطة الاستلام)',
                  ),
                  const HeightSpace(20),

                  OrderSectionTitle(
                    title: 'موقع التسليم (الوجهة)',
                    icon: Icons.pin_drop_rounded,
                  ),
                  const HeightSpace(12),
                  OrderLocationCard(
                    lat: order.pickupLat,
                    lng: order.pickupLng,
                    color: const Color(0xFFFFB300),
                    icon: Icons.pin_drop_rounded,
                    label: 'وجهة التوصيل',
                  ),
                  const HeightSpace(20),

                  OrderSectionTitle(
                    title: 'مسار الشحنة على الخريطة',
                    icon: Icons.map_rounded,
                  ),
                  const HeightSpace(12),
                  PremiumOrderMapWidget(order: order),
                  const HeightSpace(20),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المسافة التقريبية للرحلة:',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[400],
                          ),
                        ),
                        Text(
                          '${distance.toStringAsFixed(2)} كم',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFFFB300),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const HeightSpace(20),
                ]
                else ...[
                  OrderSectionTitle(
                    title: 'مراحل التوصيل وحالة الشحنة',
                    icon: Icons.timeline_rounded,
                  ),
                  const HeightSpace(12),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        OrderStepperRow(
                          title: 'تم استلام الطلب',
                          subtitle: 'تم تسجيل الطلبية في النظام وتأكيدها',
                          isActive: activeStep >= 0,
                          isLast: false,
                        ),
                        OrderStepperRow(
                          title: 'قيد التجهيز',
                          subtitle: 'يتم تجهيز المنتجات وتعبئتها للشحن',
                          isActive: activeStep >= 1,
                          isLast: false,
                        ),
                        OrderStepperRow(
                          title: 'جاري التوصيل',
                          subtitle: 'الطلب برفقة المندوب وفي الطريق إليك',
                          isActive: activeStep >= 2,
                          isLast: false,
                        ),
                        OrderStepperRow(
                          title: 'تم التوصيل',
                          subtitle: 'تم استلام وتوصيل الطلب للعميل',
                          isActive: activeStep >= 3,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const HeightSpace(20),

                  OrderSectionTitle(
                    title: 'بيانات الموقع والمسافة الجغرافية',
                    icon: Icons.location_on_rounded,
                  ),
                  const HeightSpace(12),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PremiumOrderMapWidget(order: order),
                        const HeightSpace(16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'المسافة التقريبية للشحن:',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                              child: Text(
                                '${distance.toStringAsFixed(2)} كم',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFFB300),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const HeightSpace(16),
                        Divider(color: Colors.grey[100]),
                        const HeightSpace(12),
                        OrderLocationDetailRow(
                          title: 'موقع العميل',
                          lat: order.dropLat,
                          lng: order.dropLng,
                          color: const Color(0xFF1A1A1A),
                          icon: Icons.person_pin_circle_rounded,
                        ),
                        const HeightSpace(16),
                        OrderLocationDetailRow(
                          title: 'موقع توصيل الطلب',
                          lat: order.pickupLat,
                          lng: order.pickupLng,
                          color: const Color(0xFFFFB300),
                          icon: Icons.pin_drop_rounded,
                        ),
                      ],
                    ),
                  ),
                  const HeightSpace(20),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A).withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OrderMetadataRow(
                          label: 'تاريخ الطلب:',
                          value: order.preferredDate.split('T').first,
                        ),
                        const HeightSpace(8),
                        OrderMetadataRow(
                          label: 'معرف صاحب الطلب:',
                          value: order.clientId,
                        ),
                      ],
                    ),
                  ),
                  const HeightSpace(20),

                  BlocProvider(
                    create: (context) => getIt<AddOrderCubit>(),
                    child: InteractiveRatingCard(order: order),
                  ),
                  const HeightSpace(20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
