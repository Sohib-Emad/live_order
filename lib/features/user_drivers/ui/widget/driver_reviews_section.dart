import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/core/widgets/rating_stars.dart';

class DriverReviewsSection extends StatelessWidget {
  final List<DriverReview> reviews;

  const DriverReviewsSection({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppDesign.space24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDesign.radius12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              color: AppDesign.textSecondary.withOpacity(0.3),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'لا توجد تقييمات لهذا السائق بعد.',
              style: AppDesign.body(
                color: AppDesign.textSecondary,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return _buildReviewTile(review);
      },
    );
  }

  Widget _buildReviewTile(DriverReview review) {
    final Color avatarBg = _getAvatarColor(review.reviewerName);
    final String initial = review.reviewerName.isNotEmpty
        ? review.reviewerName.substring(0, 1)
        : 'ع';

    return Container(
      margin: const EdgeInsets.only(bottom: AppDesign.space8),
      padding: const EdgeInsets.all(AppDesign.space12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: avatarBg.withOpacity(0.1),
                child: Text(
                  initial,
                  style: TextStyle(
                    color: avatarBg,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: AppDesign.body(
                        color: AppDesign.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.0,
                      ),
                    ),
                    Row(
                      children: [
                        RatingStars(rating: review.rating, starSize: 11),
                        const SizedBox(width: 6),
                        Text(
                          review.rating.toStringAsFixed(1),
                          style: AppDesign.body(
                            color: AppDesign.textSecondary,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                review.date,
                style: AppDesign.body(
                  color: AppDesign.textSecondary,
                  fontSize: 11.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesign.space8),
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text(
              review.comment,
              style: AppDesign.body(
                color: AppDesign.textPrimary,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final int hash = name.hashCode;
    final List<Color> colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
    ];
    return colors[hash.abs() % colors.length];
  }
}
