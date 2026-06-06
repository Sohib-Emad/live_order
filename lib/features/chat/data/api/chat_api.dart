import 'package:cloud_firestore/cloud_firestore.dart';

class ChatApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream messages in a chat room sorted by timestamp
  Stream<QuerySnapshot> streamMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Send a new message to a chat room
  Future<void> sendMessage(String chatId, Map<String, dynamic> messageData) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);
  }

  // Mark a specific message as read
  Future<void> markMessageAsRead(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'is_read': true});
  }

  // Get user details for sender display
  Future<DocumentSnapshot> getUserDoc(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }
}
