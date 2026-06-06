import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/widgets/spacing_widgets.dart';
import 'package:live_order/features/add_order/models/order_model.dart';
import 'package:live_order/features/driver/ui/widgets/shipment_card.dart';

class DriverOffersTab extends StatelessWidget {
  final List<OrderModel> offers;

  const DriverOffersTab({
    super.key,
    required this.offers,
  });

  static const _dark = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
          child: Text(
            'طلبات الشحن والعروض الجديدة',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: _dark,
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
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const HeightSpace(6),
                        Text(
                          'عند قيام العملاء بحجز مركبتك، ستظهر طلباتهم وعروضهم فوراً هنا لقبولها.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[400],
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
