import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

class DriverVehicleDetailsCard extends StatelessWidget {
  final String? vehicleType;
  final String? vehicleCapacity;
  final String? vehiclePlate;

  const DriverVehicleDetailsCard({
    super.key,
    required this.vehicleType,
    required this.vehicleCapacity,
    required this.vehiclePlate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDesign.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          _buildVehicleInfoRow(
            Icons.local_shipping_outlined,
            'طراز المركبة',
            vehicleType ?? 'سيارة نقل بضائع',
          ),
          const Divider(color: Color(0xFFF3F4F6), height: 20),
          _buildVehicleInfoRow(
            Icons.speed_outlined,
            'الحمولة والقدرة الاستيعابية',
            vehicleCapacity ?? 'نقل متوسط (حتى 1.5 طن)',
          ),
          const Divider(color: Color(0xFFF3F4F6), height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.badge_outlined,
                    color: AppDesign.textSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'رقم اللوحة المعدنية',
                    style: AppDesign.body(
                      color: AppDesign.textSecondary,
                      fontSize: 13.0,
                    ),
                  ),
                ],
              ),
              _buildEgyptianLicensePlate(vehiclePlate ?? 'أ ب ج ١ ٢ ٣'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppDesign.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppDesign.body(
                color: AppDesign.textSecondary,
                fontSize: 13.0,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: AppDesign.body(
            color: AppDesign.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13.0,
          ),
        ),
      ],
    );
  }

  Widget _buildEgyptianLicensePlate(String plate) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF9CA3AF), width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: const BoxDecoration(
              color: Color(0xFF1D4ED8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: const Text(
              'مصر   EGYPT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              plate,
              style: AppDesign.heading(
                fontSize: 13.0,
                color: AppDesign.textPrimary,
              ).copyWith(letterSpacing: 2),
            ),
          ),
        ],
      ),
    );
  }
}
