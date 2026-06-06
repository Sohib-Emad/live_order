import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/features/user_home/ui/widget/driver_card.dart';
import 'package:live_order/core/widgets/section_header.dart';
import 'package:live_order/features/user_home/ui/widget/section_empty_card.dart';

class TopDriversSection extends StatelessWidget {
  final List<UserProfile> drivers;
  final VoidCallback? onViewAll;
  final void Function(UserProfile driver) onDriverTap;

  const TopDriversSection({
    super.key,
    required this.drivers,
    this.onViewAll,
    required this.onDriverTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesign.space16,
          ),
          child: SectionHeader(
            title: 'السائقين الأعلى تقييماً',
            actionLabel: drivers.isNotEmpty ? 'عرض الكل' : null,
            onActionTap: onViewAll,
          ),
        ),
        const SizedBox(height: AppDesign.space12),
        if (drivers.isEmpty)
          const SectionEmptyCard(
            icon: Icons.people_outline_rounded,
            title: 'لا يوجد سائقين متاحين حالياً',
            subtitle:
                'سيظهر هنا السائقين المعتمدين والمتاحين فور انضمامهم للمنصة.',
          )
        else
          SizedBox(
            height: 190.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(
                right: AppDesign.space16,
              ),
              itemCount: drivers.length,
              itemBuilder: (context, index) {
                final driver = drivers[index];
                return DriverCard(
                  driver: driver,
                  onTap: () => onDriverTap(driver),
                );
              },
            ),
          ),
      ],
    );
  }
}
