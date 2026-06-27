import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/core/utils/logger.dart';
import 'package:live_order/features/driver_orders/data/repo/add_order_repo.dart';

part 'add_order_state.dart';

class AddOrderCubit extends Cubit<AddOrderState> {
  final AddOrderRepo addOrderRepo;

  AddOrderCubit({required this.addOrderRepo}) : super(const AddOrderInitial());

  void createOrder(Shipment order) async {
    AppLogger.info('AddOrderCubit', 'createOrder called for ${order.orderName}');
    emit(const AddOrderLoading());
    final result = await addOrderRepo.createOrder(order);
    result.fold(
      (error) {
        AppLogger.error('AddOrderCubit', 'createOrder failed', error);
        emit(AddOrderError(message: error));
      },
      (_) => emit(const AddOrderSuccess()),
    );
  }

  void getAvailableDrivers() async {
    emit(const AddOrderLoading());
    final result = await addOrderRepo.getAvailableDrivers();
    result.fold(
      (error) => emit(AddOrderError(message: error)),
      (drivers) => emit(DriversLoaded(drivers: drivers)),
    );
  }

  Stream<List<Map<String, dynamic>>> streamOrder(String orderId) {
    return addOrderRepo.streamOrder(orderId);
  }

  Stream<List<Map<String, dynamic>>> streamUser(String userId) {
    return addOrderRepo.streamUser(userId);
  }

  void rateDriverAndComplete({
    required String shipmentId,
    required String driverId,
    required double newRating,
    required String review,
  }) async {
    AppLogger.info('AddOrderCubit', 'rateDriverAndComplete called for shipment $shipmentId');
    emit(const AddOrderLoading());
    final result = await addOrderRepo.rateDriverAndComplete(
      shipmentId: shipmentId,
      driverId: driverId,
      newRating: newRating,
      review: review,
    );
    result.fold(
      (error) {
        AppLogger.error('AddOrderCubit', 'rateDriverAndComplete failed', error);
        emit(AddOrderError(message: error));
      },
      (_) => emit(const AddOrderSuccess()),
    );
  }
}
