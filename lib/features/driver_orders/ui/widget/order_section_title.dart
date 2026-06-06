import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';

class OrderSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const OrderSectionTitle({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppDesign.primary, size: 20),
        const WidthSpace(8),
        Text(
          title,
          style: AppDesign.body(color: AppDesign.textPrimary, fontWeight: FontWeight.bold, fontSize: 16).copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}
