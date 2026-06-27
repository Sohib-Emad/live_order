// lib/features/user_home/logic/state.dart

import 'package:equatable/equatable.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/core/models/user_profile.dart';

abstract class ClientDashboardState extends Equatable {
  const ClientDashboardState();

  @override
  List<Object?> get props => [];
}

class ClientDashboardInitial extends ClientDashboardState {
  const ClientDashboardInitial();
}

class ClientDashboardLoading extends ClientDashboardState {
  const ClientDashboardLoading();
}

class ClientDashboardLoaded extends ClientDashboardState {
  final List<Shipment> activeShipments;
  final List<UserProfile> topDrivers;
  final List<Shipment> recentOrders;

  const ClientDashboardLoaded({
    required this.activeShipments,
    required this.topDrivers,
    required this.recentOrders,
  });

  @override
  List<Object?> get props => [activeShipments, topDrivers, recentOrders];
}

class ClientDashboardError extends ClientDashboardState {
  final String message;

  const ClientDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
