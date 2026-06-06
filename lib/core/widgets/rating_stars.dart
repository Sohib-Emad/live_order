// lib/shared/widgets/rating_stars.dart

import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double starSize;
  final ValueChanged<double>? onRatingChanged;

  const RatingStars({
    super.key,
    required this.rating,
    this.starSize = 18.0,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = onRatingChanged != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final double starValue = index + 1.0;
        final bool isFilled = rating >= starValue;
        final bool isHalf = rating >= starValue - 0.5 && rating < starValue;

        Widget icon = Icon(
          isFilled
              ? Icons.star_rounded
              : (isHalf ? Icons.star_half_rounded : Icons.star_outline_rounded),
          color: const Color(0xFFFFB300),
          size: starSize,
        );

        if (isInteractive) {
          return GestureDetector(
            onTap: () => onRatingChanged!(starValue),
            child: icon,
          );
        }
        return icon;
      }),
    );
  }
}
