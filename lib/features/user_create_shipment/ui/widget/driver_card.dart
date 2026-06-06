import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/core/widgets/avatar_widget.dart';

class DriverCard extends StatelessWidget {
  final UserProfile driver;
  final bool isSelected;
  final VoidCallback onTap;

  const DriverCard({
    super.key,
    required this.driver,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDesign.space12),
        padding: const EdgeInsets.all(AppDesign.space16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppDesign.primary.withOpacity(0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppDesign.radius12),
          border: Border.all(
            color: isSelected ? AppDesign.primary : AppDesign.border,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            AvatarWidget(
              imageUrl: driver.imageUrl,
              fallbackName: driver.name,
              radius: 22.0,
            ),
            const SizedBox(width: AppDesign.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver.name,
                    style: AppDesign.body(
                      color: AppDesign.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    driver.vehicleType ?? 'سيارة نقل بضائع',
                    style: AppDesign.body(
                      color: AppDesign.textSecondary,
                      fontSize: 11.0,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.orange,
                      size: 16,
                    ),
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
                const SizedBox(height: 4),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppDesign.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppDesign.primary
                          : AppDesign.border,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        )
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
