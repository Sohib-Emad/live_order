// lib/shared/widgets/app_button.dart

import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

enum AppButtonVariant { primary, secondary, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onTap != null && !isLoading;

    Color getBgColor() {
      if (!isEnabled && variant != AppButtonVariant.text) return AppDesign.border;
      switch (variant) {
        case AppButtonVariant.primary:
          return AppDesign.primary;
        case AppButtonVariant.secondary:
          return Colors.white;
        case AppButtonVariant.text:
          return Colors.transparent;
      }
    }

    Color getTextColor() {
      if (!isEnabled) return AppDesign.textSecondary.withOpacity(0.5);
      switch (variant) {
        case AppButtonVariant.primary:
          return Colors.white;
        case AppButtonVariant.secondary:
          return AppDesign.primary;
        case AppButtonVariant.text:
          return AppDesign.primary;
      }
    }

    Border? getBorder() {
      if (variant == AppButtonVariant.secondary) {
        return Border.all(
          color: isEnabled ? AppDesign.primary : AppDesign.border,
          width: 1.5,
        );
      }
      return null;
    }

    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(getTextColor()),
            ),
          ),
          const SizedBox(width: AppDesign.space8),
        ] else if (icon != null) ...[
          Icon(icon, size: 18, color: getTextColor()),
          const SizedBox(width: AppDesign.space8),
        ],
        Text(
          label,
          style: AppDesign.body(
            color: getTextColor(),
            fontWeight: FontWeight.w600,
            fontSize: 15.0,
          ),
        ),
      ],
    );

    Widget button = Container(
      decoration: BoxDecoration(
        color: getBgColor(),
        border: getBorder(),
        borderRadius: BorderRadius.circular(AppDesign.radius8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppDesign.radius8),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppDesign.space16 - 2,
              horizontal: AppDesign.space24,
            ),
            child: content,
          ),
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    return button;
  }
}
