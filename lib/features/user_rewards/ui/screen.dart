// lib/features/user_rewards/ui/screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/features/user_rewards/logic/cubit.dart';
import 'package:live_order/features/user_rewards/logic/state.dart';
import 'package:live_order/features/user_rewards/ui/widget/referral_card.dart';
import 'package:live_order/features/user_rewards/ui/widget/reward_balance_card.dart';
import 'package:live_order/features/user_rewards/ui/widget/reward_history.dart';
import 'package:live_order/features/user_rewards/ui/widget/reward_loading_state.dart';
import 'package:live_order/core/widgets/empty_state.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final String _referralCode = 'CARGOSHARE50';

  @override
  void initState() {
    super.initState();
    context.read<RewardsCubit>().loadRewardsDetails();
  }

  void _copyReferral() {
    Clipboard.setData(ClipboardData(text: _referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral code copied to clipboard!'),
        backgroundColor: AppDesign.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppDesign.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Rewards Program',
          style: AppDesign.heading(fontSize: 18.0),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<RewardsCubit, RewardsState>(
        builder: (context, state) {
          if (state is RewardsLoading) {
            return const RewardLoadingState();
          } else if (state is RewardsError) {
            return EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Rewards Error',
              subtitle: state.message,
              actionLabel: 'Retry',
              onActionTap: () => context.read<RewardsCubit>().loadRewardsDetails(),
            );
          } else if (state is RewardsLoaded) {
            final points = state.points;
            final tier = _getTier(points);
            final nextTier = _getNextTier(points);
            final progress = _getTierProgress(points);

            return RefreshIndicator(
              onRefresh: () => context.read<RewardsCubit>().loadRewardsDetails(),
              color: AppDesign.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppDesign.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RewardBalanceCard(
                      points: points,
                      tier: tier,
                      nextTier: nextTier,
                      progress: progress,
                    ),

                    const SizedBox(height: AppDesign.space24),

                    ReferralCard(
                      referralCode: _referralCode,
                      onCopy: _copyReferral,
                    ),

                    const SizedBox(height: AppDesign.space28),

                    // Points History Title
                    Text(
                      'Points Transaction Ledger',
                      style: AppDesign.heading(fontSize: 16.0),
                    ),
                    const SizedBox(height: AppDesign.space12),

                    // Points transactions list
                    if (state.transactions.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        alignment: Alignment.center,
                        child: Text(
                          'No point transactions found. Book a cargo trip to start earning!',
                          textAlign: TextAlign.center,
                          style: AppDesign.body(color: AppDesign.textSecondary),
                        ),
                      )
                    else
                      RewardHistory(transactions: state.transactions),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _getTier(int points) {
    if (points >= 3000) return 'PLATINUM';
    if (points >= 1500) return 'GOLD';
    if (points >= 500) return 'SILVER';
    return 'BRONZE';
  }

  String _getNextTier(int points) {
    if (points >= 3000) return 'Max Tier';
    if (points >= 1500) return 'PLATINUM';
    if (points >= 500) return 'GOLD';
    return 'SILVER';
  }

  double _getTierProgress(int points) {
    if (points >= 3000) return 1.0;
    if (points >= 1500) return (points - 1500) / 1500;
    if (points >= 500) return (points - 500) / 1000;
    return points / 500;
  }
}
