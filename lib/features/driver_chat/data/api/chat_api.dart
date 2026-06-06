import 'package:live_order/core/services/supabase_service.dart';

class ChatApi {
  final supabase = SupabaseService.instance.client;

  // Stream messages in a chat room sorted by timestamp
  Stream<List<Map<String, dynamic>>> streamMessages(String chatId) {
    return supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .map((list) => list
            .where((r) => r['chat_id'] == chatId)
            .toList()
          ..sort((a, b) {
            final at = a['timestamp'];
            final bt = b['timestamp'];
            if (at is DateTime && bt is DateTime) return at.compareTo(bt);
            return 0;
          }));
  }

  // Send a new message to a chat room
  Future<void> sendMessage(String chatId, Map<String, dynamic> messageData) async {
    await supabase
        .from('chat_messages')
        .insert({'chat_id': chatId, ...messageData});
  }

  // Mark a specific message as read
  Future<void> markMessageAsRead(String chatId, String messageId) async {
    await supabase
        .from('chat_messages')
        .update({'is_read': true})
        .eq('id', messageId);
  }

  // Get user details for sender display
  Future<Map<String, dynamic>?> getUserDoc(String userId) async {
    return await supabase.from('users').select().eq('uid', userId).single();
  }
}
