import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthBackground extends StatelessWidget {
  final Animation<double> animation;

  const AuthBackground({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color(0xFFF5F5F0)),
        Positioned(
          top: -60.h,
          right: -60.w,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Container(
                width: 300.w,
                height: 300.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xfffdad2b).withOpacity(0.24 * animation.value),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: -80.h,
          left: -80.w,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Container(
                width: 330.w,
                height: 330.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xfffdad2b).withOpacity(0.14 * animation.value),
                ),
              );
            },
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 95.0, sigmaY: 95.0),
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }
}
