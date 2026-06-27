// lib/features/user_chat/data/api/chat_api.dart

import 'package:live_order/core/services/supabase_service.dart';

class MarketChatApi {
  final supabase = SupabaseService.instance.client;

  Stream<List<Map<String, dynamic>>> streamMessages(String chatId) {
    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .map((list) => list.where((row) => row['chat_id'] == chatId).toList());
  }

  Future<void> sendMessage(String chatId, Map<String, dynamic> messageData) async {
    messageData['chat_id'] = chatId;
    await supabase.from('messages').insert(messageData);
  }

  Future<List<Map<String, dynamic>>> getOrdersByUserAndDriver(String userId, String driverId) async {
    return await supabase
        .from('orders')
        .select()
        .eq('order_user_id', userId)
        .eq('driver_id', driverId);
  }

  String? getCurrentUserId() {
    return supabase.auth.currentUser?.id;
  }
}
