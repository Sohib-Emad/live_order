import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;

  const StepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: AppDesign.space16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final isActive = index <= currentStep;
          return Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isActive ? AppDesign.primary : AppDesign.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? AppDesign.primary : AppDesign.border,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: AppDesign.body(
                    color: isActive ? Colors.white : AppDesign.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0,
                  ),
                ),
              ),
              if (index < 4)
                Container(
                  width: 36,
                  height: 2,
                  color: index < currentStep
                      ? AppDesign.primary
                      : AppDesign.border,
                ),
            ],
          );
        }),
      ),
    );
  }
}
