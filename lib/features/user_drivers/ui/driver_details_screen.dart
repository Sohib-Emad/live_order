// lib/features/drivers_list/ui/driver_details_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/shared/widgets/app_button.dart';
import 'package:live_order/shared/widgets/avatar_widget.dart';
import 'package:live_order/shared/widgets/rating_stars.dart';

class DriverDetailsScreen extends StatelessWidget {
  final UserProfile driver;

  const DriverDetailsScreen({
    super.key,
    required this.driver,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.surface,
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Image & Gradient
                _buildHeader(context),

                Padding(
                  padding: const EdgeInsets.all(AppDesign.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Row
                      _buildStatsRow(),

                      const SizedBox(height: AppDesign.space24),

                      // About Section
                      Text(
                        'About Driver',
                        style: AppDesign.heading(fontSize: 16.0),
                      ),
                      const SizedBox(height: AppDesign.space8),
                      Container(
                        padding: const EdgeInsets.all(AppDesign.space16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppDesign.radius12),
                          border: Border.all(color: AppDesign.border, width: 1.0),
                        ),
                        child: Text(
                          driver.about.isNotEmpty
                              ? driver.about
                              : 'Experienced and reliable cargo driver. Committed to safe, punctual delivery and high client satisfaction.',
                          style: AppDesign.body(color: AppDesign.textPrimary, fontSize: 13.5),
                        ),
                      ),

                      const SizedBox(height: AppDesign.space24),

                      // Reviews Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Reviews (${driver.reviews.length})',
                            style: AppDesign.heading(fontSize: 16.0),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.orange, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                driver.rating.toStringAsFixed(2),
                                style: AppDesign.body(
                                  color: AppDesign.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDesign.space12),

                      if (driver.reviews.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: AppDesign.space32),
                          alignment: Alignment.center,
                          child: Text(
                            'No reviews yet for this driver.',
                            style: AppDesign.body(color: AppDesign.textSecondary),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: driver.reviews.length,
                          itemBuilder: (context, index) {
                            final review = driver.reviews[index];
                            return _buildReviewTile(review);
                          },
                        ),

                      const SizedBox(height: 90), // Space for bottom action bar
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Custom Sticky Bottom Action Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesign.space16,
                vertical: AppDesign.space12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                  top: BorderSide(color: AppDesign.border, width: 1.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () {
                          // Push to chat screen or similar
                          context.pushNamed('market_chat', extra: driver);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppDesign.border, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDesign.radius8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Icon(Icons.chat_bubble_outline_rounded, color: AppDesign.primary),
                      ),
                    ),
                    const SizedBox(width: AppDesign.space12),
                    Expanded(
                      flex: 3,
                      child: AppButton(
                        label: 'Request This Driver',
                        onTap: () {
                          context.pushNamed('create_shipment', extra: driver);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        // Cover Photo (warm logistics primary blue gradient)
        Container(
          height: 180,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppDesign.primary, Color(0xFF0F3DAB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Back Button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 4.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),

        // Profile Info overlaying header
        Container(
          margin: const EdgeInsets.only(top: 120),
          padding: const EdgeInsets.symmetric(horizontal: AppDesign.space16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(color: Colors.white, width: 4.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AvatarWidget(
                  imageUrl: driver.imageUrl,
                  fallbackName: driver.name,
                  radius: 32,
                ),
              ),
              const SizedBox(width: AppDesign.space12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: AppDesign.heading(fontSize: 18.0),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.local_shipping_rounded, color: AppDesign.textSecondary, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              driver.vehicleType ?? 'Logistics Carrier',
                              style: AppDesign.body(color: AppDesign.textSecondary, fontSize: 12.0),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.only(top: AppDesign.space24),
      padding: const EdgeInsets.symmetric(vertical: AppDesign.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: AppDesign.border, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatColumn('Deliveries', '${driver.totalDeliveries}+'),
          Container(height: 30, width: 1, color: AppDesign.border),
          _buildStatColumn('Years Active', '${driver.yearsActive} Yrs'),
          Container(height: 30, width: 1, color: AppDesign.border),
          _buildStatColumn('Plate Number', driver.vehiclePlate ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppDesign.heading(fontSize: 15.0),
        ),
        const SizedBox(height: AppDesign.space4),
        Text(
          label,
          style: AppDesign.body(fontSize: 11.5, color: AppDesign.textSecondary),
        ),
      ],
    );
  }

  Widget _buildReviewTile(DriverReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDesign.space12),
      padding: const EdgeInsets.all(AppDesign.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: AppDesign.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.reviewerName,
                style: AppDesign.body(
                  color: AppDesign.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                ),
              ),
              Text(
                review.date,
                style: AppDesign.body(color: AppDesign.textSecondary, fontSize: 11.0),
              ),
            ],
          ),
          const SizedBox(height: AppDesign.space8),
          RatingStars(
            rating: review.rating,
            starSize: 14,
          ),
          const SizedBox(height: AppDesign.space8),
          Text(
            review.comment,
            style: AppDesign.body(color: AppDesign.textPrimary, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
