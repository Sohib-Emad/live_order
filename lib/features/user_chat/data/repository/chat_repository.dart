// lib/features/user_chat/data/repository/chat_repository.dart

import 'package:live_order/features/user_chat/data/api/chat_api.dart';
import 'package:live_order/features/user_chat/data/model/chat_message.dart';

class MarketChatRepository {
  final MarketChatApi _api;

  MarketChatRepository(this._api);

  Stream<List<ChatMessage>> streamMessages(String chatId) {
    return _api.streamMessages(chatId).map((list) {
      return list.map((data) {
        final timestampVal = data['timestamp'];
        String timestampStr;
        if (timestampVal is DateTime) {
          timestampStr = timestampVal.toIso8601String();
        } else {
          timestampStr = DateTime.now().toIso8601String();
        }
        return ChatMessage(
          id: data['id'] ?? '',
          senderId: data['senderId'] ?? '',
          text: data['text'] ?? '',
          timestamp: DateTime.parse(timestampStr),
          attachmentType: data['attachmentType'],
          attachmentUrl: data['attachmentUrl'],
          latitude: data['latitude'] != null ? (data['latitude'] as num).toDouble() : null,
          longitude: data['longitude'] != null ? (data['longitude'] as num).toDouble() : null,
        );
      }).toList();
    });
  }

  Future<void> sendMessage(String chatId, ChatMessage message) async {
    final messageData = {
      'senderId': message.senderId,
      'text': message.text,
      'timestamp': DateTime.now().toIso8601String(),
      if (message.attachmentType != null) 'attachmentType': message.attachmentType,
      if (message.attachmentUrl != null) 'attachmentUrl': message.attachmentUrl,
      if (message.latitude != null) 'latitude': message.latitude,
      if (message.longitude != null) 'longitude': message.longitude,
    };
    await _api.sendMessage(chatId, messageData);
  }

  Future<bool> hasActiveAcceptedOrder(String myUid, String driverId) async {
    final query1 = await _api.getOrdersByUserAndDriver(myUid, driverId);
    final query2 = await _api.getOrdersByUserAndDriver(driverId, myUid);
    final allDocs = [...query1, ...query2];
    return allDocs.any((doc) {
      final status = doc['order_status'] ?? doc['status'] ?? '';
      return status == 'Accepted' || status == 'In Transit';
    });
  }

  String? getCurrentUserId() => _api.getCurrentUserId();
}
