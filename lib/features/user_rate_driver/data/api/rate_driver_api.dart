// lib/features/rate_driver/data/api/rate_driver_api.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class RateDriverApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitReview(String driverId, Map<String, dynamic> reviewData) async {
    final driverDoc = _firestore.collection('users').doc(driverId);
    
    await _firestore.runTransaction((transaction) async {
      // 1. Fetch current driver document
      final snapshot = await transaction.get(driverDoc);
      if (!snapshot.exists) {
        throw Exception('Driver not found');
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final double currentRating = (data['rating'] ?? 5.0).toDouble();
      final int currentTrips = data['trips_count'] as int? ?? 0;

      // 2. Add new review
      final reviewRef = driverDoc.collection('reviews').doc();
      transaction.set(reviewRef, reviewData);

      // 3. Compute new rating and increment trips count
      final double newRating = ((currentRating * currentTrips) + (reviewData['rating'] as num)) / (currentTrips + 1);
      transaction.update(driverDoc, {
        'rating': double.parse(newRating.toStringAsFixed(2)),
        'trips_count': currentTrips + 1,
      });
    });
  }
}
