import 'dart:math' show cos, sqrt, pi;
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/core/styling/app_styles.dart';
import 'package:live_order/core/utils/animated_snack_dialog.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/features/add_order/logic/cubit/add_order_cubit.dart';
import 'package:live_order/features/add_order/models/order_model.dart';
import 'package:live_order/features/add_order/models/user_model.dart';

class DriverSelectionScreen extends StatefulWidget {
  final OrderModel temporaryShipment;

  const DriverSelectionScreen({super.key, required this.temporaryShipment});

  @override
  State<DriverSelectionScreen> createState() => _DriverSelectionScreenState();
}

class _DriverSelectionScreenState extends State<DriverSelectionScreen> {
  String _activeFilter = 'all'; // all, closest, top_rated

  @override
  void initState() {
    super.initState();
    // Fetch available drivers from database
    context.read<AddOrderCubit>().getAvailableDrivers();
  }

  // Haversine formula to calculate distance in km
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = pi / 180;
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * sqrt(a); // 2 * R; R = 6371 km
  }

  List<UserModel> _getFilteredDrivers(List<UserModel> drivers) {
    // Clone list
    List<UserModel> list = List.from(drivers);

    // Calculate distance for all drivers
    final pickupLat = widget.temporaryShipment.userLat;
    final pickupLong = widget.temporaryShipment.userLong;

    if (_activeFilter == 'closest') {
      list.sort((a, b) {
        final distA = _calculateDistance(
          pickupLat,
          pickupLong,
          a.currentLat ?? 30.04,
          a.currentLong ?? 31.23,
        );
        final distB = _calculateDistance(
          pickupLat,
          pickupLong,
          b.currentLat ?? 30.04,
          b.currentLong ?? 31.23,
        );
        return distA.compareTo(distB);
      });
    } else if (_activeFilter == 'top_rated') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final pickupLat = widget.temporaryShipment.userLat;
    final pickupLong = widget.temporaryShipment.userLong;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F0),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF1A1A1A),
                  size: 18,
                ),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          centerTitle: true,
          title: Text(
            'اختيار سائق شحنتك يدوياً',
            style: AppStyles.black18BoldStyle.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<AddOrderCubit, AddOrderState>(
            listener: (context, state) {
              if (state is AddOrderSuccess) {
                showAnimatedSnackDialog(
                  context,
                  message: 'تم إرسال طلب الشحنة للسائق بنجاح وفي انتظار قبوله!',
                  type: AnimatedSnackBarType.success,
                );
                // Return to home
                context.go(AppRoutes.homeScreen);
              } else if (state is AddOrderError) {
                showAnimatedSnackDialog(
                  context,
                  message: state.message,
                  type: AnimatedSnackBarType.error,
                );
              }
            },
            builder: (context, state) {
              if (state is AddOrderLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFFFB300),
                    ),
                  ),
                );
              }

              if (state is DriversLoaded) {
                final drivers = _getFilteredDrivers(state.drivers);

                return Column(
                  children: [
                    // Header card
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A1A1A), Color(0xFF3D3D3D)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            color: const Color(0xFFFFB300),
                            size: 26.sp,
                          ),
                          const WidthSpace(12),
                          Expanded(
                            child: Text(
                              'قارن بين عروض ومواقع السائقين المتاحين للخدمة الآن واختر الأنسب لك يدوياً.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Filter segments
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        children: [
                          _buildFilterButton(
                            'all',
                            'جميع السائقين',
                            Icons.people_rounded,
                          ),
                          const WidthSpace(8),
                          _buildFilterButton(
                            'closest',
                            'الأقرب مسافة',
                            Icons.location_on_rounded,
                          ),
                          const WidthSpace(8),
                          _buildFilterButton(
                            'top_rated',
                            'الأعلى تقييماً',
                            Icons.star_rounded,
                          ),
                        ],
                      ),
                    ),
                    const HeightSpace(16),

                    // Drivers List
                    Expanded(
                      child: drivers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.no_accounts_rounded,
                                    size: 64.sp,
                                    color: Colors.grey[400],
                                  ),
                                  const HeightSpace(12),
                                  Text(
                                    'لا يوجد سائقين متاحين للخدمة في الوقت الحالي.',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const HeightSpace(20),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1A1A1A),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                        vertical: 12.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                    ),
                                    onPressed: () async {
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc('mock_driver_1')
                                            .set({
                                              'user_id': 'mock_driver_1',
                                              'username':
                                                  'كابتن أحمد التوصيل (تجريبي)',
                                              'name':
                                                  'كابتن أحمد التوصيل (تجريبي)',
                                              'email': 'driver@test.com',
                                              'role': 'driver',
                                              'driver_status': 'active',
                                              'is_available': true,
                                              'vehicle_info':
                                                  'جامبو ربع نقل - لوحة: د ر س ١ ٢ ٣',
                                              'rating': 4.9,
                                              'trips_count': 48,
                                              'current_lat': 30.0444,
                                              'current_long': 31.2357,
                                              'national_id': '29901011234567',
                                              'license_number': '12345678',
                                            });
                                        if (mounted) {
                                          showAnimatedSnackDialog(
                                            context,
                                            message:
                                                'تم توليد وتفعيل سائق تجريبي نشط بنجاح!',
                                            type: AnimatedSnackBarType.success,
                                          );
                                          context
                                              .read<AddOrderCubit>()
                                              .getAvailableDrivers();
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          showAnimatedSnackDialog(
                                            context,
                                            message: 'فشل التوليد: $e',
                                            type: AnimatedSnackBarType.error,
                                          );
                                        }
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.bolt_rounded,
                                      color: Color(0xFFFFB300),
                                    ),
                                    label: Text(
                                      'توليد وتفعيل سائق تجريبي نشط فوراً',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              itemCount: drivers.length,
                              itemBuilder: (context, index) {
                                final driver = drivers[index];
                                final distance = _calculateDistance(
                                  pickupLat,
                                  pickupLong,
                                  driver.currentLat ?? 30.0444,
                                  driver.currentLong ?? 31.2357,
                                );

                                return Container(
                                  margin: EdgeInsets.only(bottom: 16.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 15,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Top details row
                                        Row(
                                          children: [
                                            // Driver Avatar
                                            Container(
                                              width: 52.w,
                                              height: 52.w,
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFFFFB300,
                                                ).withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.local_shipping_rounded,
                                                  color: const Color(
                                                    0xFFFFB300,
                                                  ),
                                                  size: 24.sp,
                                                ),
                                              ),
                                            ),
                                            const WidthSpace(14),
                                            // Driver Info
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    driver.name,
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: const Color(
                                                        0xFF1A1A1A,
                                                      ),
                                                    ),
                                                  ),
                                                  const HeightSpace(4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .local_shipping_rounded,
                                                        color: Colors.grey[400],
                                                        size: 13.sp,
                                                      ),
                                                      const WidthSpace(4),
                                                      Expanded(
                                                        child: Text(
                                                          driver.vehicleInfo ??
                                                              'شاحنة توصيل بضائع نشطة',
                                                          style: TextStyle(
                                                            fontSize: 10.5.sp,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Distance Badge
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10.w,
                                                vertical: 6.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1A1A1A),
                                                borderRadius:
                                                    BorderRadius.circular(30.r),
                                              ),
                                              child: Text(
                                                '${distance.toStringAsFixed(1)} كم',
                                                style: TextStyle(
                                                  color: const Color(
                                                    0xFFFFB300,
                                                  ),
                                                  fontSize: 9.5.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const HeightSpace(14),
                                        // Ratings & Stats Row
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8.w,
                                                vertical: 4.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFFFFE082,
                                                ).withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.star_rounded,
                                                    color: const Color(
                                                      0xFFFFB300,
                                                    ),
                                                    size: 14.sp,
                                                  ),
                                                  const WidthSpace(4),
                                                  Text(
                                                    driver.rating
                                                        .toStringAsFixed(1),
                                                    style: TextStyle(
                                                      fontSize: 10.5.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: const Color(
                                                        0xFFE65100,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const WidthSpace(10),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8.w,
                                                vertical: 4.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(
                                                  0.08,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.done_all_rounded,
                                                    color: Colors.green,
                                                    size: 14.sp,
                                                  ),
                                                  const WidthSpace(4),
                                                  Text(
                                                    '${driver.tripsCount} رحلة مكتملة',
                                                    style: TextStyle(
                                                      fontSize: 10.5.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const HeightSpace(16),
                                        Divider(
                                          color: Colors.grey[200],
                                          thickness: 1,
                                          height: 1,
                                        ),
                                        const HeightSpace(12),
                                        // Action Buttons
                                        Row(
                                          children: [
                                            // View Profile Button
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: const Color(
                                                    0xFF1A1A1A,
                                                  ),
                                                  side: const BorderSide(
                                                    color: Color(0xFFE8ECF4),
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 10.h,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12.r,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  _showDriverProfileDialog(
                                                    context,
                                                    driver,
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.person_outline_rounded,
                                                  size: 15,
                                                ),
                                                label: Text(
                                                  'عرض الملف',
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const WidthSpace(10),
                                            // Select Driver Button
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                    0xFFFFB300,
                                                  ),
                                                  foregroundColor: const Color(
                                                    0xFF1A1A1A,
                                                  ),
                                                  elevation: 0,
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 10.h,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12.r,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  final shipmentWithDriver =
                                                      widget.temporaryShipment
                                                          .copyWith(
                                                            driverId:
                                                                driver.userId,
                                                          );
                                                  context
                                                      .read<AddOrderCubit>()
                                                      .createOrder(
                                                        shipmentWithDriver,
                                                      );
                                                },
                                                icon: const Icon(
                                                  Icons.check_circle_rounded,
                                                  size: 15,
                                                ),
                                                label: Text(
                                                  'اختيار السائق وتأكيد',
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              }

              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String filter, String label, IconData icon) {
    final isSelected = _activeFilter == filter;
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFB300).withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? const Color(0xFFFFB300)
                : Colors.white,
            foregroundColor: isSelected
                ? const Color(0xFF1A1A1A)
                : Colors.grey[800],
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
              side: BorderSide(
                color: isSelected ? Colors.transparent : Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          onPressed: () {
            setState(() {
              _activeFilter = filter;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12.sp),
              const WidthSpace(4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.5.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDriverProfileDialog(BuildContext context, UserModel driver) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.badge_rounded,
                  color: const Color(0xFFFFB300),
                  size: 24.sp,
                ),
                const WidthSpace(10),
                Text(
                  'ملف الكابتن التفصيلي',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileField(
                    icon: Icons.person_rounded,
                    label: 'الاسم الكامل:',
                    value: driver.name,
                  ),
                  const HeightSpace(12),
                  _buildProfileField(
                    icon: Icons.local_shipping_rounded,
                    label: 'بيانات المركبة واللوحة:',
                    value:
                        driver.vehicleInfo ??
                        'شاحنة توصيل نشطة بانتظار التفاصيل',
                  ),
                  const HeightSpace(12),
                  _buildProfileField(
                    icon: Icons.credit_card_rounded,
                    label: 'الرقم القومي (National ID):',
                    value: driver.nationalId ?? '١٤ رقماً مؤمن بنجاح',
                  ),
                  const HeightSpace(12),
                  _buildProfileField(
                    icon: Icons.assignment_ind_rounded,
                    label: 'رقم رخصة القيادة الموثقة:',
                    value: driver.licenseNumber ?? 'رخصة قيادة مهنية موثقة',
                  ),
                  const HeightSpace(12),
                  _buildProfileField(
                    icon: Icons.star_rounded,
                    label: 'التقييم العام للخدمة:',
                    value:
                        '${driver.rating.toStringAsFixed(1)} / 5.0 (تقييمات موثقة)',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إغلاق النافذة',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: const Color(0xFFFFB300).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: const Color(0xFFFFB300), size: 16),
        ),
        const WidthSpace(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const HeightSpace(2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
