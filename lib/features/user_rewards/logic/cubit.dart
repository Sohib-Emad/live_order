// lib/features/user_rewards/logic/cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/services/supabase_service.dart';
import 'package:live_order/features/user_rewards/data/model/reward_models.dart';
import 'package:live_order/features/user_rewards/data/repository/rewards_repository.dart';
import 'package:live_order/features/user_rewards/logic/state.dart';

class RewardsCubit extends Cubit<RewardsState> {
  final RewardsRepository _repository;
  StreamSubscription<int>? _pointsSubscription;
  StreamSubscription<List<RewardTransaction>>? _txSubscription;

  int _cachedPoints = 0;
  List<RewardTransaction> _cachedTx = [];

  RewardsCubit(this._repository) : super(RewardsInitial());

  Future<void> loadRewardsDetails() async {
    final uid = SupabaseService.instance.client.auth.currentUser?.id ?? 'client_1';
    emit(RewardsLoading());

    // 1. Listen to points stream
    _pointsSubscription?.cancel();
    _pointsSubscription = _repository.streamPoints(uid).listen(
      (pts) {
        _cachedPoints = pts;
        _emitLoadedState();
      },
      onError: (e) {
        emit(RewardsError(e.toString()));
      },
    );

    // 2. Listen to transactions stream
    _txSubscription?.cancel();
    _txSubscription = _repository.streamTransactions(uid).listen(
      (tx) {
        _cachedTx = tx;
        _emitLoadedState();
      },
      onError: (e) {
        emit(RewardsError(e.toString()));
      },
    );
  }

  Future<void> earnMockPoints(int points, String title) async {
    final uid = SupabaseService.instance.client.auth.currentUser?.id ?? 'client_1';
    final tx = RewardTransaction(
      id: '',
      points: points,
      title: title,
      type: 'earn',
      timestamp: DateTime.now(),
    );

    try {
      await _repository.addTransaction(uid, tx);
    } catch (e) {
      emit(RewardsError('Failed to reward points: ${e.toString()}'));
    }
  }

  Future<void> redeemMockPoints(int points, String title) async {
    final uid = SupabaseService.instance.client.auth.currentUser?.id ?? 'client_1';
    if (_cachedPoints < points) {
      emit(RewardsError('Insufficient points balance'));
      _emitLoadedState();
      return;
    }

    final tx = RewardTransaction(
      id: '',
      points: points,
      title: title,
      type: 'redeem',
      timestamp: DateTime.now(),
    );

    try {
      await _repository.addTransaction(uid, tx);
    } catch (e) {
      emit(RewardsError('Failed to redeem points: ${e.toString()}'));
    }
  }

  void _emitLoadedState() {
    emit(RewardsLoaded(_cachedPoints, _cachedTx));
  }

  @override
  Future<void> close() {
    _pointsSubscription?.cancel();
    _txSubscription?.cancel();
    return super.close();
  }
}
