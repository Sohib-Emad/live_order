// lib/features/market_chat/logic/cubit.dart

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/features/market_chat/data/model/chat_message.dart';
import 'package:live_order/features/market_chat/data/repository/chat_repository.dart';
import 'package:live_order/features/market_chat/logic/state.dart';

class MarketChatCubit extends Cubit<MarketChatState> {
  final MarketChatRepository _repository;
  StreamSubscription<List<ChatMessage>>? _subscription;
  String? _activeChatId;
  String? _currentUserId;

  MarketChatCubit(this._repository) : super(MarketChatInitial()) {
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> loadMessages(String driverId) async {
    final myUid = _currentUserId ?? FirebaseAuth.instance.currentUser?.uid ?? 'client_1';
    _currentUserId = myUid;
    
    // Consistent chatId construction
    final chatId = myUid.compareTo(driverId) < 0 ? '${myUid}_$driverId' : '${driverId}_$myUid';
    _activeChatId = chatId;

    emit(MarketChatLoading());
    
    _subscription?.cancel();
    _subscription = _repository.streamMessages(chatId).listen(
      (messages) {
        emit(MarketChatLoaded(messages));
      },
      onError: (e) {
        emit(MarketChatError(e.toString()));
      },
    );
  }

  Future<void> sendMessage(String text) async {
    final chatId = _activeChatId;
    final myUid = _currentUserId ?? 'client_1';
    if (chatId == null) return;

    final newMessage = ChatMessage(
      id: '',
      senderId: myUid,
      text: text,
      timestamp: DateTime.now(),
    );

    try {
      await _repository.sendMessage(chatId, newMessage);
    } catch (e) {
      emit(MarketChatError('Failed to send message: ${e.toString()}'));
    }
  }

  Future<void> sendLocation(double lat, double lng) async {
    final chatId = _activeChatId;
    final myUid = _currentUserId ?? 'client_1';
    if (chatId == null) return;

    final newMessage = ChatMessage(
      id: '',
      senderId: myUid,
      text: 'Shared Location',
      timestamp: DateTime.now(),
      attachmentType: 'location',
      latitude: lat,
      longitude: lng,
    );

    try {
      await _repository.sendMessage(chatId, newMessage);
    } catch (e) {
      emit(MarketChatError('Failed to send location: ${e.toString()}'));
    }
  }

  Future<void> sendImage(String imageUrl) async {
    final chatId = _activeChatId;
    final myUid = _currentUserId ?? 'client_1';
    if (chatId == null) return;

    final newMessage = ChatMessage(
      id: '',
      senderId: myUid,
      text: 'Sent an image',
      timestamp: DateTime.now(),
      attachmentType: 'image',
      attachmentUrl: imageUrl,
    );

    try {
      await _repository.sendMessage(chatId, newMessage);
    } catch (e) {
      emit(MarketChatError('Failed to send image: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
