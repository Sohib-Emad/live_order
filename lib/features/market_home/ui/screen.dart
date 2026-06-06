// lib/features/market_home/ui/screen.dart

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/di/di.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/features/market_home/logic/cubit.dart';
import 'package:live_order/features/market_home/logic/state.dart';
import 'package:live_order/features/market_home/widget/active_shipment_card.dart';
import 'package:live_order/features/market_home/widget/driver_card.dart';
import 'package:live_order/features/market_home/widget/recent_order_item.dart';
import 'package:live_order/shared/widgets/empty_state.dart';
import 'package:live_order/shared/widgets/loading_shimmer.dart';
import 'package:live_order/shared/widgets/section_header.dart';
import 'package:live_order/features/home/logic/cubit/home_cubit.dart';

// Tab screen imports
import 'package:live_order/features/create_shipment/logic/cubit.dart';
import 'package:live_order/features/create_shipment/ui/screen.dart';
import 'package:live_order/features/payments/logic/cubit.dart';
import 'package:live_order/features/payments/ui/screen.dart';
import 'package:live_order/features/market_profile/ui/screen.dart';

class MarketHomeScreen extends StatefulWidget {
  const MarketHomeScreen({super.key});

  @override
  State<MarketHomeScreen> createState() => _MarketHomeScreenState();
}

