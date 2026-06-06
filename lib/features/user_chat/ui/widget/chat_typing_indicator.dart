import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

class ChatTypingIndicator extends StatelessWidget {
  const ChatTypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
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
}
