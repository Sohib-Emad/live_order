import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/features/user_create_shipment/ui/widget/pulsing_avatar.dart';

class PulsingWaitingState extends StatelessWidget {
  final UserProfile? selectedDriver;
  final VoidCallback onCancel;

  const PulsingWaitingState({
    super.key,
    required this.selectedDriver,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDesign.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selectedDriver != null) ...[
              PulsingAvatar(
                imageUrl: selectedDriver!.imageUrl,
                fallbackName: selectedDriver!.name,
              ),
              const SizedBox(height: AppDesign.space32),
              Text(
                'جاري إرسال الطلب للكابتن ${selectedDriver!.name}',
                style: AppDesign.heading(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(AppDesign.space24),
                decoration: BoxDecoration(
                  color: AppDesign.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_empty_rounded,
                  color: AppDesign.primary,
                  size: 64,
                ),
              ),
              const SizedBox(height: AppDesign.space24),
              Text(
                'جاري إرسال الطلب للكابتن المختار',
                style: AppDesign.heading(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppDesign.space12),
            Text(
              'يرجى الانتظار لحين قبول الكابتن للطلب أو رفضه.',
              style: AppDesign.body(color: AppDesign.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppDesign.danger, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDesign.radius8),
                  ),
                ),
                child: Text(
                  'إلغاء الطلب',
                  style: AppDesign.body(
                    color: AppDesign.danger,
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
