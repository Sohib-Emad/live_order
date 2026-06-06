// lib/features/user_home/logic/state.dart

import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/core/models/user_profile.dart';

abstract class ClientDashboardState {}

class ClientDashboardInitial extends ClientDashboardState {}

class ClientDashboardLoading extends ClientDashboardState {}

class ClientDashboardLoaded extends ClientDashboardState {
  final List<Shipment> activeShipments;
  final List<UserProfile> topDrivers;
  final List<Shipment> recentOrders;

  ClientDashboardLoaded({
    required this.activeShipments,
    required this.topDrivers,
    required this.recentOrders,
  });
}

class ClientDashboardError extends ClientDashboardState {
  final String message;
  ClientDashboardError(this.message);
}
