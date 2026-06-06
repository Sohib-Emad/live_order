import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

class DriverAboutCard extends StatelessWidget {
  final String about;

  const DriverAboutCard({super.key, required this.about});

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
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Icon(
              Icons.format_quote_rounded,
              color: AppDesign.textSecondary.withOpacity(0.08),
              size: 32,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              about.isNotEmpty
                  ? about
                  : 'سائق محترف ومعتمد. ملتزم بنقل وتوصيل البضائع والطرود بكل أمان وسرعة وبأعلى معايير الجودة لرضا العملاء.',
              style: AppDesign.body(
                color: AppDesign.textPrimary,
                fontSize: 13.0,
              ).copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
