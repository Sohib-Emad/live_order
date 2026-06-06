// lib/features/rate_driver/logic/cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/features/rate_driver/data/repository/rate_driver_repository.dart';
import 'package:live_order/features/rate_driver/logic/state.dart';

class RateDriverCubit extends Cubit<RateDriverState> {
  final RateDriverRepository _repository;

  RateDriverCubit(this._repository) : super(RateDriverInitial());

  Future<void> submitDriverReview({
    required String driverId,
    required double rating,
    required String comment,
    required List<String> tags,
    required String reviewerName,
  }) async {
    emit(RateDriverSubmitting());
    try {
      await _repository.submitReview(
        driverId: driverId,
        rating: rating,
        comment: comment,
        tags: tags,
        reviewerName: reviewerName,
      );
      emit(RateDriverSuccess());
    } catch (e) {
      emit(RateDriverError(e.toString()));
    }
  }
}
