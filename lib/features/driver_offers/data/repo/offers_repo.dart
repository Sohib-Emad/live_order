import 'package:dartz/dartz.dart';
import 'package:live_order/features/driver_offers/data/api/offers_api.dart';

class OffersRepo {
  final OffersApi _offersApi;

  OffersRepo(this._offersApi);

  // Stream active offers for a driver
  Stream<List<Map<String, dynamic>>> streamDriverOffers(String driverId) {
    return _offersApi.streamDriverOffers(driverId);
  }

  // Update offer status
  Future<Either<String, void>> updateOfferStatus(String orderId, String status) async {
    try {
      await _offersApi.updateOfferStatus(orderId, status);
      return const Right(null);
    } catch (e) {
      return Left('فشل تحديث حالة العرض: $e');
    }
  }
}
