// lib/features/user_home/widget/active_shipment_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/core/widgets/avatar_widget.dart';
import 'package:live_order/core/widgets/status_badge.dart';

class ActiveShipmentCard extends StatelessWidget {
  final Shipment shipment;
  final VoidCallback onTap;

  const ActiveShipmentCard({
    super.key,
    required this.shipment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300.w,
        margin: const EdgeInsets.only(right: AppDesign.space16),
        padding: const EdgeInsets.all(AppDesign.space16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDesign.radius12),
          border: Border.all(color: AppDesign.border, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  shipment.id,
                  style: AppDesign.body(
                    color: AppDesign.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                StatusBadge(status: shipment.status),
              ],
            ),
            const SizedBox(height: AppDesign.space12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const Icon(Icons.circle, size: 10, color: AppDesign.primary),
                    Container(
                      width: 1.5,
                      height: 24,
                      color: AppDesign.border,
                    ),
                    const Icon(Icons.location_on_rounded, size: 12, color: AppDesign.danger),
                  ],
                ),
                const SizedBox(width: AppDesign.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shipment.pickupAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppDesign.body(
                          color: AppDesign.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.0,
                        ),
                      ),
                      const SizedBox(height: AppDesign.space16),
                      Text(
                        shipment.dropAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppDesign.body(
                          color: AppDesign.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDesign.space16),
            const Divider(color: AppDesign.border, height: 1),
            const SizedBox(height: AppDesign.space12),
            if (shipment.assignedDriver != null)
              Row(
                children: [
                  AvatarWidget(
                    imageUrl: shipment.assignedDriver!.imageUrl,
                    fallbackName: shipment.assignedDriver!.name,
                    radius: 16.0,
                  ),
                  const SizedBox(width: AppDesign.space8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shipment.assignedDriver!.name,
                          style: AppDesign.body(
                            color: AppDesign.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0,
                          ),
                        ),
                        Text(
                          shipment.assignedDriver!.vehicleType ?? 'Driver',
                          style: AppDesign.body(
                            color: AppDesign.textSecondary,
                            fontSize: 10.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: AppDesign.textSecondary.withOpacity(0.5),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: AppDesign.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(AppDesign.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDesign.space8),
                  Expanded(
                    child: Text(
                      'جاري البحث عن كابتن للتوصيل...',
                      style: AppDesign.body(
                        color: AppDesign.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
