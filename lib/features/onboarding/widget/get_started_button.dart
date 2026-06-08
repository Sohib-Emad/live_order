import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';

class GetStartedButton extends StatelessWidget {
  final bool isLastPage;
  final VoidCallback onPressed;

  const GetStartedButton({
    super.key,
    required this.isLastPage,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppDesign.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppDesign.primary,
          foregroundColor: const Color(0xFF1A1A1A),
          padding: EdgeInsets.symmetric(
            horizontal: isLastPage ? 32.w : 24.w,
            vertical: 14.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isLastPage ? 'ابدأ الآن' : 'التالي',
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            const WidthSpace(6),
            Icon(
              isLastPage
                  ? Icons.check_circle_outline_rounded
                  : Icons.arrow_forward_rounded,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
