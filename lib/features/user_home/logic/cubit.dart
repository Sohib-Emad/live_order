import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/features/user_home/data/repository/client_dashboard_repository.dart';
import 'package:live_order/features/user_home/logic/state.dart';

class ClientDashboardCubit extends Cubit<ClientDashboardState> {
  final ClientDashboardRepository _repository;

  ClientDashboardCubit(this._repository) : super(const ClientDashboardInitial());

  Future<void> loadDashboard() async {
    emit(const ClientDashboardLoading());
    final result = await _repository.getDashboard();
    result.fold(
      (error) => emit(ClientDashboardError(error)),
      (data) => emit(ClientDashboardLoaded(
        activeShipments: data.activeShipments,
        topDrivers: data.topDrivers,
        recentOrders: data.recentOrders,
      )),
    );
  }
}
