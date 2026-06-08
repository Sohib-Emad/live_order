import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/services/supabase_service.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/features/driver_chat/data/repo/chat_repo.dart';
import 'package:live_order/core/di/di.dart';

class LiveChatSheet extends StatefulWidget {
  final String chatId;
  final String orderName;
  final String otherUserName;

  const LiveChatSheet({
    super.key,
    required this.chatId,
    required this.orderName,
    required this.otherUserName,
  });

  @override
  State<LiveChatSheet> createState() => _LiveChatSheetState();
}

class _LiveChatSheetState extends State<LiveChatSheet> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String? _myUid = SupabaseService.instance.client.auth.currentUser?.id;

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _markMessagesAsRead(List<Map<String, dynamic>> docs) {
    if (_myUid == null) return;
    final unreadDocs = docs.where((data) {
      final senderId = data['sender_id'];
      final isRead = data['is_read'];
      return senderId != _myUid && (isRead == false || isRead == null);
    }).toList();

    if (unreadDocs.isEmpty) return;

    final chatRepo = getIt<ChatRepo>();
    for (var doc in unreadDocs) {
      final msgId = doc['id'] as String?;
      if (msgId != null) {
        chatRepo.markMessageAsRead(widget.chatId, msgId);
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _myUid == null) return;

    _textController.clear();

    try {
      final chatRepo = getIt<ChatRepo>();
      final nameResult = await chatRepo.getSenderName(_myUid);
      nameResult.fold(
        (err) => debugPrint('Error getting sender name: $err'),
        (senderName) async {
          await chatRepo.sendMessage(
            widget.chatId,
            text: text,
            senderId: _myUid,
            senderName: senderName,
          );
          Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
        },
      );
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatRepo = getIt<ChatRepo>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          ),
          child: Column(
            children: [
              // Pull Handle & Header
              Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22.r,
                      backgroundColor: const Color(
                        0xFFFFB300,
                      ).withValues(alpha: 0.12),
                      child: Text(
                        widget.otherUserName.isNotEmpty
                            ? widget.otherUserName[0]
                            : 'ك',
                        style: TextStyle(
                          color: const Color(0xFFFFB300),
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    const WidthSpace(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.otherUserName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            'طلب شحن: ${widget.orderName}',
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 18),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey[100], height: 1),

              // Messages Stream
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: chatRepo.streamMessages(widget.chatId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'حدث خطأ في تحميل الرسائل',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12.sp,
                          ),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFFFB300),
                          ),
                        ),
                      );
                    }

                    final docs = snapshot.data ?? [];
                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 48.sp,
                              color: Colors.grey[300],
                            ),
                            const HeightSpace(12),
                            Text(
                              'لا توجد رسائل بعد. ابدأ المحادثة الآن!',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Schedule scroll to bottom after list builds
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                      _markMessagesAsRead(docs);
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index];
                        final text = data['text'] ?? '';
                        final senderId = data['sender_id'] ?? '';
                        final isMe = senderId == _myUid;
                        final ts = data['timestamp'];
                        DateTime? timestamp;
                        if (ts is DateTime) {
                          timestamp = ts;
                        } else if (ts is String) {
                          timestamp = DateTime.tryParse(ts);
                        }
                        final timeStr = timestamp != null
                            ? '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}'
                            : '';

                        return Align(
                          alignment: isMe
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                if (!isMe) ...[
                                  Text(
                                    data['sender_name'] ?? widget.otherUserName,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  const HeightSpace(4),
                                ],
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? const Color(0xFFFFB300)
                                        : const Color(0xFFF1F3F4),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16.r),
                                      topRight: Radius.circular(16.r),
                                      bottomLeft: isMe
                                          ? Radius.circular(16.r)
                                          : Radius.circular(0.r),
                                      bottomRight: isMe
                                          ? Radius.circular(0.r)
                                          : Radius.circular(16.r),
                                    ),
                                  ),
                                  child: Text(
                                    text,
                                    style: TextStyle(
                                      color: isMe
                                          ? Colors.white
                                          : const Color(0xFF1A1A1A),
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (timeStr.isNotEmpty) ...[
                                  const HeightSpace(4),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                    ),
                                    child: Text(
                                      timeStr,
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Input Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _textController,
                        cursorColor: const Color(0xFFFFB300),
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالتك here...',
                          hintStyle: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[400],
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.r),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.r),
                            borderSide: const BorderSide(
                              color: Color(0xFFFFB300),
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7F8F9),
                        ),
                        onFieldSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const WidthSpace(8),
                    CircleAvatar(
                      radius: 22.r,
                      backgroundColor: const Color(0xFF1A1A1A),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
