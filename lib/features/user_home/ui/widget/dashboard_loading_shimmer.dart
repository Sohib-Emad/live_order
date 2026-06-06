import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/widgets/loading_shimmer.dart';

class DashboardLoadingShimmer extends StatelessWidget {
  const DashboardLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDesign.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LoadingShimmer(width: 150, height: 20),
          const SizedBox(height: AppDesign.space16),
          Row(
            children: const [
              Expanded(
                child: LoadingShimmer(
                  width: double.infinity,
                  height: 120,
                  borderRadius: 12,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: LoadingShimmer(
                  width: double.infinity,
                  height: 120,
                  borderRadius: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesign.space24),
          const LoadingShimmer(width: 150, height: 20),
          const SizedBox(height: AppDesign.space16),
          const LoadingShimmer(
            width: double.infinity,
            height: 80,
            borderRadius: 12,
          ),
          const SizedBox(height: 12),
          const LoadingShimmer(
            width: double.infinity,
            height: 80,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }
}
