import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/core/widgets/avatar_widget.dart';

class DriverCard extends StatelessWidget {
  final Shipment shipment;
  const DriverCard({super.key, required this.shipment});

  @override
  Widget build(BuildContext context) {
    final driver = shipment.assignedDriver!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppDesign.border),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppDesign.success, width: 2.5),
                ),
                child: AvatarWidget(
                  imageUrl: driver.imageUrl,
                  fallbackName: driver.name,
                  radius: 22.0,
                ),
              ),
              Positioned(
                bottom: 2,
                left: 2,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: AppDesign.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: AppDesign.body(
                    color: AppDesign.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.motorcycle_rounded,
                      size: 13,
                      color: AppDesign.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${driver.vehicleType} • ${driver.vehiclePlate}',
                      style: AppDesign.body(
                        color: AppDesign.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      driver.rating.toStringAsFixed(1),
                      style: AppDesign.body(
                        color: AppDesign.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${driver.reviews.length} تقييم)',
                      style: AppDesign.body(
                        color: AppDesign.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.marketChat, arguments: driver),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppDesign.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppDesign.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
