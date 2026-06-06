import 'dart:math' show cos, sqrt, pi;
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_order/core/di/di.dart';
import 'package:live_order/core/styling/app_colors.dart';
import 'package:live_order/core/styling/app_styles.dart';
import 'package:live_order/core/utils/animated_snack_dialog.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/features/add_order/logic/cubit/add_order_cubit.dart';
import 'package:live_order/features/add_order/models/order_model.dart';
import 'package:live_order/features/chat/ui/widgets/live_chat_sheet.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;
  final bool isDriver;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    this.isDriver = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .doc(order.orderId)
          .snapshots(),
      builder: (context, snapshot) {
        final currentOrder = (snapshot.hasData && snapshot.data!.exists)
            ? OrderModel.fromJson(
                snapshot.data!.data() as Map<String, dynamic>,
                docId: snapshot.data!.id,
              )
            : order;

        return _OrderDetailsBody(order: currentOrder, isDriver: isDriver);
      },
    );
  }
}

class _OrderDetailsBody extends StatelessWidget {
  final OrderModel order;
  final bool isDriver;

  const _OrderDetailsBody({required this.order, this.isDriver = false});

  // Haversine formula to calculate the distance in kilometers between two coordinates
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
    return 12742 * sqrt(a); // 2 * R; R = 6371 km
  }

  // Get active step index based on order status
  int _getActiveStep() {
    switch (order.orderStatus) {
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
      order.userLat,
      order.userLong,
      order.orderLat,
      order.orderLong,
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
                    color: Colors.black.withOpacity(0.05),
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
                onPressed: () => context.pop(),
              ),
            ),
          ),
          centerTitle: true,
          title: Text(
            isDriver ? 'تفاصيل الشحنة' : 'تفاصيل الطلب',
            style: AppStyles.black18BoldStyle.copyWith(
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
                // ── Order Header Card ──────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
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
                                    order.orderId.length > 8
                                        ? '#${order.orderId.substring(0, 8)}...'
                                        : '#${order.orderId}',
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
                                        ClipboardData(text: order.orderId),
                                      );
                                      showAnimatedSnackDialog(
                                        context,
                                        message: 'تم نسخ معرف الطلب!',
                                        type: AnimatedSnackBarType.success,
                                      );
                                    },
                                    child: Icon(
                                      Icons.copy_rounded,
                                      color: AppColors.primaryColor,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          _buildStatusBadge(),
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
                              color: const Color(0xFFFFB300).withOpacity(0.1),
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
                  _buildChatButton(context),
                  const HeightSpace(20),
                ],

                // ── Driver View: Cargo Info ────────────────────────────────
                if (isDriver) ...[
                  _buildSectionTitle(
                    'بيانات الشحنة',
                    Icons.inventory_2_rounded,
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
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.crop_free_rounded,
                          label: 'حجم الشحنة',
                          value: order.orderSize == 'small'
                              ? 'صغير'
                              : order.orderSize == 'medium'
                              ? 'متوسط'
                              : 'كبير/ثقيل',
                        ),
                        const HeightSpace(10),
                        _buildInfoRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'تاريخ الطلب',
                          value: order.orderDate.split('T').first,
                        ),
                        const HeightSpace(10),
                        _buildInfoRow(
                          icon: Icons.flag_rounded,
                          label: 'حالة الطلب',
                          value: _statusArabic(order.orderStatus),
                        ),
                      ],
                    ),
                  ),
                  const HeightSpace(20),

                  // Pickup location (user)
                  _buildSectionTitle(
                    'موقع الاستلام (العميل)',
                    Icons.person_pin_circle_rounded,
                  ),
                  const HeightSpace(12),
                  _buildLocationCard(
                    lat: order.userLat,
                    lng: order.userLong,
                    color: const Color(0xFF1A1A1A),
                    icon: Icons.person_pin_circle_rounded,
                    label: 'موقع العميل (نقطة الاستلام)',
                  ),
                  const HeightSpace(20),

                  // Delivery destination
                  _buildSectionTitle(
                    'موقع التسليم (الوجهة)',
                    Icons.pin_drop_rounded,
                  ),
                  const HeightSpace(12),
                  _buildLocationCard(
                    lat: order.orderLat,
                    lng: order.orderLong,
                    color: const Color(0xFFFFB300),
                    icon: Icons.pin_drop_rounded,
                    label: 'وجهة التوصيل',
                  ),
                  const HeightSpace(20),

                  _buildSectionTitle(
                    'مسار الشحنة على الخريطة',
                    Icons.map_rounded,
                  ),
                  const HeightSpace(12),
                  PremiumOrderMapWidget(order: order),
                  const HeightSpace(20),

                  // Distance
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
                // ── Client View: Tracking Stepper ──────────────────────────
                else ...[
                  _buildSectionTitle(
                    'مراحل التوصيل وحالة الشحنة',
                    Icons.timeline_rounded,
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
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildStepperRow(
                          'تم استلام الطلب',
                          'تم تسجيل الطلبية في النظام وتأكيدها',
                          activeStep >= 0,
                          isLast: false,
                        ),
                        _buildStepperRow(
                          'قيد التجهيز',
                          'يتم تجهيز المنتجات وتعبئتها للشحن',
                          activeStep >= 1,
                          isLast: false,
                        ),
                        _buildStepperRow(
                          'جاري التوصيل',
                          'الطلب برفقة المندوب وفي الطريق إليك',
                          activeStep >= 2,
                          isLast: false,
                        ),
                        _buildStepperRow(
                          'تم التوصيل',
                          'تم استلام وتوصيل الطلب للعميل',
                          activeStep >= 3,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const HeightSpace(20),

                  // Location card for client
                  _buildSectionTitle(
                    'بيانات الموقع والمسافة الجغرافية',
                    Icons.location_on_rounded,
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
                          color: Colors.black.withOpacity(0.03),
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
                        _buildLocationDetailRow(
                          title: 'موقع العميل',
                          lat: order.userLat,
                          lng: order.userLong,
                          color: const Color(0xFF1A1A1A),
                          icon: Icons.person_pin_circle_rounded,
                        ),
                        const HeightSpace(16),
                        _buildLocationDetailRow(
                          title: 'موقع توصيل الطلب',
                          lat: order.orderLat,
                          lng: order.orderLong,
                          color: const Color(0xFFFFB300),
                          icon: Icons.pin_drop_rounded,
                        ),
                      ],
                    ),
                  ),
                  const HeightSpace(20),

                  // Metadata
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A).withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMetadataRow(
                          'تاريخ الطلب:',
                          order.orderDate.split('T').first,
                        ),
                        const HeightSpace(8),
                        _buildMetadataRow(
                          'معرف صاحب الطلب:',
                          order.orderUserId,
                        ),
                      ],
                    ),
                  ),
                  const HeightSpace(20),

                  // Rating
                  BlocProvider(
                    create: (context) => getIt<AddOrderCubit>(),
                    child: _InteractiveRatingCard(order: order),
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

  String _statusArabic(String status) {
    switch (status) {
      case 'Waiting Driver':
        return 'بانتظار السائق';
      case 'Accepted':
        return 'مقبول';
      case 'In Transit':
        return 'قيد التوصيل';
      case 'Delivered':
        return 'تم التوصيل';
      case 'Cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  Widget _buildStatusBadge() {
    final isDelivered =
        order.orderStatus == 'Delivered' || order.orderStatus == 'مكتمل';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDelivered ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: isDelivered
              ? const Color(0xFF81C784)
              : const Color(0xFFFFD54F),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isDelivered
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFFFB300),
              shape: BoxShape.circle,
            ),
          ),
          const WidthSpace(6),
          Text(
            _statusArabic(order.orderStatus),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: isDelivered
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFF57F17),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: const Color(0xFFFFB300).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: const Color(0xFFFFB300), size: 16.sp),
        ),
        const WidthSpace(12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationCard({
    required double lat,
    required double lng,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const WidthSpace(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const HeightSpace(4),
                Text(
                  'خط العرض: $lat',
                  style: TextStyle(fontSize: 10.5.sp, color: Colors.grey[500]),
                ),
                Text(
                  'خط الطول: $lng',
                  style: TextStyle(fontSize: 10.5.sp, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 20),
        const WidthSpace(8),
        Text(
          title,
          style: AppStyles.black15BoldStyle.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildStepperRow(
    String title,
    String subtitle,
    bool isActive, {
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFFFB300) : Colors.grey[300],
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFB300).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 14.sp,
              ),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 40.h,
                color: isActive ? const Color(0xFFFFB300) : Colors.grey[200],
              ),
          ],
        ),
        const WidthSpace(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: isActive ? const Color(0xFF1A1A1A) : Colors.grey[400],
                ),
              ),
              const HeightSpace(4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  color: isActive ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
              const HeightSpace(16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDetailRow({
    required String title,
    required double lat,
    required double lng,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const WidthSpace(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const HeightSpace(2),
              Text(
                'خط العرض: $lat | خط الطول: $lng',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const WidthSpace(8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildChatButton(BuildContext context) {
    final otherUserId = isDriver ? order.orderUserId : order.driverId;
    if (otherUserId.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final otherName =
            data?['name'] ??
            data?['username'] ??
            (isDriver ? 'العميل' : 'الكابتن');

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB300).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => LiveChatSheet(
                  chatId: '${order.orderUserId}_${order.driverId}',
                  orderName: order.orderName,
                  otherUserName: otherName,
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_rounded, size: 20),
            label: Text(
              isDriver
                  ? 'محادثة العميل ($otherName)'
                  : 'محادثة الكابتن ($otherName)',
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InteractiveRatingCard extends StatefulWidget {
  final OrderModel order;
  const _InteractiveRatingCard({required this.order});

  @override
  State<_InteractiveRatingCard> createState() => _InteractiveRatingCardState();
}

class _InteractiveRatingCardState extends State<_InteractiveRatingCard> {
  double _rating = 5.0;
  final TextEditingController _reviewController = TextEditingController();
  bool _submitted = false;
  double? _submittedRating;
  String? _submittedReview;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDelivered =
        widget.order.orderStatus == 'مكتمل' ||
        widget.order.orderStatus == 'Delivered';
    if (!isDelivered) {
      return const SizedBox.shrink();
    }

    final hasRating = widget.order.rating != null || _submitted;
    final ratingToShow = _submitted ? _submittedRating : widget.order.rating;
    final reviewToShow = _submitted ? _submittedReview : widget.order.review;

    if (hasRating) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: const Color(0xFFFFB300),
                  size: 22.sp,
                ),
                const WidthSpace(8),
                Text(
                  'تقييمك لمندوب التوصيل',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const HeightSpace(12),
            Row(
              children: List.generate(5, (index) {
                final starVal = index + 1;
                return Icon(
                  Icons.star_rounded,
                  color: starVal <= (ratingToShow ?? 5.0)
                      ? const Color(0xFFFFB300)
                      : Colors.grey[200],
                  size: 26.sp,
                );
              }),
            ),
            if (reviewToShow != null && reviewToShow.isNotEmpty) ...[
              const HeightSpace(12),
              Text(
                'تعليقك المكتوب:',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
              ),
              const HeightSpace(4),
              Text(
                '"$reviewToShow"',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return BlocConsumer<AddOrderCubit, AddOrderState>(
      listener: (context, state) {
        if (state is AddOrderSuccess) {
          setState(() {
            _submitted = true;
            _submittedRating = _rating;
            _submittedReview = _reviewController.text.trim();
          });
          showAnimatedSnackDialog(
            context,
            message: 'شكرًا لك! تم تسجيل تقييمك للمندوب بنجاح.',
            type: AnimatedSnackBarType.success,
          );
        } else if (state is AddOrderError) {
          showAnimatedSnackDialog(
            context,
            message: state.message,
            type: AnimatedSnackBarType.error,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AddOrderLoading;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.stars_rounded,
                    color: const Color(0xFFFFB300),
                    size: 22.sp,
                  ),
                  const WidthSpace(8),
                  Text(
                    'تقييم كابتن التوصيل',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              const HeightSpace(6),
              Text(
                'شاركنا تجربتك وقيم تعامل وسرعة كابتن التوصيل لتطوير الخدمة.',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey[500],
                  height: 1.4,
                ),
              ),
              const HeightSpace(16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starVal = index + 1;
                  final isSelected = starVal <= _rating;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _rating = starVal.toDouble();
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Icon(
                        Icons.star_rounded,
                        color: isSelected
                            ? const Color(0xFFFFB300)
                            : Colors.grey[200],
                        size: 38.sp,
                      ),
                    ),
                  );
                }),
              ),
              const HeightSpace(16),

              Text(
                'اكتب مراجعتك أو تعليقك (اختياري)',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF555555),
                ),
              ),
              const HeightSpace(8),
              TextFormField(
                controller: _reviewController,
                maxLines: 2,
                cursorColor: const Color(0xFFFFB300),
                decoration: InputDecoration(
                  hintText: 'اكتب تجربتك هنا مع الكابتن...',
                  hintStyle: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[400],
                  ),
                  contentPadding: EdgeInsets.all(12.w),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: Color(0xffE8ECF4),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: Color(0xFFFFB300),
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xffF7F8F9),
                ),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const HeightSpace(16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          context.read<AddOrderCubit>().rateDriverAndComplete(
                            shipmentId: widget.order.orderId,
                            driverId: widget.order.driverId,
                            newRating: _rating,
                            review: _reviewController.text.trim(),
                          );
                        },
                  icon: isLoading
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 16),
                  label: Text(
                    isLoading ? 'جاري الإرسال...' : 'إرسال التقييم والدعم',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PremiumOrderMapWidget extends StatefulWidget {
  final OrderModel order;
  const PremiumOrderMapWidget({super.key, required this.order});

  @override
  State<PremiumOrderMapWidget> createState() => _PremiumOrderMapWidgetState();
}

class _PremiumOrderMapWidgetState extends State<PremiumOrderMapWidget> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    final lat1 = widget.order.userLat;
    final lon1 = widget.order.userLong;
    final lat2 = widget.order.orderLat;
    final lon2 = widget.order.orderLong;

    // Safety checks: If coordinates are invalid, identical or zero, do not animate to bounds
    if ((lat1 == 0 && lon1 == 0) ||
        (lat2 == 0 && lon2 == 0) ||
        (lat1 == lat2 && lon1 == lon2)) {
      return;
    }

    final minLat = lat1 < lat2 ? lat1 : lat2;
    final maxLat = lat1 > lat2 ? lat1 : lat2;
    final minLng = lon1 < lon2 ? lon1 : lon2;
    final maxLng = lon1 > lon2 ? lon1 : lon2;

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    Future.delayed(const Duration(milliseconds: 1000), () {
      try {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50.w),
        );
      } catch (e) {
        debugPrint("Error animating camera to bounds: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pickup = LatLng(widget.order.userLat, widget.order.userLong);
    final destination = LatLng(widget.order.orderLat, widget.order.orderLong);

    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('pickup'),
        position: pickup,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: const InfoWindow(title: 'موقع الاستلام (العميل)'),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: 'وجهة التوصيل'),
      ),
    };

    final Set<Polyline> polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: [pickup, destination],
        color: const Color(0xFFFFB300),
        width: 4,
        geodesic: true,
      ),
    };

    return Container(
      width: double.infinity,
      height: 220.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              (pickup.latitude + destination.latitude) / 2,
              (pickup.longitude + destination.longitude) / 2,
            ),
            zoom: 12.0,
          ),
          onMapCreated: _onMapCreated,
          markers: markers,
          polylines: polylines,
          myLocationEnabled: false,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
        ),
      ),
    );
  }
}
