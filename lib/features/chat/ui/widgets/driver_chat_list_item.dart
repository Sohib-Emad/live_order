import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/features/add_order/models/order_model.dart';
import 'package:live_order/features/chat/ui/widgets/live_chat_sheet.dart';
import 'package:live_order/features/chat/data/repo/chat_repo.dart';
import 'package:live_order/core/di/di.dart';

class DriverChatListItem extends StatefulWidget {
  final OrderModel order;

  const DriverChatListItem({
    super.key,
    required this.order,
  });

  @override
  State<DriverChatListItem> createState() => _DriverChatListItemState();
}

class _DriverChatListItemState extends State<DriverChatListItem> {
  late final Stream<DocumentSnapshot> _clientStream;
  late final Stream<QuerySnapshot> _msgStream;

  @override
  void initState() {
    super.initState();
    final chatId = '${widget.order.orderUserId}_${widget.order.driverId}';
    final chatRepo = getIt<ChatRepo>();

    _clientStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.order.orderUserId)
        .snapshots();
    _msgStream = chatRepo.streamMessages(chatId);
  }

  @override
  Widget build(BuildContext context) {
    final chatId = '${widget.order.orderUserId}_${widget.order.driverId}';

    return StreamBuilder<DocumentSnapshot>(
      stream: _clientStream,
      builder: (context, clientSnapshot) {
        final clientData = clientSnapshot.data?.data() as Map<String, dynamic>?;
        final clientName =
            clientData?['name'] ?? clientData?['username'] ?? 'عميل الشحنة';
        final avatarChar = clientName.isNotEmpty ? clientName[0] : 'ع';

        return StreamBuilder<QuerySnapshot>(
          stream: _msgStream,
          builder: (context, msgSnapshot) {
            String lastMsgText = 'لا توجد رسائل بعد. اضغط لبدء المحادثة!';
            String lastMsgTime = '';
            int unreadCount = 0;

            final docs = msgSnapshot.data?.docs ?? [];
            if (docs.isNotEmpty) {
              // msgStream is sorted ascending, so last element is the newest!
              final msgData = docs.last.data() as Map<String, dynamic>;
              lastMsgText = msgData['text'] ?? '';
              final timestamp = msgData['timestamp'] as Timestamp?;
              if (timestamp != null) {
                final date = timestamp.toDate();
                lastMsgTime =
                    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
              }

              // Count unread messages where sender is NOT the current driver
              unreadCount = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final senderId = data['sender_id'];
                final isRead = data['is_read'] ?? false;
                return senderId != FirebaseAuth.instance.currentUser?.uid &&
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
                    color: Colors.black.withOpacity(0.02),
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
                    backgroundColor: const Color(0xFFFFB300).withOpacity(0.12),
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
                          color: const Color(0xFFFFB300).withOpacity(0.1),
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
