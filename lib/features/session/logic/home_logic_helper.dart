import 'package:flutter/material.dart';

class HomeLogicHelper {
  // Return color based on order status
  static Color getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return const Color(0xFF4CAF50);
      case 'In Transit':
        return const Color(0xFFFFB300);
      case 'Accepted':
        return const Color(0xFF2196F3);
      case 'Cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  // Return Arabic label based on order status
  static String getStatusLabel(String status) {
    switch (status) {
      case 'Waiting Driver':
        return 'بانتظار السائق';
      case 'Accepted':
        return 'مقبول';
      case 'In Transit':
        return 'قيد التوصيل';
      case 'Delivered':
        return 'مكتمل';
      case 'Cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  // Get notification banner message based on state change
  static String getNotificationMessage(String orderName, String status) {
    switch (status) {
      case 'Accepted':
        return 'تم قبول طلب شحنتك "$orderName" من قبل الكابتن! وهو الآن يستعد للتحرك.';
      case 'In Transit':
        return 'الكابتن في طريقه لتوصيل شحنتك "$orderName" الآن! يمكنك متابعته على الخريطة.';
      case 'Delivered':
        return 'تم توصيل شحنتك "$orderName" بنجاح! شكراً لاستخدامك خدمتنا.';
      case 'Cancelled':
        return 'تم إلغاء شحنتك "$orderName".';
      default:
        return '';
    }
  }
}
