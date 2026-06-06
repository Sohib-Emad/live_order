import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

class TransactionFilterChip extends StatelessWidget {
  final String categoryKey;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const TransactionFilterChip({
    super.key,
    required this.categoryKey,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDesign.space16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppDesign.primary : AppDesign.surface,
          borderRadius: BorderRadius.circular(AppDesign.radius24),
          border: Border.all(
            color: isSelected ? AppDesign.primary : AppDesign.border,
            width: 1.0,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppDesign.body(
              color: isSelected ? Colors.white : AppDesign.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 13.0,
            ),
          ),
        ),
      ),
    );
  }
}
