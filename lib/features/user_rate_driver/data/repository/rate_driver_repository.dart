// lib/features/rate_driver/data/repository/rate_driver_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_order/features/rate_driver/data/api/rate_driver_api.dart';

class RateDriverRepository {
  final RateDriverApi _api;

  RateDriverRepository(this._api);

  Future<void> submitReview({
    required String driverId,
    required double rating,
    required String comment,
    required List<String> tags,
    required String reviewerName,
  }) async {
    final reviewData = {
      'reviewerName': reviewerName,
      'rating': rating,
      'comment': comment,
      'tags': tags,
      'date': DateTime.now().toIso8601String().substring(0, 10),
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _api.submitReview(driverId, reviewData);
  }
}
