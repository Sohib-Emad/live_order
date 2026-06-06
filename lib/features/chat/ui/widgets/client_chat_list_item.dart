import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/features/add_order/models/order_model.dart';
import 'package:live_order/features/chat/ui/widgets/live_chat_sheet.dart';
import 'package:live_order/features/chat/data/repo/chat_repo.dart';
import 'package:live_order/core/di/di.dart';

class ClientChatListItem extends StatefulWidget {
  final OrderModel order;

  const ClientChatListItem({super.key, required this.order});

  @override
  State<ClientChatListItem> createState() => _ClientChatListItemState();
}

class _ClientChatListItemState extends State<ClientChatListItem> {
  @override
  Widget build(BuildContext context) {
    final chatRepo = getIt<ChatRepo>();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.order.driverId)
          .snapshots(),
      builder: (context, driverSnapshot) {
        final driverData = driverSnapshot.data?.data() as Map<String, dynamic>?;
        final driverName =
            driverData?['name'] ?? driverData?['username'] ?? 'كابتن توصيل';
        final avatarChar = driverName.isNotEmpty ? driverName[0] : 'ك';
        final chatId = '${widget.order.orderUserId}_${widget.order.driverId}';

        return StreamBuilder<QuerySnapshot>(
          stream: chatRepo.streamMessages(chatId),
          builder: (context, msgSnapshot) {
            String lastMsgText = 'لا توجد رسائل بعد. اضغط لبدء المحادثة!';
            String lastMsgTime = '';
            int unreadCount = 0;

            final docs = msgSnapshot.data?.docs ?? [];
            if (docs.isNotEmpty) {
              // Get the LAST message (descending in StreamBuilder? No, streamMessages sorts ascending by default, so last document in ascending list is the most recent!)
              final msgData = docs.last.data() as Map<String, dynamic>;
              lastMsgText = msgData['text'] ?? '';
              final timestamp = msgData['timestamp'] as Timestamp?;
              if (timestamp != null) {
                final date = timestamp.toDate();
                lastMsgTime =
                    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
              }

              // Count unread messages in memory where sender is NOT the current user
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
                color: const Color(0xFF1E2028),
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
                          driverName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isUnread
                                ? Colors.white
                                : Colors.grey[300],
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
                        color: isUnread ? Colors.white70 : Colors.grey[500],
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
                      builder: (context) => LiveChatSheet(
                        chatId: chatId,
                        orderName: widget.order.orderName,
                        otherUserName: driverName,
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
