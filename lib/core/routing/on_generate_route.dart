import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/di/di.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/features/driver_orders/ui/order_details_screen.dart';
import 'package:live_order/features/auth/logic/cubit/auth_cubit.dart';
import 'package:live_order/features/auth/login_screen.dart';
import 'package:live_order/features/auth/register_screen.dart';
import 'package:live_order/features/session/ui/home_screen.dart';
import 'package:live_order/features/onboarding/onboarding_screen.dart';

// Models
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/core/models/shipment.dart';

// Marketplace Screens
import 'package:live_order/features/user_drivers/ui/drivers_list_screen.dart';
import 'package:live_order/features/user_drivers/ui/driver_details_screen.dart';
import 'package:live_order/features/user_chat/ui/screen.dart';
import 'package:live_order/features/user_payments/ui/screen.dart';
import 'package:live_order/features/user_rate_driver/ui/screen.dart';
import 'package:live_order/features/user_notifications/ui/screen.dart';
import 'package:live_order/features/user_rewards/ui/screen.dart';
import 'package:live_order/features/user_profile/ui/screen.dart';
import 'package:live_order/features/user_create_shipment/ui/screen.dart';
import 'package:live_order/features/user_tracking/ui/screen.dart';
import 'package:live_order/features/user_account/ui/user_profile_screen.dart';
import 'package:live_order/features/user_account/logic/cubit/user_cubit.dart';

// Marketplace Cubits
import 'package:live_order/features/user_drivers/logic/cubit.dart';
import 'package:live_order/features/user_chat/logic/cubit.dart';
import 'package:live_order/features/user_payments/logic/cubit.dart';
import 'package:live_order/features/user_rate_driver/logic/cubit.dart';
import 'package:live_order/features/user_notifications/logic/cubit.dart';
import 'package:live_order/features/user_rewards/logic/cubit.dart';
import 'package:live_order/features/user_create_shipment/logic/cubit.dart';
import 'package:live_order/features/user_tracking/logic/cubit.dart';

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.onboardingScreen:
      return MaterialPageRoute(builder: (_) => const OnboardingScreen());
    case AppRoutes.loginScreen:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<AuthCubit>(),
          child: const LoginScreen(),
        ),
      );
    case AppRoutes.registerScreen:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<AuthCubit>(),
          child: const RegisterScreen(),
        ),
      );
    case AppRoutes.homeScreen:
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    case AppRoutes.orderDetailsScreen:
      final args = settings.arguments;
      if (args is Map) {
        final order = args['order'] as Shipment;
        final isDriver = args['isDriver'] as bool? ?? false;
        return MaterialPageRoute(
          builder: (_) => OrderDetailsScreen(order: order, isDriver: isDriver),
        );
      }
      final order = args as Shipment;
      return MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(order: order),
      );
    case AppRoutes.userProfileScreen:
      final user = settings.arguments as UserProfile;
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<UserCubit>(),
          child: UserProfileScreen(user: user),
        ),
      );
    case AppRoutes.driversList:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<DriversCubit>(),
          child: const DriversListScreen(),
        ),
      );
    case AppRoutes.driverDetails:
      final driver = settings.arguments as UserProfile;
      return MaterialPageRoute(
        builder: (_) => DriverDetailsScreen(driver: driver),
      );
    case AppRoutes.marketChat:
      final driver = settings.arguments as UserProfile;
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<MarketChatCubit>(),
          child: MarketChatScreen(driver: driver),
        ),
      );
    case AppRoutes.payments:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<PaymentsCubit>(),
          child: const PaymentsScreen(),
        ),
      );
    case AppRoutes.rateDriver:
      final driver = settings.arguments as UserProfile;
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<RateDriverCubit>(),
          child: RateDriverScreen(driver: driver),
        ),
      );
    case AppRoutes.notifications:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<MarketNotificationsCubit>(),
          child: const MarketNotificationsScreen(),
        ),
      );
    case AppRoutes.rewards:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<RewardsCubit>(),
          child: const RewardsScreen(),
        ),
      );
    case AppRoutes.marketProfile:
      return MaterialPageRoute(builder: (_) => const MarketProfileScreen());
    case AppRoutes.createShipment:
      final driver = settings.arguments as UserProfile?;
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<CreateShipmentCubit>(),
          child: CreateShipmentScreen(preselectedDriver: driver),
        ),
      );
    case AppRoutes.shipmentTracking:
      final shipment = settings.arguments;
      print(
        "DEBUG NAVIGATOR: Received shipment = $shipment, type = ${shipment?.runtimeType}",
      );
      if (shipment is Shipment) {
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<TrackingCubit>(),
            child: ShipmentTrackingScreen(shipment: shipment),
          ),
        );
      }
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
            child: Text(
              'No shipment selected for tracking. Received: $shipment (type: ${shipment?.runtimeType})',
            ),
          ),
        ),
      );
    default:
      return null;
  }
}
