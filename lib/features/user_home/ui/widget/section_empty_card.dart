import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

class SectionEmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const SectionEmptyCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppDesign.space16),
      padding: const EdgeInsets.symmetric(
        vertical: AppDesign.space20,
        horizontal: AppDesign.space16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: AppDesign.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppDesign.textSecondary.withValues(alpha: 0.3), size: 32),
          const SizedBox(height: AppDesign.space12),
          Text(
            title,
            style: AppDesign.heading(fontSize: 13.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDesign.space4),
          Text(
            subtitle,
            style: AppDesign.body(
              color: AppDesign.textSecondary,
              fontSize: 11.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onActionTap != null) ...[
            const SizedBox(height: AppDesign.space12),
            InkWell(
              onTap: onActionTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppDesign.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppDesign.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: AppDesign.body(
                    color: AppDesign.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
