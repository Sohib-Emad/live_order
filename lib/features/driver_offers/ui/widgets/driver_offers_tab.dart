import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/core/models/shipment.dart';
import 'package:live_order/features/driver_home/ui/widgets/shipment_card.dart';
import 'package:live_order/core/constants/app_design.dart';

class DriverOffersTab extends StatelessWidget {
  final List<Shipment> offers;

  const DriverOffersTab({
    super.key,
    required this.offers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
          child: Text(
            'طلبات الشحن والعروض الجديدة',
            style: AppDesign.heading(
              fontSize: 20.sp,
              color: AppDesign.textPrimary,
            ),
          ),
        ),
        const HeightSpace(16),
        Expanded(
          child: offers.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          size: 56.sp,
                          color: Colors.grey[300],
                        ),
                        const HeightSpace(12),
                        Text(
                          'لا توجد عروض جديدة حالياً.',
                          style: AppDesign.heading(
                            fontSize: 13.sp,
                            color: AppDesign.textPrimary,
                          ),
                        ),
                        const HeightSpace(6),
                        Text(
                          'عند قيام العملاء بحجز مركبتك، ستظهر طلباتهم وعروضهم فوراً هنا لقبولها.',
                          textAlign: TextAlign.center,
                          style: AppDesign.body(
                            fontSize: 11.sp,
                            color: AppDesign.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    return ShipmentCard(order: offers[index]);
                  },
                ),
        ),
      ],
    );
  }
}
