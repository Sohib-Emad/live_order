// lib/features/payments/logic/cubit.dart

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/features/payments/data/model/payment_models.dart';
import 'package:live_order/features/payments/data/repository/payments_repository.dart';
import 'package:live_order/features/payments/logic/state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  final PaymentsRepository _repository;
  StreamSubscription<List<SavedCard>>? _cardsSubscription;
  StreamSubscription<List<PaymentTransaction>>? _txSubscription;

  List<SavedCard> _cachedCards = [];
  List<PaymentTransaction> _cachedTx = [];
  bool _isCashPreferred = false;

  PaymentsCubit(this._repository) : super(PaymentsInitial());

  Future<void> loadPaymentDetails() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'client_1';
    emit(PaymentsLoading());

    // 1. Listen to saved cards stream
    _cardsSubscription?.cancel();
    _cardsSubscription = _repository.streamSavedCards(uid).listen(
      (cards) {
        _cachedCards = cards;
        _emitLoadedState();
      },
      onError: (e) {
        emit(PaymentsError(e.toString()));
      },
    );

    // 2. Listen to transactions stream
    _txSubscription?.cancel();
    _txSubscription = _repository.streamTransactions(uid).listen(
      (tx) {
        _cachedTx = tx;
        _emitLoadedState();
      },
      onError: (e) {
        emit(PaymentsError(e.toString()));
      },
    );
  }

  void togglePaymentPreference(bool selectCash) {
    _isCashPreferred = selectCash;
    _emitLoadedState();
  }

  Future<void> addNewCard({
    required String holderName,
    required String cardNumber,
    required String expiryDate,
    required String cardType,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'client_1';
    final card = SavedCard(
      id: '',
      cardHolder: holderName,
      cardNumber: cardNumber,
      expiryDate: expiryDate,
      cardType: cardType,
    );

    try {
      await _repository.addCard(uid, card);
    } catch (e) {
      emit(PaymentsError('Failed to add card: ${e.toString()}'));
    }
  }

  Future<void> removeCard(String cardId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'client_1';
    try {
      await _repository.deleteCard(uid, cardId);
    } catch (e) {
      emit(PaymentsError('Failed to delete card: ${e.toString()}'));
    }
  }

  Future<void> addMockTransaction(double amount, String title, String category) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'client_1';
    final tx = PaymentTransaction(
      id: '',
      amount: amount,
      title: title,
      timestamp: DateTime.now(),
      status: 'Completed',
      category: category,
    );

    try {
      await _repository.addTransaction(uid, tx);
    } catch (e) {
      emit(PaymentsError('Failed to record transaction: ${e.toString()}'));
    }
  }

  void _emitLoadedState() {
    emit(PaymentsLoaded(
      _cachedCards,
      _cachedTx,
      isCashPreferred: _isCashPreferred,
    ));
  }

  @override
  Future<void> close() {
    _cardsSubscription?.cancel();
    _txSubscription?.cancel();
    return super.close();
  }
}
