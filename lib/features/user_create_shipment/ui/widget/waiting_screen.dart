import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/features/user_create_shipment/logic/cubit.dart';
import 'package:live_order/features/user_create_shipment/ui/widget/accepted_state.dart';
import 'package:live_order/features/user_create_shipment/ui/widget/pulsing_waiting_state.dart';
import 'package:live_order/features/user_create_shipment/ui/widget/rejected_state.dart';

class WaitingScreen extends StatelessWidget {
  final String? createdShipmentId;
  final Shipment? createdShipment;
  final UserProfile? selectedDriver;
  final VoidCallback onCancel;
  final VoidCallback onRetry;

  const WaitingScreen({
    super.key,
    required this.createdShipmentId,
    required this.createdShipment,
    required this.selectedDriver,
    required this.onCancel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (createdShipmentId == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppDesign.primary),
      );
    }

    return StreamBuilder<Map<String, dynamic>>(
      stream: context.read<CreateShipmentCubit>().getOrderStream(createdShipmentId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppDesign.primary),
          );
        }

        final data = snapshot.data;
        if (snapshot.hasError || data == null || data.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppDesign.danger,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'خطأ في تحميل تفاصيل الطلب',
                  style: AppDesign.heading(fontSize: 16.0),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('العودة للتعديل'),
                ),
              ],
            ),
          );
        }

        final row = snapshot.data ?? <String, dynamic>{};
        final dbShipment = Shipment.fromJson(row);
        final status = dbShipment.status;
        final driver = dbShipment.assignedDriver ?? selectedDriver;

        if (status == 'Waiting Driver') {
          return PulsingWaitingState(
            selectedDriver: driver,
            onCancel: onCancel,
          );
        } else if (status == 'Accepted') {
          return AcceptedState(
            shipment: dbShipment,
            selectedDriver: driver,
          );
        } else {
          return RejectedState(
            selectedDriver: driver,
            onRetry: onRetry,
          );
        }
      },
    );
  }
}
