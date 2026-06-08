import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/utils/logger.dart';

class MapLocation {
  final String address;
  final double latitude;
  final double longitude;

  MapLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class MapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final String title;

  const MapPickerScreen({
    super.key,
    this.initialLat,
    this.initialLng,
    required this.title,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  LatLng _centerPosition = const LatLng(31.0281827, 30.7120664);
  bool _isConfirming = false;
  String _currentAddress = '';
  bool _isLoadingAddress = false;

  // Search
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  // Pin animation
  late AnimationController _pinController;
  late Animation<double> _pinAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _centerPosition = LatLng(widget.initialLat!, widget.initialLng!);
    }
    _reverseGeocode(_centerPosition).then((addr) {
      if (mounted) setState(() => _currentAddress = addr);
    });

    _pinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _pinAnimation = Tween<double>(
      begin: 0.0,
      end: 6.0,
    ).animate(CurvedAnimation(parent: _pinController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  Future<String> _reverseGeocode(LatLng latLng) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse'
          '?lat=${latLng.latitude}&lon=${latLng.longitude}'
          '&format=json&accept-language=ar',
        ),
      );
      request.headers.set('User-Agent', 'LiveOrder/1.0');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;
      client.close();
      if (data['display_name'] is String) {
        return data['display_name'] as String;
      }
    } catch (e) {
      AppLogger.error('MapPicker', 'Reverse geocode failed', e);
    }
    return '';
  }

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search'
          '?q=${Uri.encodeQueryComponent(query)}'
          '&format=json&limit=15&dedupe=1'
          '&accept-language=ar',
        ),
      );
      request.headers.set('User-Agent', 'LiveOrder/1.0');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as List;
      client.close();

      setState(() {
        _searchResults = data.cast<Map<String, dynamic>>();
        _isSearching = false;
      });
    } catch (e) {
      AppLogger.error('MapPicker', 'Search failed', e);
      setState(() => _isSearching = false);
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchPlaces(query);
    });
  }

  void _goToPlace(double lat, double lng, String displayName) {
    setState(() {
      _searchResults = [];
      _searchController.text = displayName;
      _currentAddress = displayName;
    });
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 16.0),
      ),
    );
  }

  Future<void> _goToMyLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('الرجاء تفعيل خدمة الموقع من الإعدادات'),
            ),
          );
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('صلاحية الوصول للموقع مطلوبة')),
          );
        }
        return;
      }

      Position pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.lowest,
            timeLimit: Duration(seconds: 5),
          ),
        );
      } catch (_) {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          pos = last;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تعذر الحصول على الموقع، تأكد من تفعيل GPS'),
              ),
            );
          }
          return;
        }
      }

      final target = LatLng(pos.latitude, pos.longitude);
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 16.0),
        ),
      );
    } catch (e, s) {
      AppLogger.error('MapPicker', 'Get current location failed', e, s);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
      }
    }
  }

  Future<void> _confirmLocation() async {
    setState(() => _isConfirming = true);

    String address = _currentAddress;
    if (address.isEmpty) {
      address =
          '${_centerPosition.latitude.toStringAsFixed(4)}, ${_centerPosition.longitude.toStringAsFixed(4)}';
    }

    if (mounted) {
      Navigator.pop(
        context,
        MapLocation(
          address: address,
          latitude: _centerPosition.latitude,
          longitude: _centerPosition.longitude,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // Map
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _centerPosition,
                zoom: 14.0,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onCameraMoveStarted: () {
                setState(() => _isLoadingAddress = true);
              },
              onCameraMove: (position) {
                _centerPosition = position.target;
              },
              onCameraIdle: () async {
                final addr = await _reverseGeocode(_centerPosition);
                if (mounted) {
                  setState(() {
                    _currentAddress = addr;
                    _isLoadingAddress = false;
                  });
                }
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              padding: EdgeInsets.only(top: 100, bottom: 220),
            ),

            // Search bar
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      textDirection: TextDirection.rtl,
                      style: AppDesign.body(
                        color: AppDesign.textPrimary,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن عنوان أو مكان...',
                        hintTextDirection: TextDirection.rtl,
                        hintStyle: AppDesign.body(
                          color: AppDesign.textSecondary.withValues(alpha: 0.6),
                          fontSize: 15,
                        ),
                        prefixIcon: _isSearching
                            ? Padding(
                                padding: const EdgeInsets.all(14),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppDesign.primary,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.search_rounded,
                                color: AppDesign.textSecondary,
                                size: 22,
                              ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: AppDesign.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchResults = []);
                                },
                              )
                            : Icon(
                                Icons.location_on_rounded,
                                color: AppDesign.primary,
                                size: 22,
                              ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  if (_searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(maxHeight: 240),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: _searchResults.length,
                        separatorBuilder: (_, _) => Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: AppDesign.border,
                        ),
                        itemBuilder: (context, index) {
                          final place = _searchResults[index];
                          final lat = double.parse(place['lat'] as String);
                          final lon = double.parse(place['lon'] as String);
                          final name = place['display_name'] as String;
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.location_on_rounded,
                              color: AppDesign.danger,
                              size: 20,
                            ),
                            title: Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppDesign.body(
                                color: AppDesign.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                            onTap: () => _goToPlace(lat, lon, name),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // Animated pin
            IgnorePointer(
              child: Center(
                child: AnimatedBuilder(
                  animation: _pinAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -_pinAnimation.value),
                      child: child,
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppDesign.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: AppDesign.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.my_location_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppDesign.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom card
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).padding.bottom + 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppDesign.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Address
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppDesign.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: AppDesign.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الموقع المحدد',
                                style: AppDesign.body(
                                  color: AppDesign.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (_isLoadingAddress)
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppDesign.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'جاري تحديد الموقع...',
                                      style: AppDesign.body(
                                        color: AppDesign.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  _currentAddress.isEmpty
                                      ? 'حرك الخريطة لتحديد الموقع'
                                      : _currentAddress,
                                  style: AppDesign.body(
                                    color: AppDesign.textPrimary,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Confirm button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isConfirming ? null : _confirmLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppDesign.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppDesign.primary
                              .withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isConfirming
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'تأكيد الموقع',
                                style: AppDesign.body(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // My location button
            Positioned(
              top: MediaQuery.of(context).padding.top + 76,
              right: 16,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                elevation: 4,
                shadowColor: Colors.black26,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _goToMyLocation(),
                  child: const SizedBox(
                    width: 52,
                    height: 52,
                    child: Icon(
                      Icons.my_location_rounded,
                      color: AppDesign.primary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),

            // Back button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppDesign.textPrimary,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
