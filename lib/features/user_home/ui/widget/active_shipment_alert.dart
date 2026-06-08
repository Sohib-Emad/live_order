import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/widgets/app_button.dart';

class ActiveShipmentAlert extends StatelessWidget {
  final VoidCallback? onTrackShipment;
  final VoidCallback? onGoBack;

  const ActiveShipmentAlert({
    super.key,
    this.onTrackShipment,
    this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDesign.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDesign.space24),
              decoration: BoxDecoration(
                color: AppDesign.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_shipping_rounded,
                color: AppDesign.primary,
                size: 64,
              ),
            ),
            const SizedBox(height: AppDesign.space24),
            Text(
              'لديك شحنة نشطة بالفعل!',
              style: AppDesign.heading(fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDesign.space12),
            Text(
              'تماشياً مع سياسة التطبيق لتوفير أفضل وأسرع خدمة توصيل، يُسمح بإنشاء شحنة نشطة واحدة فقط في نفس الوقت.\n\nيمكنك متابعة وتتبع شحنتك الحالية أو الانتظار حتى يتم تسليمها بالكامل لتتمكن من إنشاء شحنة جديدة.',
              style: AppDesign.body(color: AppDesign.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDesign.space32),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'تتبع شحنتك الحالية الآن',
                onTap: onTrackShipment,
              ),
            ),
            const SizedBox(height: AppDesign.space12),
            TextButton(
              onPressed: onGoBack,
              child: Text(
                'العودة للرئيسية',
                style: AppDesign.body(
                  color: AppDesign.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
