import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

class PromoBanner extends StatelessWidget {
  final VoidCallback? onDismiss;

  const PromoBanner({super.key, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDesign.space16),
      padding: const EdgeInsets.all(AppDesign.space16),
      decoration: BoxDecoration(
        color: AppDesign.primary,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'عرض توصيل خاص!',
                      style: AppDesign.heading(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: AppDesign.space4),
                    Text(
                      'احصل على خصم 20% على أول شحنة بضائع كبيرة هذا الأسبوع.',
                      style: AppDesign.body(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDesign.space16),
              const Icon(Icons.percent_rounded, color: Colors.white, size: 36),
            ],
          ),
          Positioned(
            left: 0,
            top: 0,
            child: GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
