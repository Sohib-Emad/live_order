import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:live_order/core/di/di.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/features/add_order/logic/cubit/add_order_cubit.dart';
import 'package:live_order/features/add_order/models/order_model.dart';
import 'package:live_order/features/add_order/ui/add_order_screen.dart';
import 'package:live_order/features/add_order/ui/order_details_screen.dart';
import 'package:live_order/features/auth/logic/cubit/auth_cubit.dart';
import 'package:live_order/features/auth/login_screen.dart';
import 'package:live_order/features/auth/register_screen.dart';
import 'package:live_order/features/home/ui/home_screen.dart';
import 'package:live_order/features/onboarding/onboarding_screen.dart';

// Models
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/core/models/shipment.dart';

// Marketplace Screens
import 'package:live_order/features/drivers_list/ui/drivers_list_screen.dart';
import 'package:live_order/features/drivers_list/ui/driver_details_screen.dart';
import 'package:live_order/features/market_chat/ui/screen.dart';
import 'package:live_order/features/payments/ui/screen.dart';
import 'package:live_order/features/rate_driver/ui/screen.dart';
import 'package:live_order/features/notifications/ui/screen.dart';
import 'package:live_order/features/rewards/ui/screen.dart';
import 'package:live_order/features/market_profile/ui/screen.dart';
import 'package:live_order/features/create_shipment/ui/screen.dart';
import 'package:live_order/features/tracking/ui/screen.dart';
import 'package:live_order/features/user/ui/user_profile_screen.dart';
import 'package:live_order/features/user/logic/cubit/user_cubit.dart';
import 'package:live_order/features/add_order/models/user_model.dart';

// Marketplace Cubits
import 'package:live_order/features/drivers_list/logic/cubit.dart';
import 'package:live_order/features/market_chat/logic/cubit.dart';
import 'package:live_order/features/payments/logic/cubit.dart';
import 'package:live_order/features/rate_driver/logic/cubit.dart';
import 'package:live_order/features/notifications/logic/cubit.dart';
import 'package:live_order/features/rewards/logic/cubit.dart';
import 'package:live_order/features/create_shipment/logic/cubit.dart';
import 'package:live_order/features/tracking/logic/cubit.dart';

class RouterGenerationConfig {
  static GoRouter goRouter = GoRouter(
    initialLocation: AppRoutes.onboardingScreen,
    routes: [
      GoRoute(
        name: AppRoutes.onboardingScreen,
        path: AppRoutes.onboardingScreen,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        name: AppRoutes.loginScreen,
        path: AppRoutes.loginScreen,
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<AuthCubit>(),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        name: AppRoutes.registerScreen,
        path: AppRoutes.registerScreen,
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<AuthCubit>(),
          child: const RegisterScreen(),
        ),
      ),

      GoRoute(
        name: AppRoutes.homeScreen,
        path: AppRoutes.homeScreen,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        name: AppRoutes.addOrderScreen,
        path: AppRoutes.addOrderScreen,
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<AddOrderCubit>(),
          child: const AddOrderScreen(),
        ),
      ),
      GoRoute(
        name: AppRoutes.orderDetailsScreen,
        path: AppRoutes.orderDetailsScreen,
        builder: (context, state) {
          if (state.extra is Map) {
            final extraMap = state.extra as Map;
            final order = extraMap['order'] as OrderModel;
            final isDriver = extraMap['isDriver'] as bool? ?? false;
            return OrderDetailsScreen(order: order, isDriver: isDriver);
          }
          final order = state.extra as OrderModel;
          return OrderDetailsScreen(order: order);
        },
      ),
      GoRoute(
        name: AppRoutes.userProfileScreen,
        path: AppRoutes.userProfileScreen,
        builder: (context, state) {
          final user = state.extra as UserModel;
          return BlocProvider(
            create: (context) => getIt<UserCubit>(),
            child: UserProfileScreen(user: user),
          );
        },
      ),

      // New Marketplace Named Routes
      GoRoute(
        name: 'drivers_list',
        path: '/driversList',
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<DriversCubit>(),
          child: const DriversListScreen(),
        ),
      ),
      GoRoute(
        name: 'driver_details',
        path: '/driverDetails',
        builder: (context, state) {
          final driver = state.extra as UserProfile;
          return DriverDetailsScreen(driver: driver);
        },
      ),
      GoRoute(
        name: 'market_chat',
        path: '/marketChat',
        builder: (context, state) {
          final driver = state.extra as UserProfile;
          return BlocProvider(
            create: (context) => getIt<MarketChatCubit>(),
            child: MarketChatScreen(driver: driver),
          );
        },
      ),
      GoRoute(
        name: 'payments',
        path: '/payments',
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<PaymentsCubit>(),
          child: const PaymentsScreen(),
        ),
      ),
      GoRoute(
        name: 'rate_driver',
        path: '/rateDriver',
        builder: (context, state) {
          final driver = state.extra as UserProfile;
          return BlocProvider(
            create: (context) => getIt<RateDriverCubit>(),
            child: RateDriverScreen(driver: driver),
          );
        },
      ),
      GoRoute(
        name: 'notifications',
        path: '/notifications',
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<MarketNotificationsCubit>(),
          child: const MarketNotificationsScreen(),
        ),
      ),
      GoRoute(
        name: 'rewards',
        path: '/rewards',
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<RewardsCubit>(),
          child: const RewardsScreen(),
        ),
      ),
      GoRoute(
        name: 'market_profile',
        path: '/marketProfile',
        builder: (context, state) => const MarketProfileScreen(),
      ),
      GoRoute(
        name: 'create_shipment',
        path: '/createShipment',
        builder: (context, state) {
          final driver = state.extra as UserProfile?;
          return BlocProvider(
            create: (context) => getIt<CreateShipmentCubit>(),
            child: CreateShipmentScreen(preselectedDriver: driver),
          );
        },
      ),
      GoRoute(
        name: 'shipment_tracking',
        path: '/shipmentTracking',
        builder: (context, state) {
          if (state.extra is Shipment) {
            final shipment = state.extra as Shipment;
            return BlocProvider(
              create: (context) => getIt<TrackingCubit>(),
              child: ShipmentTrackingScreen(shipment: shipment),
            );
          }
          return const Scaffold(
            body: Center(
              child: Text('No shipment selected for tracking.'),
            ),
          );
        },
      ),
    ],
  );
}
