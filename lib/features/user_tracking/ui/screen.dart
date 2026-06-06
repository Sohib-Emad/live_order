import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/features/user_tracking/logic/cubit.dart';
import 'package:live_order/features/user_tracking/logic/state.dart';
import 'package:live_order/features/user_tracking/ui/widget/back_button.dart';
import 'package:live_order/features/user_tracking/ui/widget/decorative_circle.dart';
import 'package:live_order/features/user_tracking/ui/widget/driver_card.dart';
import 'package:live_order/features/user_tracking/ui/widget/eta_banner.dart';
import 'package:live_order/features/user_tracking/ui/widget/status_pill.dart';
import 'package:live_order/features/user_tracking/ui/widget/timeline_widget.dart';
import 'package:live_order/core/widgets/app_button.dart';
import 'package:live_order/features/user_tracking/ui/widget/tracking_map_widget.dart';

class ShipmentTrackingScreen extends StatefulWidget {
  final Shipment shipment;

  const ShipmentTrackingScreen({super.key, required this.shipment});

  @override
  State<ShipmentTrackingScreen> createState() => _ShipmentTrackingScreenState();
}

class _ShipmentTrackingScreenState extends State<ShipmentTrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    context.read<TrackingCubit>().startTracking(
      widget.shipment.id,
      widget.shipment,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: BlocBuilder<TrackingCubit, TrackingState>(
          builder: (context, state) {
            Shipment activeShipment = widget.shipment;
            if (state is TrackingStreaming) {
              activeShipment = state.shipment;
            }

            return Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFF3E8),
                        Color(0xFFFEF6EC),
                        Color(0xFFF8F9FA),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  top: -60,
                  left: -60,
                  child: DecorativeCircle(size: 200, opacity: 0.06),
                ),
                Positioned(
                  top: 40,
                  right: -80,
                  child: DecorativeCircle(size: 260, opacity: 0.04),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            TrackingBackButton(onTap: () => Navigator.pop(context)),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'تتبع الشحنة',
                                  style: AppDesign.heading(fontSize: 18.0),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 40,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    StatusPill(
                                      label: _statusLabel(
                                        activeShipment.status,
                                      ),
                                      color: _statusColor(
                                        activeShipment.status,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      height: 180,
                                      child: AnimatedBuilder(
                                        animation: _pulseAnimation,
                                        builder: (context, child) =>
                                            Transform.scale(
                                              scale: _pulseAnimation.value,
                                              child: child,
                                            ),
                                        child: Lottie.asset(
                                          'assets/lottie/Delivery guy.json',
                                          fit: BoxFit.contain,
                                          repeat: true,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'شحنتك في الطريق إليك!',
                                      style: AppDesign.heading(fontSize: 18.0),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'سيصلك الكابتن في أقرب وقت ممكن',
                                      style: AppDesign.body(
                                        color: AppDesign.textSecondary,
                                        fontSize: 13.0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              EtaBanner(shipmentId: activeShipment.id),
                              const SizedBox(height: 16),
                              TrackingMapWidget(shipment: activeShipment),
                              const SizedBox(height: 24),
                              if (activeShipment.assignedDriver != null) ...[
                                DriverCard(shipment: activeShipment),
                                const SizedBox(height: 24),
                              ],
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'حالة الشحنة',
                                      style: AppDesign.heading(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 16),
                                    TrackingTimeline(shipment: activeShipment),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppButton(
                                      label: 'إلغاء التوصيل',
                                      variant: AppButtonVariant.secondary,
                                      onTap: () {
                                        AnimatedSnackBar.material(
                                          'تم إرسال طلب إلغاء التوصيل.',
                                          type: AnimatedSnackBarType.info,
                                          mobileSnackBarPosition:
                                              MobileSnackBarPosition.top,
                                        ).show(context);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: AppButton(
                                      label: 'الاتصال بالدعم',
                                      onTap: () {},
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'Accepted':
        return 'تم القبول';
      case 'In Transit':
        return 'جاري التوصيل';
      case 'Delivered':
        return 'تم التسليم';
      default:
        return 'قيد المعالجة';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Accepted':
        return AppDesign.warning;
      case 'In Transit':
        return AppDesign.primary;
      case 'Delivered':
        return AppDesign.success;
      default:
        return AppDesign.textSecondary;
    }
  }
}
