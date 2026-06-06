// lib/features/market_chat/data/repository/chat_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_order/features/market_chat/data/api/chat_api.dart';
import 'package:live_order/features/market_chat/data/model/chat_message.dart';

class MarketChatRepository {
  final MarketChatApi _api;

  MarketChatRepository(this._api);

  Stream<List<ChatMessage>> streamMessages(String chatId) {
    return _api.streamMessages(chatId).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final timestampVal = data['timestamp'];
        String timestampStr;
        if (timestampVal is Timestamp) {
          timestampStr = timestampVal.toDate().toIso8601String();
        } else {
          timestampStr = DateTime.now().toIso8601String();
        }
        return ChatMessage(
          id: doc.id,
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
      'timestamp': FieldValue.serverTimestamp(),
      if (message.attachmentType != null) 'attachmentType': message.attachmentType,
      if (message.attachmentUrl != null) 'attachmentUrl': message.attachmentUrl,
      if (message.latitude != null) 'latitude': message.latitude,
      if (message.longitude != null) 'longitude': message.longitude,
    };
    await _api.sendMessage(chatId, messageData);
  }
}
