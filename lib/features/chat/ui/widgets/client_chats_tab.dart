import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/features/add_order/models/order_model.dart';
import 'package:live_order/features/chat/ui/widgets/client_chat_list_item.dart';

class ClientChatsTab extends StatelessWidget {
  final List<OrderModel> allOrders;

  const ClientChatsTab({super.key, required this.allOrders});

  @override
  Widget build(BuildContext context) {
    final chatOrders = allOrders.where((o) => o.driverId.isNotEmpty).toList();
    final seenDrivers = <String>{};
    final uniqueChatOrders = <OrderModel>[];
    for (var order in chatOrders) {
      if (!seenDrivers.contains(order.orderId)) {
        seenDrivers.add(order.orderId);
        uniqueChatOrders.add(order);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
          color: const Color(0xFF1E2028),
          child: Row(
            children: [
              Icon(Icons.chat_bubble_rounded, color: const Color(0xFFFFB300), size: 22.sp),
              SizedBox(width: 10.w),
              Text(
                'المحادثات المباشرة',
                style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ],
          ),
        ),
        Expanded(
          child: uniqueChatOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, size: 56.sp, color: Colors.grey[800]),
                      SizedBox(height: 12.h),
                      Text(
                        'لا توجد محادثات نشطة مع الكباتن',
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey[600], fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                  itemCount: uniqueChatOrders.length,
                  itemBuilder: (context, index) {
                    final order = uniqueChatOrders[index];
                    return ClientChatListItem(order: order);
                  },
                ),
        ),
      ],
    );
  }
}
