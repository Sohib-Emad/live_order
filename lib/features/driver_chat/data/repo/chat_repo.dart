import 'package:dartz/dartz.dart';
import 'package:live_order/features/driver_chat/data/api/chat_api.dart';

class ChatRepo {
  final ChatApi _chatApi;

  ChatRepo(this._chatApi);

  // Stream messages
  Stream<List<Map<String, dynamic>>> streamMessages(String chatId) {
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
        'timestamp': DateTime.now().toIso8601String(),
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
      final data = await _chatApi.getUserDoc(userId);
      if (data != null) {
        final name = data['name'] ?? data['username'] ?? 'مستخدم';
        return Right(name);
      }
      return const Right('مستخدم');
    } catch (e) {
      return Left(e.toString());
    }
  }

  // Stream user data by user ID
  Stream<List<Map<String, dynamic>>> streamClientData(String clientId) {
    return _chatApi.streamUserById(clientId);
  }
}
