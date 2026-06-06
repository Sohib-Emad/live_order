import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/core/widgets/app_button.dart';

class RejectedState extends StatelessWidget {
  final UserProfile? selectedDriver;
  final VoidCallback onRetry;

  const RejectedState({
    super.key,
    required this.selectedDriver,
    required this.onRetry,
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
                color: AppDesign.danger.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cancel_rounded,
                color: AppDesign.danger,
                size: 64,
              ),
            ),
            const SizedBox(height: AppDesign.space24),
            Text(
              'معذرةً، اعتذر الكابتن عن قبول الشحنة',
              style: AppDesign.heading(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDesign.space8),
            Text(
              'اعتذر الكابتن ${selectedDriver?.name ?? ""} عن قبول الرحلة حالياً. لا تقلق، يمكنك اختيار كابتن بديل فوراً ومتابعة الطلب.',
              style: AppDesign.body(color: AppDesign.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'اختيار كابتن آخر',
                onTap: onRetry,
              ),
            ),
            const SizedBox(height: AppDesign.space12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
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
