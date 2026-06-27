import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/features/driver_chat/ui/widgets/live_chat_sheet.dart';
import 'package:live_order/features/driver_chat/logic/cubit/chat_cubit.dart';

class DriverChatListItem extends StatefulWidget {
  final Shipment order;

  const DriverChatListItem({
    super.key,
    required this.order,
  });

  @override
  State<DriverChatListItem> createState() => _DriverChatListItemState();
}

class _DriverChatListItemState extends State<DriverChatListItem> {
  late final Stream<List<Map<String, dynamic>>> _clientStream;
  late final Stream<List<Map<String, dynamic>>> _msgStream;
  late final ChatCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ChatCubit>();
    final chatId = '${widget.order.clientId}_${widget.order.driverId}';

    _clientStream = _cubit.streamClientData(widget.order.clientId);
    _msgStream = _cubit.streamMessages(chatId);
  }

  @override
  Widget build(BuildContext context) {
    final chatId = '${widget.order.clientId}_${widget.order.driverId}';

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _clientStream,
      builder: (context, clientSnapshot) {
        final usersList = clientSnapshot.data ?? [];
        final clientData = usersList.isNotEmpty ? usersList.first : null;
        final clientName =
            clientData?['name'] ?? clientData?['username'] ?? 'عميل الشحنة';
        final avatarChar = clientName.isNotEmpty ? clientName[0] : 'ع';

        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _msgStream,
          builder: (context, msgSnapshot) {
            String lastMsgText = 'لا توجد رسائل بعد. اضغط لبدء المحادثة!';
            String lastMsgTime = '';
            int unreadCount = 0;

            final docs = msgSnapshot.data ?? [];
            if (docs.isNotEmpty) {
              final msgData = docs.last;
              lastMsgText = msgData['text'] ?? '';
              final ts = msgData['timestamp'];
              DateTime? timestamp;
              if (ts is DateTime) {
                timestamp = ts;
              } else if (ts is String) {
                timestamp = DateTime.tryParse(ts);
              }
              if (timestamp != null) {
                lastMsgTime =
                    '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
              }

              // Count unread messages where sender is NOT the current driver
              unreadCount = docs.where((data) {
                final senderId = data['sender_id'];
                final isRead = data['is_read'] ?? false;
                return senderId != _cubit.currentUserId &&
                    isRead == false;
              }).length;
            }

            final isUnread = unreadCount > 0;

            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  leading: CircleAvatar(
                    radius: 24.r,
                    backgroundColor: const Color(0xFFFFB300).withValues(alpha: 0.12),
                    child: Text(
                      avatarChar,
                      style: TextStyle(
                        color: const Color(0xFFFFB300),
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          clientName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isUnread
                                ? const Color(0xFF1A1A1A)
                                : Colors.grey[700],
                            fontWeight: isUnread
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB300).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          widget.order.orderName,
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: const Color(0xFFFFB300),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      lastMsgText,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isUnread ? Colors.black87 : Colors.grey[600],
                        fontWeight: isUnread
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        lastMsgTime,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                      if (isUnread) ...[
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFB300),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => LiveChatSheet(
                        chatId: chatId,
                        orderName: widget.order.orderName,
                        otherUserName: clientName,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
