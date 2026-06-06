// lib/features/market_home/logic/state.dart

import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/core/models/user_profile.dart';

abstract class MarketHomeState {}

class MarketHomeInitial extends MarketHomeState {}

class MarketHomeLoading extends MarketHomeState {}

class MarketHomeLoaded extends MarketHomeState {
  final List<Shipment> activeShipments;
  final List<UserProfile> topDrivers;
  final List<Shipment> recentOrders;

  MarketHomeLoaded({
    required this.activeShipments,
    required this.topDrivers,
    required this.recentOrders,
  });
}

class MarketHomeError extends MarketHomeState {
  final String message;
  MarketHomeError(this.message);
}
