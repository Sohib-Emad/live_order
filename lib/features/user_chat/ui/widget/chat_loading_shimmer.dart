import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/widgets/loading_shimmer.dart';

class ChatLoadingShimmer extends StatelessWidget {
  const ChatLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
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
