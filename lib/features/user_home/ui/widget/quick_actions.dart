import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/constants/app_design.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback? onNewShipment;
  final VoidCallback? onMyOrders;
  final VoidCallback? onTrackShipment;
  final VoidCallback? onRewards;

  const QuickActions({
    super.key,
    this.onNewShipment,
    this.onMyOrders,
    this.onTrackShipment,
    this.onRewards,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'label': 'شحنة جديدة', 'icon': Icons.add_box_rounded, 'onTap': onNewShipment},
      {'label': 'طلباتي', 'icon': Icons.local_shipping_rounded, 'onTap': onMyOrders},
      {'label': 'تتبع الشحنة', 'icon': Icons.map_rounded, 'onTap': onTrackShipment},
      {'label': 'المكافآت', 'icon': Icons.wallet_giftcard_rounded, 'onTap': onRewards},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesign.space16,
        vertical: AppDesign.space8,
      ),
      child: Row(
        children: actions.map((act) {
          return Expanded(
            child: GestureDetector(
              onTap: act['onTap'] as VoidCallback?,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDesign.radius12),
                      border: Border.all(color: AppDesign.border, width: 1.0),
                    ),
                    child: Icon(
                      act['icon'] as IconData,
                      color: AppDesign.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: AppDesign.space8),
                  Text(
                    act['label'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppDesign.body(
                      color: AppDesign.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
