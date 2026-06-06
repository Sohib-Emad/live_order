import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/core/models/user_profile.dart';

class DashboardData {
  final List<Shipment> activeShipments;
  final List<UserProfile> topDrivers;
  final List<Shipment> recentOrders;

  const DashboardData({
    required this.activeShipments,
    required this.topDrivers,
    required this.recentOrders,
  });

  factory DashboardData.fromMaps({
    required List<Map<String, dynamic>> activeShipmentMaps,
    required List<Map<String, dynamic>> topDriverMaps,
    required List<Map<String, dynamic>> recentOrderMaps,
  }) {
    return DashboardData(
      activeShipments: activeShipmentMaps.map((m) => Shipment.fromJson(m)).toList(),
      topDrivers: topDriverMaps.map((m) => UserProfile.fromJson(m)).toList(),
      recentOrders: recentOrderMaps.map((m) => Shipment.fromJson(m)).toList(),
    );
  }
}
