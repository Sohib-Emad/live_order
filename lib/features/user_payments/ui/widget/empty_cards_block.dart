import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

class EmptyCardsBlock extends StatelessWidget {
  const EmptyCardsBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppDesign.space32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: AppDesign.border, width: 1.0),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.credit_card_off_outlined,
            color: AppDesign.textSecondary,
            size: 36,
          ),
          const SizedBox(height: AppDesign.space8),
          Text(
            'لا توجد بطاقات ائتمانية مرتبطة بعد',
            style: AppDesign.body(
              color: AppDesign.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDesign.space4),
          Text(
            'أضف بطاقتك لتسريع وتسهيل الدفع الفوري الآمن لشحناتك.',
            style: AppDesign.body(
              color: AppDesign.textSecondary,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }
}
