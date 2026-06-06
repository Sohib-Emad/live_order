import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionTitle({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppDesign.primary,
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: AppDesign.heading(fontSize: 14.5),
        ),
      ],
    );
  }
}
