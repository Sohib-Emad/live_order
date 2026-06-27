import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/features/driver_orders/logic/cubit/add_order_cubit.dart';
import 'package:live_order/features/driver_orders/ui/widget/order_details_body.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Shipment order;
  final bool isDriver;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    this.isDriver = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: context.read<AddOrderCubit>().streamOrder(order.id),
      builder: (context, snapshot) {
        final ordersList = snapshot.data ?? [];
        final currentOrder = ordersList.isNotEmpty
            ? Shipment.fromJson(ordersList.first)
            : order;

        return OrderDetailsBody(order: currentOrder, isDriver: isDriver);
      },
    );
  }
}
