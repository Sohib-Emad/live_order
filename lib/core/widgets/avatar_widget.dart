// lib/shared/widgets/avatar_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String fallbackName;
  final double radius;
  final Color? backgroundColor;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    required this.fallbackName,
    this.radius = 24.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final initials = fallbackName.trim().isNotEmpty
        ? fallbackName.trim().split(' ').map((e) => e[0].toUpperCase()).take(2).join()
        : '?';

    final bg = backgroundColor ?? AppDesign.primary.withValues(alpha: 0.08);

    if (imageUrl != null && imageUrl!.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            placeholder: (context, url) => Center(
              child: SizedBox(
                width: radius,
                height: radius,
                child: const CircularProgressIndicator(strokeWidth: 2.0),
              ),
            ),
            errorWidget: (context, url, error) => Center(
              child: Text(
                initials,
                style: AppDesign.body(
                  color: AppDesign.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: radius * 0.7,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: Text(
        initials,
        style: AppDesign.body(
          color: AppDesign.primary,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}
