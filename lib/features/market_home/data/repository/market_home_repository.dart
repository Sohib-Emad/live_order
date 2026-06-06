// lib/features/market_home/data/repository/market_home_repository.dart

import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/features/market_home/data/api/market_home_api.dart';

class MarketHomeRepository {
  final MarketHomeApi _api;

  MarketHomeRepository(this._api);

  Future<List<Shipment>> getActiveShipments() async {
    final list = await _api.getActiveShipments();
    return list.map((json) => Shipment.fromJson(json)).toList();
  }

  Future<List<UserProfile>> getTopDrivers() async {
    final list = await _api.getTopDrivers();
    return list.map((json) => UserProfile.fromJson(json)).toList();
  }

  Future<List<Shipment>> getRecentOrders() async {
    final list = await _api.getRecentOrders();
    return list.map((json) => Shipment.fromJson(json)).toList();
  }
}
