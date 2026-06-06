// lib/features/tracking/ui/screen.dart

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/features/tracking/logic/cubit.dart';
import 'package:live_order/features/tracking/logic/state.dart';
import 'package:live_order/shared/widgets/app_button.dart';
import 'package:live_order/shared/widgets/avatar_widget.dart';

class ShipmentTrackingScreen extends StatefulWidget {
  final Shipment shipment;

  const ShipmentTrackingScreen({super.key, required this.shipment});

  @override
  State<ShipmentTrackingScreen> createState() => _ShipmentTrackingScreenState();
}

class _ShipmentTrackingScreenState extends State<ShipmentTrackingScreen> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    context.read<TrackingCubit>().startTracking(widget.shipment.id, widget.shipment);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Standard Cairo/Heliopolis center point
    final LatLng pickupLatLng = LatLng(
      widget.shipment.pickupLat != 0.0 ? widget.shipment.pickupLat : 30.0984,
      widget.shipment.pickupLng != 0.0 ? widget.shipment.pickupLng : 31.3323,
    );
    final LatLng dropLatLng = LatLng(
      widget.shipment.dropLat != 0.0 ? widget.shipment.dropLat : 30.0264,
      widget.shipment.dropLng != 0.0 ? widget.shipment.dropLng : 31.4925,
    );

    return Scaffold(
      body: BlocBuilder<TrackingCubit, TrackingState>(
        builder: (context, state) {
          Shipment activeShipment = widget.shipment;
          if (state is TrackingStreaming) {
            activeShipment = state.shipment;
          }

          return Stack(
            children: [
              // Full-screen Map
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: pickupLatLng,
                  initialZoom: 12.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.liveorder.app',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [pickupLatLng, dropLatLng],
                        color: AppDesign.primary,
                        strokeWidth: 4.0,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: pickupLatLng,
                        width: 32,
                        height: 32,
                        child: const Icon(Icons.circle, color: AppDesign.primary, size: 24),
                      ),
                      Marker(
                        point: dropLatLng,
                        width: 32,
                        height: 32,
                        child: const Icon(Icons.location_on_rounded, color: AppDesign.danger, size: 30),
                      ),
                    ],
                  ),
                ],
              ),

              // Floating Back Button
              Positioned(
                top: MediaQuery.of(context).padding.top + AppDesign.space16,
                left: AppDesign.space16,
                child: FloatingActionButton.small(
                  onPressed: () => context.pop(),
                  backgroundColor: Colors.white,
                  elevation: 2,
                  child: const Icon(Icons.arrow_back_rounded, color: AppDesign.textPrimary),
                ),
              ),

              // Draggable bottom sheet with status and driver info
              _buildDraggableBottomSheet(activeShipment),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDraggableBottomSheet(Shipment shipment) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppDesign.radius24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppDesign.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pull Bar
                Center(
                  child: Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppDesign.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppDesign.space16),

                // Title & ETA Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      shipment.id,
                      style: AppDesign.heading(fontSize: 18.0),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppDesign.space12, vertical: AppDesign.space4),
                      decoration: BoxDecoration(
                        color: AppDesign.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDesign.radius24),
                      ),
                      child: Text(
                        'ETA: 24 Mins',
                        style: AppDesign.body(color: AppDesign.success, fontWeight: FontWeight.bold, fontSize: 12.0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDesign.space20),

                // Driver card
                if (shipment.assignedDriver != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppDesign.space12),
                    decoration: BoxDecoration(
                      color: AppDesign.surface,
                      borderRadius: BorderRadius.circular(AppDesign.radius12),
                      border: Border.all(color: AppDesign.border),
                    ),
                    child: Row(
                      children: [
                        AvatarWidget(
                          imageUrl: shipment.assignedDriver!.imageUrl,
                          fallbackName: shipment.assignedDriver!.name,
                          radius: 20.0,
                        ),
                        const SizedBox(width: AppDesign.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shipment.assignedDriver!.name,
                                style: AppDesign.body(color: AppDesign.textPrimary, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${shipment.assignedDriver!.vehicleType} • ${shipment.assignedDriver!.vehiclePlate}',
                                style: AppDesign.body(color: AppDesign.textSecondary, fontSize: 11.0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppDesign.space8),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppDesign.primary),
                          onPressed: () => context.pushNamed('market_chat', extra: shipment.assignedDriver),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDesign.space24),
                ],

                // Status Timeline
                Text('Shipment Progress', style: AppDesign.heading(fontSize: 14.0)),
                const SizedBox(height: AppDesign.space16),
                _buildTimelineStep('Picked Up', 'Driver picked up cargo from Heliopolis', isCompleted: true),
                _buildTimelineStep('In Transit', 'Driver is on the way to New Cairo', isCompleted: shipment.status == 'In Transit', isLast: true),

                const SizedBox(height: AppDesign.space24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Cancel Delivery',
                        variant: AppButtonVariant.secondary,
                        onTap: () {
                          AnimatedSnackBar.material(
                            'Cancel request sent to driver.',
                            type: AnimatedSnackBarType.info,
                            mobileSnackBarPosition: MobileSnackBarPosition.top,
                          ).show(context);
                        },
                      ),
                    ),
                    const SizedBox(width: AppDesign.space12),
                    Expanded(
                      child: AppButton(
                        label: 'Contact Support',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineStep(String label, String time, {bool isCompleted = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 6,
              backgroundColor: isCompleted ? AppDesign.primary : AppDesign.border,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isCompleted ? AppDesign.primary : AppDesign.border,
              ),
          ],
        ),
        const SizedBox(width: AppDesign.space16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppDesign.body(
                  color: isCompleted ? AppDesign.textPrimary : AppDesign.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(time, style: AppDesign.body(color: AppDesign.textSecondary, fontSize: 11.5)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
