// lib/shared/widgets/status_badge.dart

import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color getBaseColor() {
      final norm = status.trim().toLowerCase();
      if (norm.contains('deliver') || norm.contains('success') || norm.contains('complete') || norm.contains('مكتمل')) {
        return AppDesign.success;
      } else if (norm.contains('transit') || norm.contains('way') || norm.contains('طريق') || norm.contains('جاري')) {
        return AppDesign.warning;
      } else if (norm.contains('cancel') || norm.contains('fail') || norm.contains('danger') || norm.contains('ملغي')) {
        return AppDesign.danger;
      }
      return AppDesign.primary;
    }

    String getDisplayLabel() {
      final norm = status.trim().toLowerCase();
      if (norm.contains('deliver') || norm.contains('مكتمل')) return 'Delivered';
      if (norm.contains('transit') || norm.contains('طريق')) return 'In Transit';
      if (norm.contains('cancel') || norm.contains('ملغي')) return 'Cancelled';
      if (norm.contains('waiting') || norm.contains('انتظار')) return 'Pending';
      return status;
    }

    final color = getBaseColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDesign.space12, vertical: AppDesign.space4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDesign.radius24),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.0),
      ),
      child: Text(
        getDisplayLabel(),
        style: AppDesign.body(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11.0,
        ),
      ),
    );
  }
}
