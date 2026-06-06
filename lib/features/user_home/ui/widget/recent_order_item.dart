// lib/features/user_home/widget/recent_order_item.dart

import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/core/widgets/status_badge.dart';

class RecentOrderItem extends StatelessWidget {
  final Shipment shipment;
  final VoidCallback onTap;

  const RecentOrderItem({
    super.key,
    required this.shipment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData getCargoIcon() {
      switch (shipment.cargoType.toLowerCase()) {
        case 'electronics':
          return Icons.devices_rounded;
        case 'documents':
          return Icons.description_rounded;
        case 'furniture':
          return Icons.chair_rounded;
        case 'food':
          return Icons.restaurant_rounded;
        default:
          return Icons.local_shipping_rounded;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDesign.space12),
        padding: const EdgeInsets.all(AppDesign.space12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDesign.radius12),
          border: Border.all(color: AppDesign.border, width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDesign.space12),
              decoration: BoxDecoration(
                color: AppDesign.surface,
                borderRadius: BorderRadius.circular(AppDesign.radius8),
              ),
              child: Icon(getCargoIcon(), color: AppDesign.primary, size: 22.0),
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
                        shipment.cargoType,
                        style: AppDesign.body(
                          color: AppDesign.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${shipment.priceEstimate.toStringAsFixed(0)}',
                        style: AppDesign.body(
                          color: AppDesign.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDesign.space4),
                  Text(
                    '${shipment.pickupAddress.split(',').first} → ${shipment.dropAddress.split(',').first}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppDesign.body(
                      color: AppDesign.textSecondary,
                      fontSize: 12.0,
                    ),
                  ),
                  const SizedBox(height: AppDesign.space8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        shipment.preferredDate,
                        style: AppDesign.body(
                          color: AppDesign.textSecondary.withOpacity(0.8),
                          fontSize: 11.0,
                        ),
                      ),
                      StatusBadge(status: shipment.status),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
