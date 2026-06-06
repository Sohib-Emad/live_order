import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/constants/app_design.dart';

class PageIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;

  const PageIndicator({
    super.key,
    required this.itemCount,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(itemCount, (index) {
        final isSelected = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.only(left: 6.w),
          width: isSelected ? 24.w : 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: isSelected ? AppDesign.primary : Colors.grey[300],
            borderRadius: BorderRadius.circular(10.r),
          ),
        );
      }),
    );
  }
}
