import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/features/user_home/data/repository/client_dashboard_repository.dart';
import 'package:live_order/features/user_home/logic/state.dart';

class ClientDashboardCubit extends Cubit<ClientDashboardState> {
  final ClientDashboardRepository _repository;

  ClientDashboardCubit(this._repository) : super(ClientDashboardInitial());

  Future<void> loadDashboard() async {
    emit(ClientDashboardLoading());
    try {
      final data = await _repository.getDashboard();
      emit(ClientDashboardLoaded(
        activeShipments: data.activeShipments,
        topDrivers: data.topDrivers,
        recentOrders: data.recentOrders,
      ));
    } catch (e) {
      emit(ClientDashboardError(e.toString()));
    }
  }
}
