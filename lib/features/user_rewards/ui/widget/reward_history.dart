import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/features/user_rewards/logic/state.dart';

class RewardHistory extends StatelessWidget {
  final List<RewardTransaction> transactions;

  const RewardHistory({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isEarn = tx.type == 'earn';
        return Container(
          margin: const EdgeInsets.only(bottom: AppDesign.space8),
          padding: const EdgeInsets.all(AppDesign.space12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDesign.radius12),
            border: Border.all(color: AppDesign.border, width: 1.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: AppDesign.body(color: AppDesign.textPrimary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tx.timestamp.day}/${tx.timestamp.month}/${tx.timestamp.year}',
                      style: AppDesign.body(color: AppDesign.textSecondary, fontSize: 11.0),
                    ),
                  ],
                ),
              ),
              Text(
                '${isEarn ? '+' : '-'}${tx.points} PTS',
                style: AppDesign.body(
                  color: isEarn ? AppDesign.success : AppDesign.danger,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
