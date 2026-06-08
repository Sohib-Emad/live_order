import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/features/user_chat/data/model/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final bool isMe;

  const ChatMessageBubble({
    super.key,
    required this.msg,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
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
              color: Colors.black.withValues(alpha: 0.015),
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
}
