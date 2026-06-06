import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/services/supabase_service.dart';
import 'package:live_order/features/driver_chat/ui/widgets/live_chat_sheet.dart';

class OrderChatButton extends StatelessWidget {
  final bool isDriver;
  final String clientId;
  final String driverId;
  final String orderName;

  const OrderChatButton({
    super.key,
    required this.isDriver,
    required this.clientId,
    required this.driverId,
    required this.orderName,
  });

  @override
  Widget build(BuildContext context) {
    final otherUserId = isDriver ? clientId : driverId;
    if (otherUserId.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: SupabaseService.instance.client
          .from('users')
          .stream(primaryKey: ['uid'])
          .map((list) => list.where((r) => r['uid'] == otherUserId).toList()),
      builder: (context, snapshot) {
        final usersList = snapshot.data ?? [];
        final data = usersList.isNotEmpty ? usersList.first : null;
        final otherName =
            data?['name'] ??
            data?['username'] ??
            (isDriver ? 'العميل' : 'الكابتن');

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB300).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => LiveChatSheet(
                  chatId: '${clientId}_${driverId}',
                  orderName: orderName,
                  otherUserName: otherName,
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_rounded, size: 20),
            label: Text(
              isDriver
                  ? 'محادثة العميل ($otherName)'
                  : 'محادثة الكابتن ($otherName)',
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
          ),
        );
      },
    );
  }
}
