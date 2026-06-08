import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/core/widgets/app_button.dart';

class AcceptedState extends StatelessWidget {
  final Shipment shipment;
  final UserProfile? selectedDriver;

  const AcceptedState({
    super.key,
    required this.shipment,
    required this.selectedDriver,
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
                color: AppDesign.success.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppDesign.success,
                size: 64,
              ),
            ),
            const SizedBox(height: AppDesign.space24),
            Text(
              'تم قبول طلبك بنجاح!',
              style: AppDesign.heading(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDesign.space8),
            Text(
              'لقد وافق الكابتن ${selectedDriver?.name ?? ""} على طلب الشحن الخاص بك. يمكنك الآن متابعتها أو التواصل معه مباشرة.',
              style: AppDesign.body(color: AppDesign.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'تتبع حركة الشحنة الآن',
                onTap: () {
                  final navigator = Navigator.of(context);
                  navigator.pushNamedAndRemoveUntil(
                    AppRoutes.homeScreen,
                    (route) => false,
                  );
                  navigator.pushNamed(
                    AppRoutes.shipmentTracking,
                    arguments: shipment,
                  );
                },
              ),
            ),
            const SizedBox(height: AppDesign.space12),
            if (selectedDriver != null) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    navigator.pushNamedAndRemoveUntil(
                      AppRoutes.homeScreen,
                      (route) => false,
                    );
                    navigator.pushNamed(
                      AppRoutes.marketChat,
                      arguments: selectedDriver,
                    );
                  },
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppDesign.primary,
                    size: 18,
                  ),
                  label: Text(
                    'محادثة وتواصل مع الكابتن',
                    style: AppDesign.body(
                      color: AppDesign.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppDesign.primary,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDesign.radius8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDesign.space12),
            ],
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.homeScreen,
                  (route) => false,
                );
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
