import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/shipment.dart';

class TimelineStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;
  final bool isLast;

  const TimelineStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    this.isActive = false,
    this.isLast = false,
  });
}

class TimelineTile extends StatelessWidget {
  final TimelineStep step;
  const TimelineTile({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    final Color dotColor = step.isCompleted
        ? AppDesign.primary
        : step.isActive
        ? AppDesign.primary
        : AppDesign.border;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: step.isCompleted
                        ? AppDesign.primary
                        : step.isActive
                        ? AppDesign.primary.withValues(alpha: 0.15)
                        : AppDesign.border.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: dotColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    step.icon,
                    size: 16,
                    color: step.isCompleted
                        ? Colors.white
                        : step.isActive
                        ? AppDesign.primary
                        : AppDesign.border,
                  ),
                ),
                if (!step.isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        color: step.isCompleted
                            ? AppDesign.primary.withValues(alpha: 0.3)
                            : AppDesign.border,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: step.isLast ? 0 : 20, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: AppDesign.body(
                      color: step.isCompleted || step.isActive
                          ? AppDesign.textPrimary
                          : AppDesign.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.subtitle,
                    style: AppDesign.body(
                      color: AppDesign.textSecondary,
                      fontSize: 11.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (step.isActive) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppDesign.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'جاري الآن...',
                        style: AppDesign.body(
                          color: AppDesign.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrackingTimeline extends StatelessWidget {
  final Shipment shipment;
  const TrackingTimeline({super.key, required this.shipment});

  @override
  Widget build(BuildContext context) {
    final bool inTransit =
        shipment.status == 'In Transit' || shipment.status == 'Accepted';
    final bool delivered = shipment.status == 'Delivered';

    final steps = [
      TimelineStep(
        icon: Icons.check_circle_rounded,
        title: 'تم استلام الطلب',
        subtitle: 'تم تأكيد شحنتك بنجاح',
        isCompleted: true,
      ),
      TimelineStep(
        icon: Icons.inventory_2_rounded,
        title: 'تم استلام البضاعة',
        subtitle: shipment.pickupAddress,
        isCompleted: true,
      ),
      TimelineStep(
        icon: Icons.local_shipping_rounded,
        title: 'جاري التوصيل',
        subtitle: 'الكابتن في الطريق إلى ${shipment.dropAddress}',
        isCompleted: inTransit || delivered,
        isActive: inTransit && !delivered,
      ),
      TimelineStep(
        icon: Icons.home_rounded,
        title: 'تم التسليم',
        subtitle: 'وصلت شحنتك!',
        isCompleted: delivered,
        isLast: true,
      ),
    ];

    return Column(
      children: steps.map((step) => TimelineTile(step: step)).toList(),
    );
  }
}
