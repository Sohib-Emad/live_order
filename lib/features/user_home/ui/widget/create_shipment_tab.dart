import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_order/core/di/di.dart';
import 'package:live_order/features/user_create_shipment/logic/cubit.dart';
import 'package:live_order/features/user_create_shipment/ui/screen.dart';
import 'package:live_order/features/session/logic/cubit/home_cubit.dart';
import 'package:live_order/features/session/logic/state.dart';
import 'package:live_order/features/user_home/ui/widget/active_shipment_alert.dart';

class CreateShipmentTab extends StatelessWidget {
  final VoidCallback onTrackShipment;
  final VoidCallback onGoBack;

  const CreateShipmentTab({
    super.key,
    required this.onTrackShipment,
    required this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    final homeState = context.read<HomeCubit>().state;
    if (homeState is HomeLoaded) {
      final hasActiveShipment = homeState.orders.any(
        (order) =>
            order.status == 'Waiting Driver' ||
            order.status == 'Accepted' ||
            order.status == 'In Transit' ||
            order.status == 'Created',
      );
      if (hasActiveShipment) {
        return ActiveShipmentAlert(
          onTrackShipment: onTrackShipment,
          onGoBack: onGoBack,
        );
      }
    }
    return BlocProvider<CreateShipmentCubit>(
      create: (context) => getIt<CreateShipmentCubit>(),
      child: const CreateShipmentScreen(),
    );
  }
}
