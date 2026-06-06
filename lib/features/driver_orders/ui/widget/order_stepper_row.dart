import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';

class OrderStepperRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isActive;
  final bool isLast;

  const OrderStepperRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
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
}
