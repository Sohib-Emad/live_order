import 'package:live_order/core/constants/app_design.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/features/session/logic/cubit/home_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';

class DriverBlockedScreen extends StatefulWidget {
  const DriverBlockedScreen({super.key});

  @override
  State<DriverBlockedScreen> createState() => _DriverBlockedScreenState();
}

class _DriverBlockedScreenState extends State<DriverBlockedScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
              Lottie.asset(
                'assets/lottie/block.json',
                controller: _controller,
                onLoaded: (composition) {
                  _controller
                    ..duration = composition.duration
                    ..repeat();
                },
                width: 180.w,
                height: 180.w,
                fit: BoxFit.contain,
              ),
              const HeightSpace(24),
              Text(
                'عذراً، حسابك محظور حالياً',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const HeightSpace(12),
              Text(
                'لقد تم تجميد أو حظر حسابك لمخالفة شروط الاستخدام وسياسات العمل أو بسبب بلاغات متكررة. يرجى التواصل مع الدعم الفني للمزيد من التفاصيل.',
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
                  backgroundColor: AppDesign.primaryColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () async {
                  await context.read<HomeCubit>().signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.loginScreen,
                      (route) => false,
                    );
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
