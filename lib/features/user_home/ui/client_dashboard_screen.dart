import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/di/di.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/features/user_home/logic/cubit.dart';
import 'package:live_order/features/user_home/ui/widget/home_app_bar.dart';
import 'package:live_order/features/user_home/ui/widget/home_bottom_nav.dart';
import 'package:live_order/features/user_home/ui/widget/dashboard_tab.dart';
import 'package:live_order/features/user_home/ui/widget/create_shipment_tab.dart';
import 'package:live_order/features/user_home/ui/widget/shipment_selection_sheet.dart';
import 'package:live_order/features/user_payments/logic/cubit.dart';
import 'package:live_order/features/user_payments/ui/screen.dart';
import 'package:live_order/features/user_profile/ui/screen.dart';
import 'package:live_order/features/session/logic/cubit/home_cubit.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  bool _showPromo = true;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<ClientDashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocListener<HomeCubit, HomeState>(
        listenWhen: (previous, current) {
          if (previous is HomeLoaded && current is HomeLoaded) {
            final prevOrders = previous.orders;
            final currOrders = current.orders;
            if (prevOrders.length != currOrders.length) return true;
            for (int i = 0; i < prevOrders.length; i++) {
              final prevO = prevOrders[i];
              final currO = currOrders.firstWhere((o) => o.id == prevO.id, orElse: () => prevO);
              if (currO.status != prevO.status) return true;
            }
            return false;
          }
          return previous is! HomeLoaded && current is HomeLoaded;
        },
        listener: (context, state) {
          if (state is HomeLoaded) {
            context.read<ClientDashboardCubit>().loadDashboard();
          }
        },
        child: Scaffold(
          backgroundColor: AppDesign.surface,
          appBar: _currentTabIndex == 0 ? const HomeAppBar() : null,
          body: _buildBody(),
          bottomNavigationBar: HomeBottomNav(
            currentIndex: _currentTabIndex,
            onTap: (index) => setState(() => _currentTabIndex = index),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentTabIndex) {
      case 0:
        return DashboardTab(
          showPromo: _showPromo,
          onDismissPromo: () => setState(() => _showPromo = false),
          onNewShipment: () => setState(() => _currentTabIndex = 1),
          onViewAllDrivers: () => Navigator.pushNamed(context, AppRoutes.driversList),
          onTrackShipment: _handleTrackAction,
          onRewards: () => setState(() => _currentTabIndex = 3),
        );
      case 1:
        return CreateShipmentTab(
          onTrackShipment: () {
            setState(() => _currentTabIndex = 0);
            _handleTrackAction();
          },
          onGoBack: () => setState(() => _currentTabIndex = 0),
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

  void _handleTrackAction() {
    final homeState = context.read<HomeCubit>().state;
    if (homeState is HomeLoaded) {
      final active = homeState.orders.where((o) =>
        o.status == 'Waiting Driver' ||
        o.status == 'Accepted' ||
        o.status == 'In Transit'
      ).toList();
      if (active.isEmpty) {
        AnimatedSnackBar.material(
          'ليس لديك أي شحنات نشطة لتتبعها حالياً.',
          type: AnimatedSnackBarType.warning,
          mobileSnackBarPosition: MobileSnackBarPosition.bottom,
        ).show(context);
      } else if (active.length == 1) {
        Navigator.pushNamed(context, AppRoutes.shipmentTracking, arguments: active.first);
      } else {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppDesign.radius24)),
          ),
          builder: (context) => ShipmentSelectionSheet(
            shipments: active,
            onShipmentSelected: (item) => Navigator.pushNamed(context, AppRoutes.shipmentTracking, arguments: item),
          ),
        );
      }
    } else {
      AnimatedSnackBar.material(
        'جاري تحميل لوحة التحكم. يرجى الانتظار لحظة.',
        type: AnimatedSnackBarType.info,
        mobileSnackBarPosition: MobileSnackBarPosition.bottom,
      ).show(context);
    }
  }
}
