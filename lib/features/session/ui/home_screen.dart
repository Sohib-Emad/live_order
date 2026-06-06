import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/core/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:live_order/core/di/di.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/features/session/logic/cubit/home_cubit.dart';
import 'package:live_order/features/session/ui/widgets/driver_blocked_screen.dart';
import 'package:live_order/features/session/ui/widgets/driver_pending_screen.dart';
import 'package:live_order/features/admin/ui/admin_dashboard_screen.dart';
import 'package:live_order/features/driver_home/logic/cubit/driver_cubit.dart';
import 'package:live_order/features/driver_home/ui/driver_home_screen.dart';

import 'package:live_order/features/user_home/logic/cubit.dart';
import 'package:live_order/features/user_home/ui/client_dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (context) => getIt<HomeCubit>(),
      child: const HomeScreenBody(),
    );
  }
}

class HomeScreenBody extends StatefulWidget {
  const HomeScreenBody({super.key});

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  @override
  void initState() {
    super.initState();
    final uid = SupabaseService.instance.client.auth.currentUser?.id;
    if (uid != null) {
      context.read<HomeCubit>().initHome(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = SupabaseService.instance.client.auth.currentUser?.id;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('يرجى تسجيل الدخول أولاً')),
      );
    }

    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          current is HomeLoaded ||
          current is HomeLoading ||
          current is HomeError,
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F5F0),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
              ),
            ),
          );
        }

        if (state is HomeError) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F0),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/lottie/notfound.json',
                      width: 200.w,
                      height: 200.w,
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                    const HeightSpace(16),
                    Text(
                      'الحساب غير موجود',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const HeightSpace(12),
                    Text(
                      'عذراً، لم نتمكن من العثور على سجل لهذا الحساب في النظام، أو قد يكون هناك خطأ في الاتصال بالخادم. يرجى محاولة تسجيل الدخول مرة أخرى أو التواصل مع الإدارة.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (state.message.isNotEmpty &&
                        state.message != 'الحساب غير موجود في النظام') ...[
                      const HeightSpace(12),
                      Text(
                        'تفاصيل الخطأ: ${state.message}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.redAccent[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const HeightSpace(32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppDesign.primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        await SupabaseService.instance.client.auth.signOut();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.loginScreen,
                            (route) => false,
                          );
                        }
                      },
                      child: Text(
                        'العودة لتسجيل الدخول',
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

        if (state is HomeLoaded) {
          return _buildUserScreen(state.user);
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserScreen(UserProfile user) {
    if (user.driverStatus == 'blocked') {
      return const DriverBlockedScreen();
    }

    if (user.role == 'admin') {
      return const AdminDashboardScreen();
    } else if (user.role == 'driver') {
      if (user.driverStatus == 'pending') {
        return const DriverPendingScreen();
      } else {
        return BlocProvider<DriverCubit>(
          create: (context) => getIt<DriverCubit>(),
          child: DriverHomeScreen(driver: user),
        );
      }
    } else {
      return BlocProvider<ClientDashboardCubit>(
        create: (context) => getIt<ClientDashboardCubit>(),
        child: const ClientDashboardScreen(),
      );
    }
  }
}
