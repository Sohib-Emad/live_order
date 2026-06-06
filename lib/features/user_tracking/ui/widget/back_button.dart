import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

class TrackingBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const TrackingBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_forward_rounded,
          color: AppDesign.textPrimary,
          size: 20,
        ),
      ),
    );
  }
}
