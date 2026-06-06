import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/constants/app_design.dart';

class SupportInfoDialog extends StatelessWidget {
  const SupportInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'الدعم الفني والمساعدة',
          style: AppDesign.heading(fontSize: 16.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSupportItem('📞', 'رقم الدعم السريع', '19999'),
            const Divider(color: AppDesign.border, height: 16),
            _buildSupportItem(
              '📧',
              'البريد الإلكتروني المخصص',
              'support@liveorder.com',
            ),
            const Divider(color: AppDesign.border, height: 16),
            _buildSupportItem(
              '⏰',
              'أوقات العمل المتاحة',
              '24 ساعة / 7 أيام طوال الأسبوع',
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppDesign.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إغلاق',
              style: AppDesign.body(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportItem(String icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppDesign.surface,
            shape: BoxShape.circle,
          ),
          child: Text(icon, style: TextStyle(fontSize: 18.sp)),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppDesign.body(
                  color: AppDesign.textSecondary,
                  fontSize: 11.0,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: AppDesign.body(
                  color: AppDesign.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
