import 'package:dartz/dartz.dart';
import 'package:live_order/features/user_home/data/api/client_dashboard_api.dart';
import 'package:live_order/features/user_home/data/models/dashboard_data.dart';

class ClientDashboardRepository {
  final ClientDashboardApi _api;

  ClientDashboardRepository(this._api);

  Future<Either<String, DashboardData>> getDashboard() async {
    try {
      final active = await _api.getActiveShipments();
      final drivers = await _api.getTopDrivers();
      final recent = await _api.getRecentOrders();

      return Right(DashboardData.fromMaps(
        activeShipmentMaps: active,
        topDriverMaps: drivers,
        recentOrderMaps: recent,
      ));
    } catch (e) {
      return Left('Failed to load dashboard: $e');
    }
  }
}
