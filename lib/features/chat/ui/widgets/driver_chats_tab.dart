import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/features/add_order/models/order_model.dart';
import 'package:live_order/features/chat/ui/widgets/driver_chat_list_item.dart';

class DriverChatsTab extends StatelessWidget {
  final List<OrderModel> allOrders;

  const DriverChatsTab({
    super.key,
    required this.allOrders,
  });

  static const _dark = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    final chatOrders = allOrders
        .where(
          (o) =>
              o.orderStatus != 'Waiting Driver' && o.orderStatus != 'Cancelled',
        )
        .toList();

    // Group orders by client (orderUserId) to only show one chat room per client!
    final seenClients = <String>{};
    final uniqueChatOrders = <OrderModel>[];
    for (var order in chatOrders) {
      if (!seenClients.contains(order.orderUserId)) {
        seenClients.add(order.orderUserId);
        uniqueChatOrders.add(order);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
          child: Text(
            'محادثات العملاء النشطة',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: _dark,
            ),
          ),
        ),
        const HeightSpace(16),
        Expanded(
          child: chatOrders.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 56.sp,
                          color: Colors.grey[300],
                        ),
                        const HeightSpace(12),
                        Text(
                          'لا توجد محادثات جارية.',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  itemCount: uniqueChatOrders.length,
                  itemBuilder: (context, index) {
                    final order = uniqueChatOrders[index];
                    return DriverChatListItem(
                      order: order,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
