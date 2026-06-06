import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/features/driver_offers/data/repo/offers_repo.dart';

part 'offers_state.dart';

class OffersCubit extends Cubit<OffersState> {
  final OffersRepo offersRepo;

  OffersCubit({required this.offersRepo}) : super(OffersInitial());

  // Accept offer
  void acceptOffer(String orderId) async {
    emit(OffersLoading());
    final result = await offersRepo.updateOfferStatus(orderId, 'Accepted');
    result.fold(
      (error) => emit(OffersError(message: error)),
      (_) => emit(OffersSuccess()),
    );
  }

  // Reject offer
  void rejectOffer(String orderId) async {
    emit(OffersLoading());
    final result = await offersRepo.updateOfferStatus(orderId, 'Cancelled');
    result.fold(
      (error) => emit(OffersError(message: error)),
      (_) => emit(OffersSuccess()),
    );
  }
}
