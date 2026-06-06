import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/constants/app_design.dart';

class ProfileStats extends StatelessWidget {
  final Map<String, dynamic> stats;
  final String? role;

  const ProfileStats({
    super.key,
    required this.stats,
    this.role,
  });

  @override
  Widget build(BuildContext context) {
    final isDriver = role == 'driver';
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: AppDesign.border.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'الطلبات المكتملة',
            '${stats['completed_orders'] ?? 0}',
            Icons.check_circle_outline_rounded,
            AppDesign.success,
          ),
          _buildStatItem(
            'الطلبات النشطة',
            '${stats['active_orders'] ?? 0}',
            Icons.local_shipping_outlined,
            AppDesign.primary,
          ),
          _buildStatItem(
            isDriver ? 'إجمالي الأرباح' : 'إجمالي الإنفاق',
            '${(stats['total_spent'] as num?)?.toStringAsFixed(0) ?? 0} ج.م',
            Icons.account_balance_wallet_outlined,
            const Color(0xFF2196F3),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: AppDesign.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: AppDesign.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
