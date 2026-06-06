import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/constants/app_design.dart';

class LogoutConfirmDialog extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutConfirmDialog({super.key, required this.onLogout});

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
        title: Text('تسجيل الخروج', style: AppDesign.heading(fontSize: 16.0)),
        content: Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج من التطبيق؟',
          style: AppDesign.body(color: AppDesign.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: AppDesign.body(color: AppDesign.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            child: Text(
              'تسجيل خروج',
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
}
