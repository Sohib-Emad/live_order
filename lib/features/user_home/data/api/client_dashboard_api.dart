// lib/features/user_home/data/api/client_dashboard_api.dart

import 'package:live_order/core/services/supabase_service.dart';

class ClientDashboardApi {
  final supabase = SupabaseService.instance.client;

  Future<List<Map<String, dynamic>>> getActiveShipments() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return [];
    final data = await supabase
        .from('orders')
        .select()
        .eq('order_user_id', uid);
    return data
        .where(
          (row) =>
              row['order_status'] == 'Waiting Driver' ||
              row['order_status'] == 'Accepted' ||
              row['order_status'] == 'In Transit',
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> getTopDrivers() async {
    final data = await supabase
        .from('users')
        .select()
        .eq('role', 'driver')
        .limit(20);
    return data;
  }

  Future<List<Map<String, dynamic>>> getRecentOrders() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return [];
    final data = await supabase
        .from('orders')
        .select()
        .eq('order_user_id', uid)
        .order('order_date', ascending: false)
        .limit(10);
    return data;
  }
}
