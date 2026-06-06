import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/features/add_order/models/order_model.dart';
import 'package:live_order/features/add_order/models/user_model.dart';
import 'package:live_order/features/add_order/data/repo/add_order_repo.dart';

part 'add_order_state.dart';

class AddOrderCubit extends Cubit<AddOrderState> {
  final AddOrderRepo addOrderRepo;

  AddOrderCubit({required this.addOrderRepo}) : super(AddOrderInitial());

  void createOrder(OrderModel order) async {
    emit(AddOrderLoading());
    final result = await addOrderRepo.createOrder(order);
    result.fold(
      (error) => emit(AddOrderError(message: error)),
      (_) => emit(AddOrderSuccess()),
    );
  }

  void getAvailableDrivers() async {
    emit(AddOrderLoading());
    final result = await addOrderRepo.getAvailableDrivers();
    result.fold(
      (error) => emit(AddOrderError(message: error)),
      (drivers) => emit(DriversLoaded(drivers: drivers)),
    );
  }

  void rateDriverAndComplete({
    required String shipmentId,
    required String driverId,
    required double newRating,
    required String review,
  }) async {
    emit(AddOrderLoading());
    final result = await addOrderRepo.rateDriverAndComplete(
      shipmentId: shipmentId,
      driverId: driverId,
      newRating: newRating,
      review: review,
    );
    result.fold(
      (error) => emit(AddOrderError(message: error)),
      (_) => emit(AddOrderSuccess()),
    );
  }
}
