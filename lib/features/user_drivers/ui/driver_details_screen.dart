import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/routing/app_routes.dart';
import 'package:live_order/core/models/user_profile.dart';
import 'package:live_order/features/user_drivers/ui/widget/driver_info_header.dart';
import 'package:live_order/features/user_drivers/ui/widget/driver_about_card.dart';
import 'package:live_order/features/user_drivers/ui/widget/driver_vehicle_details_card.dart';
import 'package:live_order/features/user_drivers/ui/widget/driver_reviews_section.dart';
import 'package:live_order/features/user_drivers/ui/widget/driver_safety_banner.dart';
import 'package:live_order/features/user_drivers/ui/widget/driver_action_dock.dart';
import 'package:live_order/features/user_drivers/ui/widget/driver_report_dialog.dart';
import 'package:live_order/features/user_drivers/ui/widget/section_title.dart';

class DriverDetailsScreen extends StatelessWidget {
  final UserProfile driver;

  const DriverDetailsScreen({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppDesign.textPrimary,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          'تفاصيل الكابتن',
          style: AppDesign.heading(fontSize: 17.0),
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DriverInfoHeader(driver: driver),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDesign.space16,
                      vertical: AppDesign.space16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionTitle(
                          title: 'نبذة عن الكابتن',
                          icon: Icons.info_outline_rounded,
                        ),
                        const SizedBox(height: AppDesign.space8),
                        DriverAboutCard(about: driver.about),

                        const SizedBox(height: AppDesign.space24),

                        SectionTitle(
                          title: 'بيانات المركبة',
                          icon: Icons.local_shipping_outlined,
                        ),
                        const SizedBox(height: AppDesign.space8),
                        DriverVehicleDetailsCard(
                          vehicleType: driver.vehicleType,
                          vehicleCapacity: driver.vehicleCapacity,
                          vehiclePlate: driver.vehiclePlate,
                        ),

                        const SizedBox(height: AppDesign.space24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SectionTitle(
                              title: 'تقييمات العملاء (${driver.reviews.length})',
                              icon: Icons.star_outline_rounded,
                            ),
                            if (driver.reviews.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    driver.rating.toStringAsFixed(1),
                                    style: AppDesign.body(
                                      color: AppDesign.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: AppDesign.space8),
                        DriverReviewsSection(reviews: driver.reviews),

                        const SizedBox(height: AppDesign.space24),

                        DriverSafetyBanner(
                          onReportTap: () => showDriverReportDialog(context, driver),
                        ),

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            DriverActionDock(
              onChatTap: () {
                Navigator.pushNamed(context, AppRoutes.marketChat, arguments: driver);
              },
            ),
          ],
        ),
      ),
    );
  }
}
