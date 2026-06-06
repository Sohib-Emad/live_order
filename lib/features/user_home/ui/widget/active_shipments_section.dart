import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/features/user_home/ui/widget/active_shipment_card.dart';
import 'package:live_order/core/widgets/section_header.dart';
import 'package:live_order/features/user_home/ui/widget/section_empty_card.dart';

class ActiveShipmentsSection extends StatelessWidget {
  final List<Shipment> shipments;
  final void Function(Shipment shipment) onShipmentTap;
  final VoidCallback? onNewShipmentTap;

  const ActiveShipmentsSection({
    super.key,
    required this.shipments,
    required this.onShipmentTap,
    this.onNewShipmentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesign.space16,
          ),
          child: SectionHeader(
            title: 'الشحنات النشطة',
            actionLabel: shipments.isNotEmpty ? 'عرض الكل' : null,
            onActionTap: () {},
          ),
        ),
        const SizedBox(height: AppDesign.space12),
        if (shipments.isEmpty)
          SectionEmptyCard(
            icon: Icons.local_shipping_outlined,
            title: 'لا توجد شحنات جارية حالياً',
            subtitle:
                'ابدأ بإنشاء شحنتك الأولى وسيتم تتبعها وتحديثها هنا لحظياً.',
            actionLabel: 'طلب شحنة جديدة',
            onActionTap: onNewShipmentTap,
          )
        else
          SizedBox(
            height: 180.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(
                right: AppDesign.space16,
              ),
              itemCount: shipments.length,
              itemBuilder: (context, index) {
                final item = shipments[index];
                return ActiveShipmentCard(
                  shipment: item,
                  onTap: () => onShipmentTap(item),
                );
              },
            ),
          ),
      ],
    );
  }
}
