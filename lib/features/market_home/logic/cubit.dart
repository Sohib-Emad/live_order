// lib/features/market_home/logic/cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/features/market_home/data/repository/market_home_repository.dart';
import 'package:live_order/features/market_home/logic/state.dart';

class MarketHomeCubit extends Cubit<MarketHomeState> {
  final MarketHomeRepository _repository;

  MarketHomeCubit(this._repository) : super(MarketHomeInitial());

  Future<void> loadDashboard() async {
    emit(MarketHomeLoading());
    try {
      final active = await _repository.getActiveShipments();
      final topDrivers = await _repository.getTopDrivers();
      final recent = await _repository.getRecentOrders();
      emit(MarketHomeLoaded(
        activeShipments: active,
        topDrivers: topDrivers,
        recentOrders: recent,
      ));
    } catch (e) {
      emit(MarketHomeError(e.toString()));
    }
  }
}
