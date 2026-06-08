import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

class ChatRestrictedView extends StatelessWidget {
  final String message;
  final VoidCallback onBack;

  const ChatRestrictedView({
    super.key,
    required this.message,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDesign.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDesign.space24),
              decoration: BoxDecoration(
                color: AppDesign.danger.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: AppDesign.danger,
                size: 64,
              ),
            ),
            const SizedBox(height: AppDesign.space24),
            Text(
              'التواصل غير متاح حالياً',
              style: AppDesign.heading(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDesign.space12),
            Text(
              message,
              style: AppDesign.body(color: AppDesign.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDesign.space32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppDesign.border, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDesign.radius8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'الرجوع للخلف',
                  style: AppDesign.body(
                    color: AppDesign.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
