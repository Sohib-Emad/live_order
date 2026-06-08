import 'package:get_it/get_it.dart';

// Driver Orders (formerly add_order)
import 'package:live_order/features/driver_orders/data/api/add_order_api.dart';
import 'package:live_order/features/driver_orders/data/repo/add_order_repo.dart';
import 'package:live_order/features/driver_orders/logic/cubit/add_order_cubit.dart';

// Admin
import 'package:live_order/features/admin/data/api/admin_api.dart';
import 'package:live_order/features/admin/data/repo/admin_repo.dart';
import 'package:live_order/features/admin/logic/cubit/admin_cubit.dart';

// Auth
import 'package:live_order/features/auth/logic/cubit/auth_cubit.dart';
import 'package:live_order/features/auth/repo/auth_repo.dart';

// Driver Home
import 'package:live_order/features/driver_home/data/api/driver_api.dart';
import 'package:live_order/features/driver_home/data/repo/driver_repo.dart';
import 'package:live_order/features/driver_home/logic/cubit/driver_cubit.dart';

// Driver Chat
import 'package:live_order/features/driver_chat/data/api/chat_api.dart';
import 'package:live_order/features/driver_chat/data/repo/chat_repo.dart';
import 'package:live_order/features/driver_chat/logic/cubit/chat_cubit.dart';

// Driver Notifications
import 'package:live_order/features/driver_notifications/data/api/notification_api.dart';
import 'package:live_order/features/driver_notifications/data/repo/notification_repo.dart';
import 'package:live_order/features/driver_notifications/logic/cubit/notification_cubit.dart';

// Driver Offers
import 'package:live_order/features/driver_offers/data/api/offers_api.dart';
import 'package:live_order/features/driver_offers/data/repo/offers_repo.dart';
import 'package:live_order/features/driver_offers/logic/cubit/offers_cubit.dart';

// Session (formerly home)
import 'package:live_order/features/session/data/api/home_api.dart';
import 'package:live_order/features/session/data/repo/home_repo.dart';
import 'package:live_order/features/session/logic/cubit/home_cubit.dart';

// User Account
import 'package:live_order/features/user_account/data/api/user_api.dart';
import 'package:live_order/features/user_account/data/repo/user_repo.dart';
import 'package:live_order/features/user_account/logic/cubit/user_cubit.dart';

// Marketplace Feature Modules
import 'package:live_order/features/user_drivers/data/api/drivers_api.dart';
import 'package:live_order/features/user_drivers/data/repository/drivers_repository.dart';
import 'package:live_order/features/user_drivers/logic/cubit.dart';
import 'package:live_order/features/user_chat/data/api/chat_api.dart';
import 'package:live_order/features/user_chat/data/repository/chat_repository.dart';
import 'package:live_order/features/user_chat/logic/cubit.dart';
import 'package:live_order/features/user_payments/data/api/payments_api.dart';
import 'package:live_order/features/user_payments/data/repository/payments_repository.dart';
import 'package:live_order/features/user_payments/logic/cubit.dart';
import 'package:live_order/features/user_rate_driver/data/api/rate_driver_api.dart';
import 'package:live_order/features/user_rate_driver/data/repository/rate_driver_repository.dart';
import 'package:live_order/features/user_rate_driver/logic/cubit.dart';
import 'package:live_order/features/user_notifications/data/api/notifications_api.dart';
import 'package:live_order/features/user_notifications/data/repository/notifications_repository.dart';
import 'package:live_order/features/user_notifications/logic/cubit.dart';
import 'package:live_order/features/user_rewards/data/api/rewards_api.dart';
import 'package:live_order/features/user_rewards/data/repository/rewards_repository.dart';
import 'package:live_order/features/user_rewards/logic/cubit.dart';
import 'package:live_order/features/user_create_shipment/data/api/create_shipment_api.dart';
import 'package:live_order/features/user_create_shipment/data/repository/create_shipment_repository.dart';
import 'package:live_order/features/user_create_shipment/logic/cubit.dart';
import 'package:live_order/features/user_tracking/data/api/tracking_api.dart';
import 'package:live_order/features/user_tracking/data/repository/tracking_repository.dart';
import 'package:live_order/features/user_tracking/logic/cubit.dart';
import 'package:live_order/features/user_home/data/api/client_dashboard_api.dart';
import 'package:live_order/features/user_home/data/repository/client_dashboard_repository.dart';
import 'package:live_order/features/user_home/logic/cubit.dart';



final GetIt getIt = GetIt.instance;

