import 'package:live_order/core/services/supabase_service.dart';

class UserApi {
  final supabase = SupabaseService.instance.client;

  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      final data =
          await supabase.from('users').select().eq('uid', userId).single()
              as Map<String, dynamic>?;
      return data ?? {};
    } catch (e) {
      throw Exception('خطأ في جلب بيانات المستخدم: $e');
    }
  }

  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await supabase.from('users').update(data).eq('uid', userId);
    } catch (e) {
      throw Exception('خطأ في تحديث البيانات: $e');
    }
  }

  Future<void> updateProfileImage(String userId, String imageUrl) async {
    try {
      await supabase
          .from('users')
          .update({'profile_image': imageUrl})
          .eq('uid', userId);
    } catch (e) {
      throw Exception('خطأ في تحديث الصورة الشخصية: $e');
    }
  }

  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final completedOrders = await supabase
          .from('orders')
          .select()
          .eq('client_id', userId)
          .eq('order_status', 'Delivered');

      final allOrders = await supabase
          .from('orders')
          .select()
          .eq('client_id', userId);

      double totalSpent = 0;
      for (var doc in allOrders) {
        totalSpent += (doc['total_price'] as num?)?.toDouble() ?? 0;
      }

      return {
        'completed_orders': completedOrders.length,
        'total_spent': totalSpent,
        'active_orders': allOrders.length - completedOrders.length,
      };
    } catch (e) {
      throw Exception('خطأ في جلب الإحصائيات: $e');
    }
  }

  Future<void> updateContactInfo(
    String userId,
    String phone,
    String address,
  ) async {
    try {
      await supabase
          .from('users')
          .update({
            'phone': phone,
            'address': address,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('uid', userId);
    } catch (e) {
      throw Exception('خطأ في تحديث بيانات الاتصال: $e');
    }
  }

  Future<void> deleteAccount(String userId) async {
    try {
      await supabase
          .from('users')
          .update({
            'is_deleted': true,
            'deleted_at': DateTime.now().toIso8601String(),
          })
          .eq('uid', userId);
    } catch (e) {
      throw Exception('خطأ في حذف الحساب: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserActivity(String userId) async {
    try {
      final data = await supabase
          .from('user_activity')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false)
          .limit(50);

      return data;
    } catch (e) {
      throw Exception('خطأ في جلب سجل النشاط: $e');
    }
  }

  Future<void> updateNotificationSettings(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    try {
      await supabase
          .from('users')
          .update({'notification_settings': settings})
          .eq('uid', userId);
    } catch (e) {
      throw Exception('خطأ في تحديث إعدادات الإشعارات: $e');
    }
  }
}
