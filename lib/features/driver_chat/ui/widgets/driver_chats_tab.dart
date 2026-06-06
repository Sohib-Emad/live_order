import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/features/driver_chat/ui/widgets/driver_chat_list_item.dart';
import 'package:live_order/core/constants/app_design.dart';

class DriverChatsTab extends StatelessWidget {
  final List<Shipment> allOrders;

  const DriverChatsTab({
    super.key,
    required this.allOrders,
  });

  @override
  Widget build(BuildContext context) {
    final chatOrders = allOrders
        .where(
          (o) => o.status != 'Waiting Driver' && o.status != 'Cancelled',
        )
        .toList();

    // Group orders by client (clientId) to only show one chat room per client!
    final seenClients = <String>{};
    final uniqueChatOrders = <Shipment>[];
    for (var order in chatOrders) {
      if (!seenClients.contains(order.clientId)) {
        seenClients.add(order.clientId);
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
            style: AppDesign.heading(
              fontSize: 20.sp,
              color: AppDesign.textPrimary,
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
                          style: AppDesign.heading(
                            fontSize: 13.sp,
                            color: AppDesign.textPrimary,
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
