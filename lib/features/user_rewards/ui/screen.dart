// lib/features/rewards/ui/screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/features/rewards/data/model/reward_models.dart';
import 'package:live_order/features/rewards/logic/cubit.dart';
import 'package:live_order/features/rewards/logic/state.dart';
import 'package:live_order/shared/widgets/empty_state.dart';
import 'package:live_order/shared/widgets/loading_shimmer.dart';

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
            return _buildLoadingState();
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
                    // Prominent Point Balance & Tier Card
                    _buildBalanceCard(points, tier, nextTier, progress),

                    const SizedBox(height: AppDesign.space24),

                    // Referral Panel
                    _buildReferralCard(),

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
                      _buildTransactionsList(state.transactions),
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

  Widget _buildBalanceCard(int points, String tier, String nextTier, double progress) {
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
            color: AppDesign.primary.withOpacity(0.15),
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
                  color: Colors.white.withOpacity(0.15),
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
              backgroundColor: Colors.white.withOpacity(0.15),
              color: AppDesign.success,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard() {
    return Container(
      padding: const EdgeInsets.all(AppDesign.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: AppDesign.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppDesign.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.share_rounded, color: AppDesign.primary, size: 20),
              ),
              const SizedBox(width: AppDesign.space12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invite Friends, Earn Points',
                    style: AppDesign.body(color: AppDesign.textPrimary, fontWeight: FontWeight.bold, fontSize: 14.0),
                  ),
                  Text(
                    'Get 150 points for each signup.',
                    style: AppDesign.body(color: AppDesign.textSecondary, fontSize: 11.5),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDesign.space16),
          Container(
            padding: const EdgeInsets.all(AppDesign.space12),
            decoration: BoxDecoration(
              color: AppDesign.surface,
              borderRadius: BorderRadius.circular(AppDesign.radius8),
              border: Border.all(color: AppDesign.border, width: 1.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _referralCode,
                  style: AppDesign.heading(color: AppDesign.textPrimary, fontSize: 15.0),
                ),
                GestureDetector(
                  onTap: _copyReferral,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppDesign.space16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppDesign.primary,
                      borderRadius: BorderRadius.circular(AppDesign.radius8),
                    ),
                    child: Text(
                      'Copy Code',
                      style: AppDesign.body(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<RewardTransaction> list) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final tx = list[index];
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

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(AppDesign.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          LoadingShimmer(width: double.infinity, height: 160, borderRadius: 12),
          SizedBox(height: 24),
          LoadingShimmer(width: double.infinity, height: 100, borderRadius: 12),
          SizedBox(height: 24),
          LoadingShimmer(width: 150, height: 20),
          SizedBox(height: 12),
          LoadingShimmer(width: double.infinity, height: 60, borderRadius: 12),
        ],
      ),
    );
  }
}
