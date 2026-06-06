import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:live_order/features/chat/data/api/chat_api.dart';

class ChatRepo {
  final ChatApi _chatApi;

  ChatRepo(this._chatApi);

  // Stream messages
  Stream<QuerySnapshot> streamMessages(String chatId) {
    return _chatApi.streamMessages(chatId);
  }

  // Send a message
  Future<Either<String, void>> sendMessage(
    String chatId, {
    required String text,
    required String senderId,
    required String senderName,
  }) async {
    try {
      final messageData = {
        'text': text,
        'sender_id': senderId,
        'sender_name': senderName,
        'timestamp': FieldValue.serverTimestamp(),
        'is_read': false,
      };
      await _chatApi.sendMessage(chatId, messageData);
      return const Right(null);
    } catch (e) {
      return Left('فشل إرسال الرسالة: $e');
    }
  }

  // Mark a message as read
  Future<Either<String, void>> markMessageAsRead(String chatId, String messageId) async {
    try {
      await _chatApi.markMessageAsRead(chatId, messageId);
      return const Right(null);
    } catch (e) {
      return Left('فشل تحديث الرسالة كمقروءة: $e');
    }
  }

  // Fetch sender name
  Future<Either<String, String>> getSenderName(String userId) async {
    try {
      final doc = await _chatApi.getUserDoc(userId);
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name'] ?? data['username'] ?? 'مستخدم';
        return Right(name);
      }
      return const Right('مستخدم');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
