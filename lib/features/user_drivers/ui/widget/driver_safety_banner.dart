import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

class DriverSafetyBanner extends StatelessWidget {
  final VoidCallback onReportTap;

  const DriverSafetyBanner({super.key, required this.onReportTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesign.space12,
        vertical: AppDesign.space8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(AppDesign.radius8),
        border: Border.all(
          color: const Color(0xFFFEE2E2),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: AppDesign.danger,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تواجه مشكلة مع الكابتن؟ يمكنك إبلاغ الإدارة للمراجعة الفورية.',
                    style: AppDesign.body(
                      color: const Color(0xFF991B1B),
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onReportTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'إبلاغ',
              style: AppDesign.body(
                color: AppDesign.danger,
                fontWeight: FontWeight.bold,
                fontSize: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
