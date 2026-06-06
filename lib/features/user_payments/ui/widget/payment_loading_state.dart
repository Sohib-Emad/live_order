import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/widgets/loading_shimmer.dart';

class PaymentLoadingState extends StatelessWidget {
  const PaymentLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDesign.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          LoadingShimmer(width: double.infinity, height: 60, borderRadius: 12),
          SizedBox(height: 24),
          LoadingShimmer(width: 150, height: 20),
          SizedBox(height: 12),
          LoadingShimmer(width: 280, height: 180, borderRadius: 12),
          SizedBox(height: 24),
          LoadingShimmer(width: 150, height: 20),
          SizedBox(height: 12),
          LoadingShimmer(width: double.infinity, height: 80, borderRadius: 12),
        ],
      ),
    );
  }
}
