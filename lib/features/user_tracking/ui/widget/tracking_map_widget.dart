import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/models/shipment.dart';

class TrackingMapWidget extends StatefulWidget {
  final Shipment shipment;
  const TrackingMapWidget({super.key, required this.shipment});

  @override
  State<TrackingMapWidget> createState() => _TrackingMapWidgetState();
}

class _TrackingMapWidgetState extends State<TrackingMapWidget> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _fitBounds(double lat1, double lon1, double lat2, double lon2) {
    final minLat = lat1 < lat2 ? lat1 : lat2;
    final maxLat = lat1 > lat2 ? lat1 : lat2;
    final minLng = lon1 < lon2 ? lon1 : lon2;
    final maxLng = lon1 > lon2 ? lon1 : lon2;

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50),
        );
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final pickup = LatLng(widget.shipment.pickupLat, widget.shipment.pickupLng);
    final drop = LatLng(widget.shipment.dropLat, widget.shipment.dropLng);

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('pickup'),
        position: pickup,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'موقع الاستلام'),
      ),
      Marker(
        markerId: const MarkerId('drop'),
        position: drop,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'موقع التسليم'),
      ),
    };

    final driver = widget.shipment.assignedDriver;
    final driverLat = driver?.currentLat;
    final driverLng = driver?.currentLong;
    if (driverLat != null && driverLng != null && (driverLat != 0 || driverLng != 0)) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(driverLat, driverLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(title: driver!.name),
        ),
      );
    }

    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('route'),
        points: [pickup, drop],
        color: AppDesign.primary,
        width: 3,
      ),
    };

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          key: ValueKey(widget.shipment.id),
          initialCameraPosition: CameraPosition(
            target: LatLng(
              (pickup.latitude + drop.latitude) / 2,
              (pickup.longitude + drop.longitude) / 2,
            ),
            zoom: 11.0,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            final lat1 = widget.shipment.pickupLat;
            final lon1 = widget.shipment.pickupLng;
            final lat2 = widget.shipment.dropLat;
            final lon2 = widget.shipment.dropLng;
            if ((lat1 == 0 && lon1 == 0) || (lat2 == 0 && lon2 == 0)) return;
            _fitBounds(lat1, lon1, lat2, lon2);
          },
          markers: markers,
          polylines: polylines,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          myLocationEnabled: false,
        ),
      ),
    );
  }
}
