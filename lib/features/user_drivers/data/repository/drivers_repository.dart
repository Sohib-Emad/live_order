// lib/features/user_drivers/data/repository/drivers_repository.dart

import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/features/user_drivers/data/api/drivers_api.dart';

class DriversRepository {
  final DriversApi _api;

  DriversRepository(this._api);

  Future<List<UserProfile>> getDriversList() async {
    final list = await _api.getDriversList();
    return list.map((json) => UserProfile.fromJson(json)).toList();
  }
}
