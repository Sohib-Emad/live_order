// lib/features/user_chat/ui/screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/features/user_chat/logic/cubit.dart';
import 'package:live_order/features/user_chat/logic/state.dart';
import 'package:live_order/core/widgets/avatar_widget.dart';
import 'package:live_order/core/widgets/empty_state.dart';
import 'package:live_order/features/user_chat/ui/widget/chat_message_bubble.dart';
import 'package:live_order/features/user_chat/ui/widget/chat_typing_indicator.dart';
import 'package:live_order/features/user_chat/ui/widget/chat_loading_shimmer.dart';
import 'package:live_order/features/user_chat/ui/widget/chat_restricted_view.dart';

class MarketChatScreen extends StatefulWidget {
  final UserProfile driver;

  const MarketChatScreen({
    super.key,
    required this.driver,
  });

  @override
  State<MarketChatScreen> createState() => _MarketChatScreenState();
}

class _MarketChatScreenState extends State<MarketChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<MarketChatCubit>().loadMessages(widget.driver.uid);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    context.read<MarketChatCubit>().sendMessage(text);
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _sendMockLocation() {
    // Shared mock location coordinates for Cairo
    context.read<MarketChatCubit>().sendLocation(30.0444, 31.2357);
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _sendMockImage() {
    // Cairo cargo image mock
    context.read<MarketChatCubit>().sendImage('https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=500');
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppDesign.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            AvatarWidget(
              imageUrl: widget.driver.imageUrl,
              fallbackName: widget.driver.name,
              radius: 18.0,
            ),
            const SizedBox(width: AppDesign.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.driver.name,
                    style: AppDesign.heading(fontSize: 15.0),
                  ),
                  Text(
                    widget.driver.vehicleType ?? 'Driver',
                    style: AppDesign.body(color: AppDesign.textSecondary, fontSize: 11.0),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined, color: AppDesign.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling ${widget.driver.name}...'),
                  backgroundColor: AppDesign.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<MarketChatCubit, MarketChatState>(
        builder: (context, state) {
          if (state is MarketChatRestricted) {
            return ChatRestrictedView(message: state.message, onBack: () => Navigator.pop(context));
          }

          return Column(
            children: [
              // Message stream area
              Expanded(
                child: BlocConsumer<MarketChatCubit, MarketChatState>(
                  listener: (context, state) {
                    if (state is MarketChatLoaded) {
                      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                    }
                  },
                  builder: (context, state) {
                    if (state is MarketChatLoading) {
                      return const ChatLoadingShimmer();
                    } else if (state is MarketChatError) {
                      return Center(
                        child: EmptyState(
                          icon: Icons.error_outline_rounded,
                          title: 'حدث خطأ في تحميل الرسائل',
                          subtitle: state.message,
                          actionLabel: 'إعادة المحاولة',
                          onActionTap: () => context.read<MarketChatCubit>().loadMessages(widget.driver.uid),
                        ),
                      );
                    } else if (state is MarketChatLoaded) {
                      final messages = state.messages;
                      if (messages.isEmpty) {
                        return Center(
                          child: EmptyState(
                            icon: Icons.chat_bubble_outline_rounded,
                            title: 'ابدأ المحادثة الآن',
                            subtitle: 'أرسل رسالة للاتفاق على تفاصيل شحن وتوصيل البضائع.',
                          ),
                        );
                      }
                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: AppDesign.space16, vertical: AppDesign.space16),
                        itemCount: messages.length + (state.isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == messages.length) {
                            return const ChatTypingIndicator();
                          }
                          final msg = messages[index];
                          final isMe = msg.senderId != widget.driver.uid;
                          return ChatMessageBubble(msg: msg, isMe: isMe);
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),

              // Action toolbar and input bar only visible when chat is loaded successfully
              if (state is MarketChatLoaded) ...[
                // Action toolbar above input
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: AppDesign.space16, vertical: AppDesign.space4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.image_outlined, color: AppDesign.textSecondary, size: 20),
                        onPressed: _sendMockImage,
                      ),
                      IconButton(
                        icon: const Icon(Icons.location_on_outlined, color: AppDesign.textSecondary, size: 20),
                        onPressed: _sendMockLocation,
                      ),
                    ],
                  ),
                ),

                // Custom premium text input bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(
                    AppDesign.space16,
                    AppDesign.space8,
                    AppDesign.space16,
                    AppDesign.space16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppDesign.surface,
                            borderRadius: BorderRadius.circular(AppDesign.radius24),
                            border: Border.all(color: AppDesign.border, width: 1.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: AppDesign.space16),
                          child: TextField(
                            controller: _textController,
                            cursorColor: AppDesign.primary,
                            style: AppDesign.body(color: AppDesign.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'اكتب رسالتك هنا...',
                              hintStyle: AppDesign.body(color: AppDesign.textSecondary.withOpacity(0.6)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: AppDesign.space12),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDesign.space12),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          padding: const EdgeInsets.all(AppDesign.space12),
                          decoration: const BoxDecoration(
                            color: AppDesign.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
