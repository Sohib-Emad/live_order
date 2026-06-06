// lib/features/market_chat/logic/state.dart

import 'package:live_order/features/market_chat/data/model/chat_message.dart';

abstract class MarketChatState {}

class MarketChatInitial extends MarketChatState {}

class MarketChatLoading extends MarketChatState {}

class MarketChatLoaded extends MarketChatState {
  final List<ChatMessage> messages;
  final bool isTyping;

  MarketChatLoaded(this.messages, {this.isTyping = false});

  MarketChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
  }) {
    return MarketChatLoaded(
      messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class MarketChatError extends MarketChatState {
  final String message;
  MarketChatError(this.message);
}
