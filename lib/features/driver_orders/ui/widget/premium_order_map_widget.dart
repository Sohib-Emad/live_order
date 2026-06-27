import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/core/utils/logger.dart';

class PremiumOrderMapWidget extends StatefulWidget {
  final Shipment order;
  const PremiumOrderMapWidget({super.key, required this.order});

  @override
  State<PremiumOrderMapWidget> createState() => _PremiumOrderMapWidgetState();
}

class _PremiumOrderMapWidgetState extends State<PremiumOrderMapWidget> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    final lat1 = widget.order.dropLat;
    final lon1 = widget.order.dropLng;
    final lat2 = widget.order.pickupLat;
    final lon2 = widget.order.pickupLng;

    if ((lat1 == 0 && lon1 == 0) ||
        (lat2 == 0 && lon2 == 0) ||
        (lat1 == lat2 && lon1 == lon2)) {
      return;
    }

    final minLat = lat1 < lat2 ? lat1 : lat2;
    final maxLat = lat1 > lat2 ? lat1 : lat2;
    final minLng = lon1 < lon2 ? lon1 : lon2;
    final maxLng = lon1 > lon2 ? lon1 : lon2;

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    Future.delayed(const Duration(milliseconds: 1000), () {
      try {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50.w),
        );
      } catch (e) {
        AppLogger.error('PremiumOrderMap', 'Error animating camera to bounds', e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pickup = LatLng(widget.order.dropLat, widget.order.dropLng);
    final destination = LatLng(widget.order.pickupLat, widget.order.pickupLng);

    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('pickup'),
        position: pickup,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: const InfoWindow(title: 'موقع الاستلام (العميل)'),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: 'وجهة التوصيل'),
      ),
    };

    final Set<Polyline> polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: [pickup, destination],
        color: const Color(0xFFFFB300),
        width: 4,
        geodesic: true,
      ),
    };

    return Container(
      width: double.infinity,
      height: 220.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              (pickup.latitude + destination.latitude) / 2,
              (pickup.longitude + destination.longitude) / 2,
            ),
            zoom: 12.0,
          ),
          onMapCreated: _onMapCreated,
          markers: markers,
          polylines: polylines,
          myLocationEnabled: false,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
        ),
      ),
    );
  }
}
