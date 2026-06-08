import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

class RewardBalanceCard extends StatelessWidget {
  final int points;
  final String tier;
  final String nextTier;
  final double progress;

  const RewardBalanceCard({
    super.key,
    required this.points,
    required this.tier,
    required this.nextTier,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDesign.space20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppDesign.primary, Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        boxShadow: [
          BoxShadow(
            color: AppDesign.primary.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL POINT BALANCE',
                    style: TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$points PTS',
                    style: AppDesign.heading(color: Colors.white, fontSize: 28.0),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDesign.space12, vertical: AppDesign.space4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDesign.radius24),
                  border: Border.all(color: Colors.white24, width: 1.0),
                ),
                child: Text(
                  tier,
                  style: AppDesign.body(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesign.space24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next Tier: $nextTier',
                style: AppDesign.body(color: Colors.white70, fontSize: 12.0, fontWeight: FontWeight.w600),
              ),
              if (progress < 1.0)
                Text(
                  '${(progress * 100).toInt()}% completed',
                  style: AppDesign.body(color: Colors.white70, fontSize: 11.0),
                ),
            ],
          ),
          const SizedBox(height: AppDesign.space8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDesign.radius8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              color: AppDesign.success,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
