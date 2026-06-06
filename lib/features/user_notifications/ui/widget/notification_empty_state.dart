import 'package:flutter/material.dart';
import 'package:live_order/core/widgets/empty_state.dart';

class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: EmptyState(
        icon: Icons.notifications_off_outlined,
        title: 'لا توجد إشعارات جديدة',
        subtitle: 'صندوق الإشعارات فارغ تماماً حالياً.',
      ),
    );
  }
}
