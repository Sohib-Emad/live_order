import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/core/widgets/avatar_widget.dart';

class DriverInfoHeader extends StatelessWidget {
  final UserProfile driver;

  const DriverInfoHeader({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.only(
        left: AppDesign.space16,
        right: AppDesign.space16,
        bottom: AppDesign.space20,
        top: AppDesign.space12,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF3F4F6),
                    width: 2.0,
                  ),
                ),
                child: AvatarWidget(
                  imageUrl: driver.imageUrl,
                  fallbackName: driver.name,
                  radius: 36,
                ),
              ),
              const SizedBox(width: AppDesign.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            driver.name,
                            style: AppDesign.heading(fontSize: 18.0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (driver.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF1D9BF0),
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_shipping_outlined,
                          color: AppDesign.textSecondary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          driver.vehicleType ?? 'سيارة نقل بضائع',
                          style: AppDesign.body(
                            color: AppDesign.textSecondary,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFEDD5),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.orange,
                            size: 14,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            driver.rating.toStringAsFixed(1),
                            style: AppDesign.body(
                              color: const Color(0xFFC2410C),
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesign.space20),
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          const SizedBox(height: AppDesign.space16),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatColumn('رحلات ناجحة', '${driver.totalDeliveries}+'),
        Container(height: 24, width: 1, color: const Color(0xFFE5E7EB)),
        _buildStatColumn('سنوات الخبرة', '${driver.yearsActive} سنوات'),
        Container(height: 24, width: 1, color: const Color(0xFFE5E7EB)),
        _buildStatColumn(
          'حمولة المركبة',
          driver.vehicleCapacity ?? 'نقل خفيف',
        ),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppDesign.heading(fontSize: 14.0, color: AppDesign.textPrimary),
        ),
        const SizedBox(height: AppDesign.space4),
        Text(
          label,
          style: AppDesign.body(fontSize: 11.0, color: AppDesign.textSecondary),
        ),
      ],
    );
  }
}
