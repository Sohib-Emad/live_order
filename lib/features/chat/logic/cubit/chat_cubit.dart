import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/features/chat/data/repo/chat_repo.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo chatRepo;

  ChatCubit({required this.chatRepo}) : super(ChatInitial());

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
}
