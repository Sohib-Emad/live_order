// lib/features/user_drivers/widget/driver_list_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/core/widgets/avatar_widget.dart';

class DriverListTile extends StatelessWidget {
  final UserProfile driver;
  final VoidCallback onViewTap;

  const DriverListTile({
    super.key,
    required this.driver,
    required this.onViewTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDesign.space12),
      padding: const EdgeInsets.all(AppDesign.space12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: AppDesign.border, width: 1.0),
      ),
      child: Row(
        children: [
          AvatarWidget(
            imageUrl: driver.imageUrl,
            fallbackName: driver.name,
            radius: 26.0,
          ),
          const SizedBox(width: AppDesign.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      driver.name,
                      style: AppDesign.body(
                        color: AppDesign.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
                        const SizedBox(width: 2),
                        Text(
                          driver.rating.toStringAsFixed(1),
                          style: AppDesign.body(
                            color: AppDesign.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppDesign.space4),
                Text(
                  driver.vehicleType ?? 'Truck Driver',
                  style: AppDesign.body(color: AppDesign.textSecondary, fontSize: 12.0),
                ),
                const SizedBox(height: AppDesign.space8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rate: \$2.5 / km',
                      style: AppDesign.body(
                        color: AppDesign.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onViewTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppDesign.surface,
                        foregroundColor: AppDesign.primary,
                        elevation: 0,
                        minimumSize: Size(60.w, 28.h),
                        padding: const EdgeInsets.symmetric(horizontal: AppDesign.space12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDesign.radius8),
                          side: const BorderSide(color: AppDesign.border),
                        ),
                      ),
                      child: Text(
                        'View',
                        style: AppDesign.body(
                          color: AppDesign.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
