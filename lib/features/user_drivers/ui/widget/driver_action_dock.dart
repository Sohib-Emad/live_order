import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/widgets/app_button.dart';

class DriverActionDock extends StatelessWidget {
  final VoidCallback onChatTap;

  const DriverActionDock({super.key, required this.onChatTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDesign.space16,
          vertical: AppDesign.space16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppDesign.radius24),
            topRight: Radius.circular(AppDesign.radius24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: const Color(0xFFF3F4F6),
              width: 1.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'بدء دردشة وتواصل مع الكابتن',
                  onTap: onChatTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
