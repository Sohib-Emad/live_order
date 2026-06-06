import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

class DecorativeCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const DecorativeCircle({super.key, required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppDesign.primary.withValues(alpha: opacity),
      ),
    );
  }
}
