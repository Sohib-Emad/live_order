import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

class PaymentPreferenceToggle extends StatelessWidget {
  final bool isCash;
  final ValueChanged<bool> onChanged;

  const PaymentPreferenceToggle({
    super.key,
    required this.isCash,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDesign.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: AppDesign.border, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تفضيل الدفع النقدي (كاش)',
                  style: AppDesign.body(
                    color: AppDesign.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: AppDesign.space4),
                Text(
                  'قم بالتفعيل لتسوية رسوم التوصيل نقداً مباشرة كاش للسائق.',
                  style: AppDesign.body(
                    color: AppDesign.textSecondary,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isCash,
            activeThumbColor: AppDesign.primary,
            activeTrackColor: AppDesign.primary.withOpacity(0.3),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
