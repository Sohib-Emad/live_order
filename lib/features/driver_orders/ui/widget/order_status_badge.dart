import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({super.key, required this.status});

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

  @override
  Widget build(BuildContext context) {
    final isDelivered =
        status == 'Delivered' || status == 'مكتمل';
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
            _statusArabic(status),
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
}
