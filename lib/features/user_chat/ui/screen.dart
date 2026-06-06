// lib/features/market_chat/ui/screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/features/market_chat/data/model/chat_message.dart';
import 'package:live_order/features/market_chat/logic/cubit.dart';
import 'package:live_order/features/market_chat/logic/state.dart';
import 'package:live_order/shared/widgets/avatar_widget.dart';
import 'package:live_order/shared/widgets/empty_state.dart';
import 'package:live_order/shared/widgets/loading_shimmer.dart';

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
      body: Column(
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
                  return _buildLoadingShimmer();
                } else if (state is MarketChatError) {
                  return Center(
                    child: EmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Error loading messages',
                      subtitle: state.message,
                      actionLabel: 'Retry',
                      onActionTap: () => context.read<MarketChatCubit>().loadMessages(widget.driver.uid),
                    ),
                  );
                } else if (state is MarketChatLoaded) {
                  final messages = state.messages;
                  if (messages.isEmpty) {
                    return Center(
                      child: EmptyState(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Start chatting',
                        subtitle: 'Send a message to align on shipment details.',
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: AppDesign.space16, vertical: AppDesign.space16),
                    itemCount: messages.length + (state.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        return _buildTypingIndicator();
                      }
                      final msg = messages[index];
                      final isMe = msg.senderId != widget.driver.uid;
                      return _buildMessageBubble(msg, isMe);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

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
                        hintText: 'Type your message...',
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
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDesign.space12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppDesign.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe ? null : Border.all(color: AppDesign.border, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppDesign.space16, vertical: AppDesign.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.attachmentType == 'image') ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  msg.attachmentUrl!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 140,
                      color: AppDesign.surface,
                      child: const Icon(Icons.image_not_supported_outlined, color: AppDesign.textSecondary),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppDesign.space8),
            ] else if (msg.attachmentType == 'location') ...[
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Live Location shared (${msg.latitude!.toStringAsFixed(4)}, ${msg.longitude!.toStringAsFixed(4)})',
                      style: AppDesign.body(
                        color: isMe ? Colors.white : AppDesign.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDesign.space8),
            ],
            Text(
              msg.text,
              style: AppDesign.body(
                color: isMe ? Colors.white : AppDesign.textPrimary,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDesign.space12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppDesign.border, width: 1.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppDesign.space16, vertical: AppDesign.space12),
        child: Text(
          'typing...',
          style: AppDesign.body(color: AppDesign.textSecondary, fontSize: 12.0),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDesign.space16),
      itemCount: 4,
      itemBuilder: (context, index) {
        final isMe = index % 2 == 0;
        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppDesign.space16),
            child: LoadingShimmer(
              width: 200,
              height: 60,
              borderRadius: 12,
            ),
          ),
        );
      },
    );
  }
}