class _MarketHomeScreenState extends State<MarketHomeScreen> {
  bool _showPromo = true;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<MarketHomeCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppDesign.surface,
        appBar: _currentTabIndex == 0
            ? AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                title: BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    String name = 'مستخدم';
                    if (state is HomeLoaded) {
                      name = state.user.name;
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'صباح الخير،',
                          style: AppDesign.body(
                            color: AppDesign.textSecondary,
                            fontSize: 12.0,
                          ),
                        ),
                        Text(name, style: AppDesign.heading(fontSize: 16.0)),
                      ],
                    );
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.person_outline_rounded,
                      color: AppDesign.textPrimary,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentTabIndex = 3; // Switch to profile tab
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: AppDesign.space16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            color: AppDesign.textPrimary,
                          ),
                          onPressed: () => context.pushNamed('notifications'),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: CircleAvatar(
                            radius: 7,
                            backgroundColor: AppDesign.danger,
                            child: Text(
                              '3',
                              style: AppDesign.body(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : null,
        body: _buildBody(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: (index) {
            setState(() {
              _currentTabIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppDesign.primary,
          unselectedItemColor: AppDesign.textSecondary,
          selectedLabelStyle: AppDesign.body(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppDesign.primary,
          ),
          unselectedLabelStyle: AppDesign.body(
            fontSize: 11,
            color: AppDesign.textSecondary,
          ),
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_rounded),
              label: 'طلب شحنة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_rounded),
              label: 'المحفظة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentTabIndex) {
      case 0:
        return RefreshIndicator(
          onRefresh: () => context.read<MarketHomeCubit>().loadDashboard(),
          color: AppDesign.primary,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Promo Banner
                if (_showPromo) _buildPromoBanner(),

                // Quick Actions
                _buildQuickActions(),

                const SizedBox(height: AppDesign.space16),

                BlocBuilder<MarketHomeCubit, MarketHomeState>(
                  builder: (context, state) {
                    if (state is MarketHomeLoading) {
                      return _buildLoadingState();
                    } else if (state is MarketHomeError) {
                      return EmptyState(
                        icon: Icons.error_outline_rounded,
                        title: 'حدث خطأ ما',
                        subtitle: state.message,
                        actionLabel: 'إعادة المحاولة',
                        onActionTap: () =>
                            context.read<MarketHomeCubit>().loadDashboard(),
                      );
                    } else if (state is MarketHomeLoaded) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Active Shipments
                          if (state.activeShipments.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDesign.space16,
                              ),
                              child: SectionHeader(
                                title: 'الشحنات النشطة',
                                actionLabel: 'عرض الكل',
                                onActionTap: () {},
                              ),
                            ),
                            const SizedBox(height: AppDesign.space12),
                            SizedBox(
                              height: 180.h,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.only(
                                  right: AppDesign.space16,
                                ),
                                itemCount: state.activeShipments.length,
                                itemBuilder: (context, index) {
                                  final item = state.activeShipments[index];
                                  return ActiveShipmentCard(
                                    shipment: item,
                                    onTap: () {
                                      context.pushNamed(
                                        'shipment_tracking',
                                        extra: item,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: AppDesign.space24),
                          ],

                          // Top Rated Drivers
                          if (state.topDrivers.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDesign.space16,
                              ),
                              child: SectionHeader(
                                title: 'السائقين الأعلى تقييماً',
                                actionLabel: 'عرض الكل',
                                onActionTap: () =>
                                    context.pushNamed('drivers_list'),
                              ),
                            ),
                            const SizedBox(height: AppDesign.space12),
                            SizedBox(
                              height: 190.h,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.only(
                                  right: AppDesign.space16,
                                ),
                                itemCount: state.topDrivers.length,
                                itemBuilder: (context, index) {
                                  final driver = state.topDrivers[index];
                                  return DriverCard(
                                    driver: driver,
                                    onBookTap: () =>
                                        context.pushNamed('create_shipment'),
                                    onTap: () => context.pushNamed(
                                      'driver_details',
                                      extra: driver,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: AppDesign.space24),
                          ],

                          // Recent Orders
                          if (state.recentOrders.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDesign.space16,
                              ),
                              child: SectionHeader(
                                title: 'الطلبات الأخيرة',
                                actionLabel: 'السجل',
                                onActionTap: () {},
                              ),
                            ),
                            const SizedBox(height: AppDesign.space12),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDesign.space16,
                              ),
                              itemCount: state.recentOrders.length,
                              itemBuilder: (context, index) {
                                final item = state.recentOrders[index];
                                return RecentOrderItem(
                                  shipment: item,
                                  onTap: () {},
                                );
                              },
                            ),
                          ],
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: AppDesign.space32),
              ],
            ),
          ),
        );
      case 1:
        return BlocProvider<CreateShipmentCubit>(
          create: (context) => getIt<CreateShipmentCubit>(),
          child: const CreateShipmentScreen(),
        );
      case 2:
        return BlocProvider<PaymentsCubit>(
          create: (context) => getIt<PaymentsCubit>(),
          child: const PaymentsScreen(),
        );
      case 3:
        return const MarketProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.all(AppDesign.space16),
      padding: const EdgeInsets.all(AppDesign.space16),
      decoration: BoxDecoration(
        color: AppDesign.primary,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'عرض توصيل خاص!',
                      style: AppDesign.heading(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: AppDesign.space4),
                    Text(
                      'احصل على خصم 20% على أول شحنة بضائع كبيرة هذا الأسبوع.',
                      style: AppDesign.body(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDesign.space16),
              const Icon(Icons.percent_rounded, color: Colors.white, size: 36),
            ],
          ),
          Positioned(
            left: 0,
            top: 0,
            child: GestureDetector(
              onTap: () => setState(() => _showPromo = false),
              child: Icon(
                Icons.close_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'label': 'شحنة جديدة',
        'icon': Icons.add_box_rounded,
        'route': 'create_shipment',
      },
      {
        'label': 'طلباتي',
        'icon': Icons.local_shipping_rounded,
        'route': 'drivers_list',
      },
      {
        'label': 'تتبع الشحنة',
        'icon': Icons.map_rounded,
        'route': 'shipment_tracking',
      },
      {
        'label': 'المكافآت',
        'icon': Icons.wallet_giftcard_rounded,
        'route': 'rewards',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesign.space16,
        vertical: AppDesign.space8,
      ),
      child: Row(
        children: actions.map((act) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
                final route = act['route'] as String;
                if (route == 'shipment_tracking') {
                  _handleTrackAction();
                } else if (route == 'create_shipment') {
                  setState(() {
                    _currentTabIndex = 1; // Switch to Create Shipment tab
                  });
                } else if (route == 'rewards') {
                  setState(() {
                    _currentTabIndex = 3; // Switch to Profile/Rewards tab
                  });
                } else {
                  context.pushNamed(route);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDesign.radius12),
                      border: Border.all(color: AppDesign.border, width: 1.0),
                    ),
                    child: Icon(
                      act['icon'] as IconData,
                      color: AppDesign.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: AppDesign.space8),
                  Text(
                    act['label'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppDesign.body(
                      color: AppDesign.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDesign.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LoadingShimmer(width: 150, height: 20),
          const SizedBox(height: AppDesign.space16),
          Row(
            children: const [
              Expanded(
                child: LoadingShimmer(
                  width: double.infinity,
                  height: 120,
                  borderRadius: 12,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: LoadingShimmer(
                  width: double.infinity,
                  height: 120,
                  borderRadius: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesign.space24),
          const LoadingShimmer(width: 150, height: 20),
          const SizedBox(height: AppDesign.space16),
          const LoadingShimmer(
            width: double.infinity,
            height: 80,
            borderRadius: 12,
          ),
          const SizedBox(height: 12),
          const LoadingShimmer(
            width: double.infinity,
            height: 80,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }

  void _handleTrackAction() {
    final homeState = context.read<MarketHomeCubit>().state;
    if (homeState is MarketHomeLoaded) {
      if (homeState.activeShipments.isEmpty) {
        AnimatedSnackBar.material(
          'ليس لديك أي شحنات نشطة لتتبعها حالياً.',
          type: AnimatedSnackBarType.warning,
          mobileSnackBarPosition: MobileSnackBarPosition.bottom,
        ).show(context);
      } else if (homeState.activeShipments.length == 1) {
        context.pushNamed(
          'shipment_tracking',
          extra: homeState.activeShipments.first,
        );
      } else {
        _showShipmentSelectionSheet(homeState.activeShipments);
      }
    } else {
      AnimatedSnackBar.material(
        'جاري تحميل لوحة التحكم. يرجى الانتظار لحظة.',
        type: AnimatedSnackBarType.info,
        mobileSnackBarPosition: MobileSnackBarPosition.bottom,
      ).show(context);
    }
  }

  void _showShipmentSelectionSheet(List<Shipment> shipments) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDesign.radius24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDesign.space24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('تتبع الشحنة', style: AppDesign.heading(fontSize: 18.0)),
                const SizedBox(height: AppDesign.space4),
                Text(
                  'اختر شحنة نشطة لعرض التتبع المباشر.',
                  style: AppDesign.body(color: AppDesign.textSecondary),
                ),
                const SizedBox(height: AppDesign.space16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: shipments.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: AppDesign.border, height: 1),
                    itemBuilder: (context, index) {
                      final item = shipments[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(AppDesign.space8),
                          decoration: BoxDecoration(
                            color: AppDesign.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppDesign.radius8,
                            ),
                          ),
                          child: const Icon(
                            Icons.local_shipping_rounded,
                            color: AppDesign.primary,
                          ),
                        ),
                        title: Text(
                          item.cargoType,
                          style: AppDesign.body(
                            color: AppDesign.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'إلى: ${item.dropAddress}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppDesign.body(
                            color: AppDesign.textSecondary,
                            fontSize: 12.0,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppDesign.textSecondary,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          context.pushNamed('shipment_tracking', extra: item);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
