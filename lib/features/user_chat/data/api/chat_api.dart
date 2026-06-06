// lib/features/market_chat/data/api/chat_api.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class MarketChatApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> streamMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> sendMessage(String chatId, Map<String, dynamic> messageData) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);
  }
}
