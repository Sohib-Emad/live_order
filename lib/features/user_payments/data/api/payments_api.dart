// lib/features/user_payments/data/api/payments_api.dart

import 'package:live_order/core/services/supabase_service.dart';

class PaymentsApi {
  final supabase = SupabaseService.instance.client;

  Stream<List<Map<String, dynamic>>> streamSavedCards(String userId) {
    return supabase
        .from('cards')
        .stream(primaryKey: ['id'])
        .map((list) => list.where((row) => row['user_id'] == userId).toList());
  }

  Stream<List<Map<String, dynamic>>> streamTransactions(String userId) {
    return supabase
        .from('transactions')
        .stream(primaryKey: ['id'])
        .map((list) => list.where((row) => row['user_id'] == userId).toList());
  }

  Future<void> addCard(String userId, Map<String, dynamic> cardData) async {
    cardData['user_id'] = userId;
    await supabase.from('cards').insert(cardData);
  }

  Future<void> deleteCard(String userId, String cardId) async {
    await supabase.from('cards').delete().eq('id', cardId).eq('user_id', userId);
  }

  Future<void> addTransaction(String userId, Map<String, dynamic> txData) async {
    txData['user_id'] = userId;
    await supabase.from('transactions').insert(txData);
  }
}
