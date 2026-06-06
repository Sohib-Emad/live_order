import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/widgets/avatar_widget.dart';

class PulsingAvatar extends StatefulWidget {
  final String imageUrl;
  final String fallbackName;

  const PulsingAvatar({
    super.key,
    required this.imageUrl,
    required this.fallbackName,
  });

  @override
  State<PulsingAvatar> createState() => _PulsingAvatarState();
}

class _PulsingAvatarState extends State<PulsingAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: 1.0 + (_controller.value * 0.8),
              child: Opacity(
                opacity: 1.0 - _controller.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppDesign.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Transform.scale(
              scale: 1.0 + (((_controller.value + 0.5) % 1.0) * 0.8),
              child: Opacity(
                opacity: 1.0 - ((_controller.value + 0.5) % 1.0),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppDesign.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: AvatarWidget(
                imageUrl: widget.imageUrl,
                fallbackName: widget.fallbackName,
                radius: 44.0,
              ),
            ),
          ],
        );
      },
    );
  }
}
