// lib/features/user_rate_driver/data/api/rate_driver_api.dart

import 'package:live_order/core/services/supabase_service.dart';

class RateDriverApi {
  final supabase = SupabaseService.instance.client;

  Future<void> submitReview(String driverId, Map<String, dynamic> reviewData) async {
    final driverData = await supabase
        .from('users')
        .select()
        .eq('uid', driverId)
        .single() as Map<String, dynamic>?;

    if (driverData == null) {
      throw Exception('Driver not found');
    }

    final double currentRating = (driverData['rating'] ?? 5.0).toDouble();
    final int currentTrips = driverData['trips_count'] as int? ?? 0;

    reviewData['driver_id'] = driverId;
    await supabase.from('reviews').insert(reviewData);

    final double newRating = ((currentRating * currentTrips) + (reviewData['rating'] as num)) / (currentTrips + 1);
    await supabase.from('users').update({
      'rating': double.parse(newRating.toStringAsFixed(2)),
      'trips_count': currentTrips + 1,
    }).eq('uid', driverId);
  }
}
