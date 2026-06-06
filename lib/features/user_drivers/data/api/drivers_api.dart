// lib/features/user_drivers/data/api/drivers_api.dart

import 'package:live_order/core/services/supabase_service.dart';

class DriversApi {
  final supabase = SupabaseService.instance.client;

  Future<List<Map<String, dynamic>>> getDriversList() async {
    try {
      final data = await supabase
          .from('users')
          .select()
          .eq('role', 'driver');

      final drivers = data
          .cast<Map<String, dynamic>>()
          .toList()
        ..sort(
          (a, b) => ((b['rating'] as num?)?.toDouble() ?? 0)
              .compareTo((a['rating'] as num?)?.toDouble() ?? 0),
        );
      return drivers;
    } catch (e) {
      throw Exception('Failed to fetch drivers list from database: $e');
    }
  }
}
