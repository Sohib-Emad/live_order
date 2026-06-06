import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';

class DriverPendingScreen extends StatelessWidget {
  const DriverPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90.w,
                height: 90.w,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_empty_rounded,
                  color: Colors.orange,
                  size: 40.sp,
                ),
              ),
              const HeightSpace(24),
              Text(
                'طلب التسجيل قيد المراجعة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const HeightSpace(12),
              Text(
                'مرحباً بك كابتن! تم استلام بيانات مركبتك بنجاح وجاري مراجعتها وتدقيقها من قبل الإدارة العامة للموافقة وتفعيل حسابك بأسرع وقت.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const HeightSpace(32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    context.go('/loginScreen');
                  }
                },
                child: Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
