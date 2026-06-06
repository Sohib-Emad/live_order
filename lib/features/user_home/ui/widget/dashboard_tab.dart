import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/core/widgets/empty_state.dart';
import 'package:live_order/features/user_home/logic/cubit.dart';
import 'package:live_order/features/user_home/logic/state.dart';
import 'package:live_order/features/user_home/ui/widget/promo_banner.dart';
import 'package:live_order/features/user_home/ui/widget/quick_actions.dart';
import 'package:live_order/features/user_home/ui/widget/active_shipments_section.dart';
import 'package:live_order/features/user_home/ui/widget/top_drivers_section.dart';
import 'package:live_order/features/user_home/ui/widget/recent_orders_section.dart';
import 'package:live_order/features/user_home/ui/widget/dashboard_loading_shimmer.dart';

class DashboardTab extends StatelessWidget {
  final bool showPromo;
  final VoidCallback onDismissPromo;
  final VoidCallback onNewShipment;
  final VoidCallback onViewAllDrivers;
  final VoidCallback onTrackShipment;
  final VoidCallback onRewards;

  const DashboardTab({
    super.key,
    required this.showPromo,
    required this.onDismissPromo,
    required this.onNewShipment,
    required this.onViewAllDrivers,
    required this.onTrackShipment,
    required this.onRewards,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<ClientDashboardCubit>().loadDashboard(),
      color: AppDesign.primary,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showPromo) PromoBanner(onDismiss: onDismissPromo),
            QuickActions(
              onNewShipment: onNewShipment,
              onMyOrders: onViewAllDrivers,
              onTrackShipment: onTrackShipment,
              onRewards: onRewards,
            ),
            const SizedBox(height: AppDesign.space16),
            BlocBuilder<ClientDashboardCubit, ClientDashboardState>(
              builder: (context, state) {
                if (state is ClientDashboardLoading) {
                  return const DashboardLoadingShimmer();
                } else if (state is ClientDashboardError) {
                  return EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'حدث خطأ ما',
                    subtitle: state.message,
                    actionLabel: 'إعادة المحاولة',
                    onActionTap: () => context.read<ClientDashboardCubit>().loadDashboard(),
                  );
                } else if (state is ClientDashboardLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ActiveShipmentsSection(
                        shipments: state.activeShipments,
                        onShipmentTap: (item) => Navigator.pushNamed(context, AppRoutes.shipmentTracking, arguments: item),
                        onNewShipmentTap: onNewShipment,
                      ),
                      const SizedBox(height: AppDesign.space24),
                      TopDriversSection(
                        drivers: state.topDrivers,
                        onViewAll: onViewAllDrivers,
                        onDriverTap: (driver) => Navigator.pushNamed(context, AppRoutes.driverDetails, arguments: driver),
                      ),
                      const SizedBox(height: AppDesign.space24),
                      RecentOrdersSection(
                        orders: state.recentOrders,
                        onOrderTap: (item) => Navigator.pushNamed(context, AppRoutes.shipmentTracking, arguments: item),
                      ),
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
  }
}
