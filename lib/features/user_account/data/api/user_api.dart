import 'package:cloud_firestore/cloud_firestore.dart';

class UserApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // الحصول على بيانات المستخدم
  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      throw Exception('خطأ في جلب بيانات المستخدم: $e');
    }
  }

  // تحديث بيانات المستخدم
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      throw Exception('خطأ في تحديث البيانات: $e');
    }
  }

  // تحديث الصورة الشخصية
  Future<void> updateProfileImage(String userId, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profile_image': imageUrl,
      });
    } catch (e) {
      throw Exception('خطأ في تحديث الصورة الشخصية: $e');
    }
  }

  // الحصول على إحصائيات المستخدم
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // جلب عدد الطلبات المكتملة
      QuerySnapshot completedOrders = await _firestore
          .collection('orders')
          .where('client_id', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .get();

      // جلب إجمالي المبلغ المنفق
      QuerySnapshot allOrders = await _firestore
          .collection('orders')
          .where('client_id', isEqualTo: userId)
          .get();

      double totalSpent = 0;
      for (var doc in allOrders.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalSpent += (data['total_price'] as num?)?.toDouble() ?? 0;
      }

      return {
        'completed_orders': completedOrders.size,
        'total_spent': totalSpent,
        'active_orders': allOrders.size - completedOrders.size,
      };
    } catch (e) {
      throw Exception('خطأ في جلب الإحصائيات: $e');
    }
  }

  // تحديث بيانات الاتصال
  Future<void> updateContactInfo(String userId, String phone, String address) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'phone': phone,
        'address': address,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('خطأ في تحديث بيانات الاتصال: $e');
    }
  }

  // حذف حساب المستخدم (soft delete)
  Future<void> deleteAccount(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'is_deleted': true,
        'deleted_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('خطأ في حذف الحساب: $e');
    }
  }

  // الحصول على تاريخ النشاط
  Future<List<Map<String, dynamic>>> getUserActivity(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('user_activity')
          .where('user_id', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('خطأ في جلب سجل النشاط: $e');
    }
  }

  // تحديث إعدادات الإشعارات
  Future<void> updateNotificationSettings(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'notification_settings': settings,
      });
    } catch (e) {
      throw Exception('خطأ في تحديث إعدادات الإشعارات: $e');
    }
  }
}
