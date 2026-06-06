import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/core/styling/app_colors.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/features/add_order/models/order_model.dart';
import 'package:live_order/features/driver/logic/cubit/driver_cubit.dart';

class ShipmentCard extends StatelessWidget {
  final OrderModel order;
  const ShipmentCard({super.key, required this.order});

  Color get _color {
    switch (order.orderStatus) {
      case 'Waiting Driver':
        return AppColors.primaryColor;
      case 'Accepted':
        return Colors.blueAccent;
      case 'In Transit':
        return AppColors.primaryColor;
      case 'Delivered':
        return const Color(0xFF4CAF50);
      default:
        return Colors.redAccent;
    }
  }

  String get _label {
    switch (order.orderStatus) {
      case 'Waiting Driver':
        return 'عرض جديد';
      case 'Accepted':
        return 'مقبولة';
      case 'In Transit':
        return 'في الطريق';
      case 'Delivered':
        return 'تم التوصيل';
      default:
        return 'ملغي';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOffer = order.orderStatus == 'Waiting Driver';
    final isAccepted = order.orderStatus == 'Accepted';
    final isTransit = order.orderStatus == 'In Transit';

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          AppRoutes.orderDetailsScreen,
          extra: {'order': order, 'isDriver': true},
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header stripe
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.07),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(18.r),
                  topLeft: Radius.circular(18.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.orderName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A1A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: _color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      _label,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: _color,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
              child: Column(
                children: [
                  Row(
                    children: [
                      _chip(
                        Icons.crop_free_rounded,
                        order.orderSize == 'small'
                            ? 'صغير'
                            : order.orderSize == 'medium'
                            ? 'متوسط'
                            : 'كبير',
                      ),
                      const WidthSpace(10),
                      _chip(
                        Icons.calendar_today_rounded,
                        order.orderDate.split('T').first,
                      ),
                    ],
                  ),

                  // Rating
                  if (order.rating != null) ...[
                    const HeightSpace(10),
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.primaryColor,
                            size: 15,
                          ),
                          const WidthSpace(6),
                          Text(
                            'تقييم: ${order.rating!.toStringAsFixed(1)} / 5.0',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          if (order.review != null && order.review!.isNotEmpty)
                            Expanded(
                              child: Text(
                                '  — "${order.review}"',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],

                  const HeightSpace(12),

                  // Buttons
                  if (isOffer)
                    Row(
                      children: [
                        Expanded(
                          child: _btn(
                            context: context,
                            label: 'قبول',
                            icon: Icons.check_rounded,
                            color: const Color(0xFF4CAF50),
                            onTap: () => context
                                .read<DriverCubit>()
                                .acceptShipment(order.orderId),
                          ),
                        ),
                        const WidthSpace(10),
                        Expanded(
                          child: _btn(
                            context: context,
                            label: 'رفض',
                            icon: Icons.close_rounded,
                            color: Colors.redAccent,
                            onTap: () => context
                                .read<DriverCubit>()
                                .rejectShipment(order.orderId),
                          ),
                        ),
                      ],
                    )
                  else if (isAccepted)
                    _btn(
                      context: context,
                      label: 'بدء التوصيل',
                      icon: Icons.directions_run_rounded,
                      color: AppColors.primaryColor,
                      onTap: () => context
                          .read<DriverCubit>()
                          .updateShipmentStatus(order.orderId, 'In Transit'),
                      fullWidth: true,
                    )
                  else if (isTransit)
                    _btn(
                      context: context,
                      label: 'تأكيد التوصيل',
                      icon: Icons.check_circle_rounded,
                      color: const Color(0xFF4CAF50),
                      onTap: () => context
                          .read<DriverCubit>()
                          .updateShipmentStatus(order.orderId, 'Delivered'),
                      fullWidth: true,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _btn({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    Widget b = ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15),
      label: Text(
        label,
        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: b);
    }
    return b;
  }
}
