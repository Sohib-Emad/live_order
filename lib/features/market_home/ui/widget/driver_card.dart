// lib/features/market_home/widget/driver_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/shared/widgets/avatar_widget.dart';
import 'package:live_order/shared/widgets/rating_stars.dart';

class DriverCard extends StatelessWidget {
  final UserProfile driver;
  final VoidCallback onBookTap;
  final VoidCallback onTap;

  const DriverCard({
    super.key,
    required this.driver,
    required this.onBookTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160.w,
        margin: const EdgeInsets.only(right: AppDesign.space16),
        padding: const EdgeInsets.all(AppDesign.space12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDesign.radius12),
          border: Border.all(color: AppDesign.border, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AvatarWidget(
              imageUrl: driver.imageUrl,
              fallbackName: driver.name,
              radius: 28.0,
            ),
            const SizedBox(height: AppDesign.space8),
            Text(
              driver.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppDesign.body(
                color: AppDesign.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13.0,
              ),
            ),
            const SizedBox(height: AppDesign.space4),
            Text(
              driver.vehicleType ?? 'Truck Driver',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppDesign.body(
                color: AppDesign.textSecondary,
                fontSize: 11.0,
              ),
            ),
            const SizedBox(height: AppDesign.space8),
            RatingStars(rating: driver.rating, starSize: 12.0),
            const SizedBox(height: AppDesign.space12),
            ElevatedButton(
              onPressed: onBookTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesign.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: Size(double.infinity, 32.h),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDesign.radius8),
                ),
              ),
              child: Text(
                'Book Now',
                style: AppDesign.body(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
