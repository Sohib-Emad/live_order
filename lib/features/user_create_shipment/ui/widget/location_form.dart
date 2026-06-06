import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/core/widgets/app_text_field.dart';

class LocationForm extends StatelessWidget {
  final TextEditingController pickupController;
  final TextEditingController dropoffController;
  final VoidCallback? onPickupTap;
  final VoidCallback? onDropoffTap;

  const LocationForm({
    super.key,
    required this.pickupController,
    required this.dropoffController,
    this.onPickupTap,
    this.onDropoffTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDesign.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: AppDesign.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مواقع استلام وتسليم الشحنة',
            style: AppDesign.heading(fontSize: 16.0),
          ),
          const SizedBox(height: AppDesign.space20),
          AppTextField(
            label: 'عنوان موقع الاستلام (البيك آب)',
            hint: 'اختر موقع الاستلام على الخريطة',
            controller: pickupController,
            prefixIcon: const Icon(
              Icons.location_on_rounded,
              color: AppDesign.success,
            ),
            suffixIcon: const Icon(
              Icons.map_rounded,
              color: AppDesign.primary,
            ),
            readOnly: true,
            onTap: onPickupTap,
          ),
          const SizedBox(height: AppDesign.space20),
          AppTextField(
            label: 'عنوان موقع التسليم (الدروب أوف)',
            hint: 'اختر موقع التسليم على الخريطة',
            controller: dropoffController,
            prefixIcon: const Icon(
              Icons.location_on_rounded,
              color: AppDesign.danger,
            ),
            suffixIcon: const Icon(
              Icons.map_rounded,
              color: AppDesign.primary,
            ),
            readOnly: true,
            onTap: onDropoffTap,
          ),
        ],
      ),
    );
  }
}