Future<void> init() async {
  // APIs
  getIt.registerSingleton<AddOrderApi>(AddOrderApi());
  getIt.registerSingleton<AdminApi>(AdminApi());
  getIt.registerSingleton<DriverApi>(DriverApi());
  getIt.registerSingleton<HomeApi>(HomeApi());
  getIt.registerSingleton<ChatApi>(ChatApi());
  getIt.registerSingleton<NotificationApi>(NotificationApi());
  getIt.registerSingleton<OffersApi>(OffersApi());
  getIt.registerSingleton<UserApi>(UserApi());

  // Marketplace APIs
  getIt.registerSingleton<DriversApi>(DriversApi());
  getIt.registerSingleton<MarketChatApi>(MarketChatApi());
  getIt.registerSingleton<PaymentsApi>(PaymentsApi());
  getIt.registerSingleton<RateDriverApi>(RateDriverApi());
  getIt.registerSingleton<NotificationsApi>(NotificationsApi());
  getIt.registerSingleton<RewardsApi>(RewardsApi());
  getIt.registerSingleton<CreateShipmentApi>(CreateShipmentApi());
  getIt.registerSingleton<TrackingApi>(TrackingApi());
  getIt.registerSingleton<ClientDashboardApi>(ClientDashboardApi());

  // Repositories
  getIt.registerSingleton<AuthRepo>(AuthRepo());
  getIt.registerSingleton<AddOrderRepo>(AddOrderRepo(getIt<AddOrderApi>()));
  getIt.registerSingleton<AdminRepo>(AdminRepo(getIt<AdminApi>()));
  getIt.registerSingleton<DriverRepo>(DriverRepo(getIt<DriverApi>()));
  getIt.registerSingleton<HomeRepo>(HomeRepo(getIt<HomeApi>()));
  getIt.registerSingleton<ChatRepo>(ChatRepo(getIt<ChatApi>()));
  getIt.registerSingleton<NotificationRepo>(
    NotificationRepo(getIt<NotificationApi>()),
  );
  getIt.registerSingleton<OffersRepo>(OffersRepo(getIt<OffersApi>()));
  getIt.registerSingleton<UserRepository>(
    UserRepository(userApi: getIt<UserApi>()),
  );

  // Marketplace Repositories
  getIt.registerSingleton<DriversRepository>(
    DriversRepository(getIt<DriversApi>()),
  );
  getIt.registerSingleton<MarketChatRepository>(
    MarketChatRepository(getIt<MarketChatApi>()),
  );
  getIt.registerSingleton<PaymentsRepository>(
    PaymentsRepository(getIt<PaymentsApi>()),
  );
  getIt.registerSingleton<RateDriverRepository>(
    RateDriverRepository(getIt<RateDriverApi>()),
  );
  getIt.registerSingleton<NotificationsRepository>(
    NotificationsRepository(getIt<NotificationsApi>()),
  );
  getIt.registerSingleton<RewardsRepository>(
    RewardsRepository(getIt<RewardsApi>()),
  );
  getIt.registerSingleton<CreateShipmentRepository>(
    CreateShipmentRepository(getIt<CreateShipmentApi>()),
  );
  getIt.registerSingleton<TrackingRepository>(
    TrackingRepository(getIt<TrackingApi>()),
  );
  getIt.registerSingleton<ClientDashboardRepository>(
    ClientDashboardRepository(getIt<ClientDashboardApi>()),
  );

  // Cubits
  getIt.registerFactory(() => AuthCubit(authRepo: getIt<AuthRepo>()));
  getIt.registerFactory(
    () => AddOrderCubit(addOrderRepo: getIt<AddOrderRepo>()),
  );
  getIt.registerFactory(() => AdminCubit(adminRepo: getIt<AdminRepo>()));
  getIt.registerFactory(() => DriverCubit(driverRepo: getIt<DriverRepo>()));
  getIt.registerFactory(() => HomeCubit(homeRepo: getIt<HomeRepo>()));
  getIt.registerFactory(() => ChatCubit(chatRepo: getIt<ChatRepo>()));
  getIt.registerFactory(
    () => NotificationCubit(notificationRepo: getIt<NotificationRepo>()),
  );
  getIt.registerFactory(() => OffersCubit(offersRepo: getIt<OffersRepo>()));
  getIt.registerFactory(
    () => UserCubit(userRepository: getIt<UserRepository>()),
  );

  // Marketplace Cubits
  getIt.registerFactory(() => DriversCubit(getIt<DriversRepository>()));
  getIt.registerFactory(() => MarketChatCubit(getIt<MarketChatRepository>()));
  getIt.registerFactory(() => PaymentsCubit(getIt<PaymentsRepository>()));
  getIt.registerFactory(() => RateDriverCubit(getIt<RateDriverRepository>()));
  getIt.registerFactory(
    () => MarketNotificationsCubit(getIt<NotificationsRepository>()),
  );
  getIt.registerFactory(() => RewardsCubit(getIt<RewardsRepository>()));
  getIt.registerFactory(
    () => CreateShipmentCubit(getIt<CreateShipmentRepository>()),
  );
  getIt.registerFactory(() => TrackingCubit(getIt<TrackingRepository>()));
  getIt.registerFactory(
    () => ClientDashboardCubit(getIt<ClientDashboardRepository>()),
  );

}
