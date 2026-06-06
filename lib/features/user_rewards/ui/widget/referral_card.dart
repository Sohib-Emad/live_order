import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

class ReferralCard extends StatelessWidget {
  final String referralCode;
  final VoidCallback onCopy;

  const ReferralCard({
    super.key,
    required this.referralCode,
    required this.onCopy,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppDesign.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.share_rounded, color: AppDesign.primary, size: 20),
              ),
              const SizedBox(width: AppDesign.space12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invite Friends, Earn Points',
                    style: AppDesign.body(color: AppDesign.textPrimary, fontWeight: FontWeight.bold, fontSize: 14.0),
                  ),
                  Text(
                    'Get 150 points for each signup.',
                    style: AppDesign.body(color: AppDesign.textSecondary, fontSize: 11.5),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDesign.space16),
          Container(
            padding: const EdgeInsets.all(AppDesign.space12),
            decoration: BoxDecoration(
              color: AppDesign.surface,
              borderRadius: BorderRadius.circular(AppDesign.radius8),
              border: Border.all(color: AppDesign.border, width: 1.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  referralCode,
                  style: AppDesign.heading(color: AppDesign.textPrimary, fontSize: 15.0),
                ),
                GestureDetector(
                  onTap: onCopy,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppDesign.space16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppDesign.primary,
                      borderRadius: BorderRadius.circular(AppDesign.radius8),
                    ),
                    child: Text(
                      'Copy Code',
                      style: AppDesign.body(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
