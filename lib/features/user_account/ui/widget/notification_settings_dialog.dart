import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/features/user_account/logic/cubit/user_cubit.dart';

class NotificationSettingsDialog extends StatefulWidget {
  final UserCubit userCubit;
  final String userId;

  const NotificationSettingsDialog({
    super.key,
    required this.userCubit,
    required this.userId,
  });

  @override
  State<NotificationSettingsDialog> createState() => _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState extends State<NotificationSettingsDialog> {
  bool _orderNotifications = true;
  bool _chatNotifications = true;
  bool _promoNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'إعدادات الإشعارات',
          style: AppDesign.heading(fontSize: 16.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationToggle(
              'إشعارات حركة الطلبات',
              _orderNotifications,
              (v) => setState(() => _orderNotifications = v),
            ),
            const Divider(color: AppDesign.border, height: 16),
            _buildNotificationToggle(
              'إشعارات الرسائل والدردشة',
              _chatNotifications,
              (v) => setState(() => _chatNotifications = v),
            ),
            const Divider(color: AppDesign.border, height: 16),
            _buildNotificationToggle(
              'إشعارات العروض الحصرية والتنبيهات',
              _promoNotifications,
              (v) => setState(() => _promoNotifications = v),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppDesign.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 10.h,
              ),
              elevation: 0,
            ),
            onPressed: () {
              widget.userCubit.updateNotificationSettings(
                widget.userId,
                {
                  'order_notifications': _orderNotifications,
                  'chat_notifications': _chatNotifications,
                  'promo_notifications': _promoNotifications,
                },
              );
              Navigator.pop(context);
            },
            child: Text(
              'تم وحفظ',
              style: AppDesign.body(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppDesign.body(
              color: AppDesign.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 13.0,
            ),
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppDesign.primary,
          activeTrackColor: AppDesign.primary.withValues(alpha: 0.3),
        ),
      ],
    );
  }
}
