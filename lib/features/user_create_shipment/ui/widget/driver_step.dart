import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/features/user_create_shipment/ui/widget/driver_card.dart';

class DriverStep extends StatelessWidget {
  final UserProfile? selectedDriver;
  final Future<List<UserProfile>> Function() fetchDrivers;
  final ValueChanged<UserProfile> onDriverSelected;

  const DriverStep({
    super.key,
    required this.selectedDriver,
    required this.fetchDrivers,
    required this.onDriverSelected,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر كابتن التوصيل المفضل لشحنتك',
            style: AppDesign.heading(fontSize: 16.0),
          ),
          const SizedBox(height: AppDesign.space4),
          Text(
            'اختر أحد السائقين الأعلى تقييماً المسجلين والمعتمدين لدينا.',
            style: AppDesign.body(
              color: AppDesign.textSecondary,
              fontSize: 12.0,
            ),
          ),
          const SizedBox(height: AppDesign.space20),
          FutureBuilder<List<UserProfile>>(
            future: fetchDrivers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: CircularProgressIndicator(color: AppDesign.primary),
                  ),
                );
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  alignment: Alignment.center,
                  child: Text(
                    'لا يوجد سائقين متاحين حالياً في قاعدة البيانات.',
                    style: AppDesign.body(color: AppDesign.textSecondary),
                  ),
                );
              }

              final drivers = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: drivers.length,
                itemBuilder: (context, index) {
                  final driver = drivers[index];
                  final isSelected = selectedDriver?.uid == driver.uid;

                  return DriverCard(
                    driver: driver,
                    isSelected: isSelected,
                    onTap: () => onDriverSelected(driver),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
