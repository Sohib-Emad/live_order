import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/constants/app_design.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? role;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.role,
  });

  String _roleLabel() {
    switch (role) {
      case 'driver':
        return 'سائق نشط';
      case 'admin':
        return 'مشرف نشط';
      default:
        return 'عميل نشط';
    }
  }

  IconData _roleIcon() {
    switch (role) {
      case 'driver':
        return Icons.local_shipping_rounded;
      case 'admin':
        return Icons.admin_panel_settings_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 16.h),
      width: double.infinity,
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: AppDesign.primary.withOpacity(0.2),
                width: 2.r,
              ),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'ع',
                style: TextStyle(
                  color: AppDesign.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 26.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: AppDesign.heading(fontSize: 18.0),
                ),
                SizedBox(height: 4.h),
                Text(
                  email,
                  style: AppDesign.body(
                    color: AppDesign.textSecondary,
                    fontSize: 12.0,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppDesign.success.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppDesign.success.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _roleIcon(),
                        color: AppDesign.success,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _roleLabel(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: AppDesign.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
