// lib/shared/widgets/empty_state.dart

import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/widgets/app_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDesign.space24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDesign.space20),
            decoration: BoxDecoration(
              color: AppDesign.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48.0,
              color: AppDesign.textSecondary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppDesign.space20),
          Text(
            title,
            style: AppDesign.heading(fontSize: 18.0),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDesign.space8),
          Text(
            subtitle,
            style: AppDesign.body(color: AppDesign.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onActionTap != null) ...[
            const SizedBox(height: AppDesign.space24),
            AppButton(
              label: actionLabel!,
              onTap: onActionTap,
              isFullWidth: false,
            ),
          ],
        ],
      ),
    );
  }
}
