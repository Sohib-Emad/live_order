import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:live_order/core/utils/logger.dart';

class SupabaseService {
  static SupabaseService? _instance;
  late final SupabaseClient _client;

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  SupabaseClient get client => _client;

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
    _instance = SupabaseService._();
    _instance!._client = Supabase.instance.client;
    AppLogger.info('SupabaseService', 'Initialized successfully');
  }

  static Future<void> initializeWithClient(SupabaseClient client) async {
    _instance = SupabaseService._();
    _instance!._client = client;
  }

  Stream<List<Map<String, dynamic>>> streamQuery(
    String table, {
    String? eqField,
    dynamic eqValue,
    List<String>? primaryKey,
  }) {
    final stream = client.from(table).stream(primaryKey: primaryKey ?? ['id']);
    if (eqField != null && eqValue != null) {
      return stream
          .map((list) => list.where((row) => row[eqField] == eqValue).toList());
    }
    return stream;
  }}
