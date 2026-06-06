// lib/features/rewards/logic/state.dart

import 'package:live_order/features/rewards/data/model/reward_models.dart';

abstract class RewardsState {}

class RewardsInitial extends RewardsState {}

class RewardsLoading extends RewardsState {}

class RewardsLoaded extends RewardsState {
  final int points;
  final List<RewardTransaction> transactions;

  RewardsLoaded(this.points, this.transactions);
}

class RewardsError extends RewardsState {
  final String message;
  RewardsError(this.message);
}
