// lib/shared/widgets/section_header.dart

import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: AppDesign.heading(fontSize: 18.0),
        ),
        if (actionLabel != null && onActionTap != null)
          GestureDetector(
            onTap: onActionTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDesign.space4,
                horizontal: AppDesign.space8,
              ),
              child: Text(
                actionLabel!,
                style: AppDesign.body(
                  color: AppDesign.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
