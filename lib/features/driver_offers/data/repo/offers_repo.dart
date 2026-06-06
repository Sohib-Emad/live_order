import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:live_order/features/offers/data/api/offers_api.dart';

class OffersRepo {
  final OffersApi _offersApi;

  OffersRepo(this._offersApi);

  // Stream active offers for a driver
  Stream<QuerySnapshot> streamDriverOffers(String driverId) {
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
