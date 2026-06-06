import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/di/di.dart';
import 'package:live_order/features/add_order/logic/cubit/add_order_cubit.dart';
import 'package:live_order/features/add_order/models/user_model.dart';
import 'package:live_order/features/admin/logic/cubit/admin_cubit.dart';
import 'package:live_order/features/admin/ui/admin_dashboard_screen.dart';
import 'package:live_order/features/driver/logic/cubit/driver_cubit.dart';
import 'package:live_order/features/driver/ui/driver_home_screen.dart';
import 'package:live_order/features/home/logic/cubit/home_cubit.dart';
import 'package:live_order/features/home/ui/widgets/driver_blocked_screen.dart';
import 'package:live_order/features/home/ui/widgets/driver_pending_screen.dart';
import 'package:live_order/features/chat/logic/cubit/chat_cubit.dart';
import 'package:live_order/features/notification/logic/cubit/notification_cubit.dart';
import 'package:live_order/features/offers/logic/cubit/offers_cubit.dart';
import 'package:live_order/features/profile/logic/cubit/profile_cubit.dart';

// Marketplace Home screen modules
import 'package:live_order/features/market_home/logic/cubit.dart';
import 'package:live_order/features/market_home/ui/screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AddOrderCubit>(create: (context) => getIt<AddOrderCubit>()),
        BlocProvider<HomeCubit>(create: (context) => getIt<HomeCubit>()),
        BlocProvider<AdminCubit>(create: (context) => getIt<AdminCubit>()),
        BlocProvider<DriverCubit>(create: (context) => getIt<DriverCubit>()),
        BlocProvider<ChatCubit>(create: (context) => getIt<ChatCubit>()),
        BlocProvider<NotificationCubit>(create: (context) => getIt<NotificationCubit>()),
        BlocProvider<OffersCubit>(create: (context) => getIt<OffersCubit>()),
        BlocProvider<ProfileCubit>(create: (context) => getIt<ProfileCubit>()),
      ],
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
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<HomeCubit>().initHome(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(
          child: Text('يرجى تسجيل الدخول أولاً'),
        ),
      );
    }

    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          current is HomeLoaded || current is HomeLoading || current is HomeError,
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
            body: Center(
              child: Text(
                'حدث خطأ أثناء تحميل البيانات: ${state.message}',
                style: const TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildUserScreen(UserModel user) {
    // Real-Time Block Status check for both Drivers and normal Client Users!
    if (user.driverStatus == 'blocked') {
      return const DriverBlockedScreen();
    }

    if (user.role == 'admin') {
      return const AdminDashboardScreen();
    } else if (user.role == 'driver') {
      if (user.driverStatus == 'pending') {
        return const DriverPendingScreen();
      } else {
        return DriverHomeScreen(driver: user);
      }
    } else {
      // Return the brand new marketplace home screen instead of the old client screen
      return BlocProvider<MarketHomeCubit>(
        create: (context) => getIt<MarketHomeCubit>(),
        child: const MarketHomeScreen(),
      );
    }
  }
}
