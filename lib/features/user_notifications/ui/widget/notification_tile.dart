import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/features/user_notifications/data/model/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  Color getIconColor() {
    switch (notification.category) {
      case 'promo':
        return AppDesign.success;
      case 'payment':
        return AppDesign.primary;
      case 'system':
        return AppDesign.danger;
      default:
        return AppDesign.warning;
    }
  }

  IconData getIcon() {
    switch (notification.category) {
      case 'promo':
        return Icons.percent_rounded;
      case 'payment':
        return Icons.account_balance_wallet_rounded;
      case 'system':
        return Icons.info_outline_rounded;
      default:
        return Icons.local_shipping_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDesign.space8),
        padding: const EdgeInsets.all(AppDesign.space16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDesign.radius12),
          border: Border.all(
            color: notification.isRead ? AppDesign.border : AppDesign.primary.withOpacity(0.12),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDesign.space8),
              decoration: BoxDecoration(
                color: getIconColor().withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(getIcon(), color: getIconColor(), size: 18),
            ),
            const SizedBox(width: AppDesign.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppDesign.body(
                            color: AppDesign.textPrimary,
                            fontWeight: notification.isRead ? FontWeight.bold : FontWeight.w800,
                            fontSize: 13.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppDesign.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDesign.space4),
                  Text(
                    notification.body,
                    style: AppDesign.body(
                      color: notification.isRead ? AppDesign.textSecondary : AppDesign.textPrimary.withOpacity(0.8),
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
