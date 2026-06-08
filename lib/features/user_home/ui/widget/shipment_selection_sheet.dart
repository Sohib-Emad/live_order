import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/shipment.dart';

class ShipmentSelectionSheet extends StatelessWidget {
  final List<Shipment> shipments;
  final void Function(Shipment shipment) onShipmentSelected;

  const ShipmentSelectionSheet({
    super.key,
    required this.shipments,
    required this.onShipmentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDesign.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تتبع الشحنة', style: AppDesign.heading(fontSize: 18.0)),
            const SizedBox(height: AppDesign.space4),
            Text(
              'اختر شحنة نشطة لعرض التتبع المباشر.',
              style: AppDesign.body(color: AppDesign.textSecondary),
            ),
            const SizedBox(height: AppDesign.space16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: shipments.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: AppDesign.border, height: 1),
                itemBuilder: (context, index) {
                  final item = shipments[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(AppDesign.space8),
                      decoration: BoxDecoration(
                        color: AppDesign.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppDesign.radius8,
                        ),
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        color: AppDesign.primary,
                      ),
                    ),
                    title: Text(
                      item.cargoType,
                      style: AppDesign.body(
                        color: AppDesign.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'إلى: ${item.dropAddress}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppDesign.body(
                        color: AppDesign.textSecondary,
                        fontSize: 12.0,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppDesign.textSecondary,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onShipmentSelected(item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
