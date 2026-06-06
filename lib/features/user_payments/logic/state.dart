// lib/features/user_payments/logic/state.dart

import 'package:live_order/features/user_payments/data/model/payment_models.dart';

abstract class PaymentsState {}

class PaymentsInitial extends PaymentsState {}

class PaymentsLoading extends PaymentsState {}

class PaymentsLoaded extends PaymentsState {
  final List<SavedCard> cards;
  final List<PaymentTransaction> transactions;
  final bool isCashPreferred;

  PaymentsLoaded(this.cards, this.transactions, {this.isCashPreferred = false});

  PaymentsLoaded copyWith({
    List<SavedCard>? cards,
    List<PaymentTransaction>? transactions,
    bool? isCashPreferred,
  }) {
    return PaymentsLoaded(
      cards ?? this.cards,
      transactions ?? this.transactions,
      isCashPreferred: isCashPreferred ?? this.isCashPreferred,
    );
  }
}

class PaymentsError extends PaymentsState {
  final String message;
  PaymentsError(this.message);
}
