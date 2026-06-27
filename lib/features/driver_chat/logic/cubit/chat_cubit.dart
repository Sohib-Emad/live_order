import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/services/supabase_service.dart';
import 'package:live_order/features/driver_chat/data/repo/chat_repo.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo chatRepo;

  ChatCubit({required this.chatRepo}) : super(ChatInitial());

  String? get currentUserId => SupabaseService.instance.client.auth.currentUser?.id;

  // Stream messages
  Stream<List<Map<String, dynamic>>> streamMessages(String chatId) {
    return chatRepo.streamMessages(chatId);
  }

  // Stream client user data
  Stream<List<Map<String, dynamic>>> streamClientData(String clientId) {
    return chatRepo.streamClientData(clientId);
  }

  // Send message
  void sendMessage(
    String chatId, {
    required String text,
    required String senderId,
  }) async {
    emit(ChatLoading());
    // Get sender name first
    final nameResult = await chatRepo.getSenderName(senderId);
    nameResult.fold(
      (error) => emit(ChatError(message: error)),
      (senderName) async {
        final result = await chatRepo.sendMessage(
          chatId,
          text: text,
          senderId: senderId,
          senderName: senderName,
        );
        result.fold(
          (error) => emit(ChatError(message: error)),
          (_) => emit(ChatSuccess()),
        );
      },
    );
  }

  // Mark message as read
  void markAsRead(String chatId, String messageId) async {
    await chatRepo.markMessageAsRead(chatId, messageId);
  }

  // Get sender name
  Future<Either<String, String>> getSenderName(String userId) {
    return chatRepo.getSenderName(userId);
  }
}
