import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/widgets/rating_stars.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'How was your delivery service?',
          style: AppDesign.body(
            color: AppDesign.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14.5,
          ),
        ),
        const SizedBox(height: AppDesign.space12),
        RatingStars(
          rating: rating,
          starSize: 32.0,
          onRatingChanged: onRatingChanged,
        ),
      ],
    );
  }
}
