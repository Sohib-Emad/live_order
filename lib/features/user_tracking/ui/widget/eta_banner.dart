import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

class EtaBanner extends StatelessWidget {
  final String shipmentId;
  const EtaBanner({super.key, required this.shipmentId});

  @override
  Widget build(BuildContext context) {
    final shortId = shipmentId.length > 8
        ? shipmentId.substring(0, 8).toUpperCase()
        : shipmentId.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppDesign.primary.withValues(alpha: 0.08),
            AppDesign.primary.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppDesign.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppDesign.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: AppDesign.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'شحنة #$shortId',
                  style: AppDesign.body(
                    color: AppDesign.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'وقت التسليم المتوقع: ٢٠ - ٣٠ دقيقة',
                  style: AppDesign.body(
                    color: AppDesign.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppDesign.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '~٢٥ د',
              style: AppDesign.body(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
