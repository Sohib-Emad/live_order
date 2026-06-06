import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/features/user_home/ui/widget/recent_order_item.dart';
import 'package:live_order/core/widgets/section_header.dart';
import 'package:live_order/features/user_home/ui/widget/section_empty_card.dart';

class RecentOrdersSection extends StatelessWidget {
  final List<Shipment> orders;
  final VoidCallback? onViewLog;
  final void Function(Shipment order) onOrderTap;

  const RecentOrdersSection({
    super.key,
    required this.orders,
    this.onViewLog,
    required this.onOrderTap,
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
            title: 'الطلبات الأخيرة والمكتملة',
            actionLabel: orders.isNotEmpty ? 'السجل' : null,
            onActionTap: onViewLog,
          ),
        ),
        const SizedBox(height: AppDesign.space12),
        if (orders.isEmpty)
          SectionEmptyCard(
            icon: Icons.history_rounded,
            title: 'سجل الطلبات فارغ',
            subtitle:
                'عند تسليم شحناتك الجارية بالكامل، ستظهر جميع تفاصيلها وأرشيفها هنا.',
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDesign.space16,
            ),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final item = orders[index];
              return RecentOrderItem(
                shipment: item,
                onTap: () => onOrderTap(item),
              );
            },
          ),
      ],
    );
  }
}
