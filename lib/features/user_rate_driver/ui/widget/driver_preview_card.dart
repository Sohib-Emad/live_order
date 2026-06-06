import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/core/widgets/avatar_widget.dart';

class DriverPreviewCard extends StatelessWidget {
  final UserProfile driver;

  const DriverPreviewCard({
    super.key,
    required this.driver,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AvatarWidget(
          imageUrl: driver.imageUrl,
          fallbackName: driver.name,
          radius: 36,
        ),
        const SizedBox(height: AppDesign.space12),
        Text(
          driver.name,
          style: AppDesign.heading(fontSize: 17.0),
        ),
        const SizedBox(height: AppDesign.space4),
        Text(
          driver.vehicleType ?? 'Cargo Driver',
          style: AppDesign.body(color: AppDesign.textSecondary, fontSize: 13.0),
        ),
      ],
    );
  }
}
