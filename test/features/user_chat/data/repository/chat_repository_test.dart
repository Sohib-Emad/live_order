import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_order/features/user_chat/data/repository/chat_repository.dart';
import 'package:live_order/features/user_chat/data/api/chat_api.dart';
import 'package:live_order/features/user_chat/data/model/chat_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockMarketChatApi implements MarketChatApi {
  @override
  late final SupabaseClient supabase;

  final _messagesCtrl = StreamController<List<Map<String, dynamic>>>.broadcast();
  List<Map<String, dynamic>>? _ordersResult;
  bool _ordersThrows = false;
  String? _userId;

  void setOrdersResult(List<Map<String, dynamic>> orders) =>
      _ordersResult = orders;
  void throwOnOrders() => _ordersThrows = true;
  void setUserId(String? id) => _userId = id;
  void emitMessages(List<Map<String, dynamic>> data) =>
      _messagesCtrl.add(data);
  void addMessagesError(Object error) => _messagesCtrl.addError(error);

  @override
  Stream<List<Map<String, dynamic>>> streamMessages(String chatId) =>
      _messagesCtrl.stream;

  @override
  Future<void> sendMessage(
      String chatId, Map<String, dynamic> messageData) async {}

  @override
  Future<List<Map<String, dynamic>>> getOrdersByUserAndDriver(
      String userId, String driverId) async {
    if (_ordersThrows) throw Exception('DB error');
    return _ordersResult ?? [];
  }

  @override
  String? getCurrentUserId() => _userId;

  void dispose() {
    _messagesCtrl.close();
  }
}

void main() {
  group('MarketChatRepository', () {
    late MockMarketChatApi api;
    late MarketChatRepository repository;

    setUp(() {
      api = MockMarketChatApi();
      repository = MarketChatRepository(api);
    });

    tearDown(() {
      api.dispose();
    });

    group('streamMessages', () {
      test('maps raw data to ChatMessage objects', () async {
        final states = <List<ChatMessage>>[];
        final sub = repository.streamMessages('chat_1').listen(states.add);

        api.emitMessages([
          {
            'id': 'msg_1',
            'senderId': 'user_1',
            'text': 'Hello',
            'timestamp': '2026-06-27T10:00:00.000',
          },
        ]);
        await Future<void>.delayed(Duration.zero);

        expect(states.length, 1);
        expect(states[0].length, 1);
        expect(states[0][0].id, 'msg_1');
        expect(states[0][0].senderId, 'user_1');
        expect(states[0][0].text, 'Hello');
        await sub.cancel();
      });

      test('handles missing fields with defaults', () async {
        final states = <List<ChatMessage>>[];
        final sub = repository.streamMessages('chat_1').listen(states.add);

        api.emitMessages([
          {'id': 'msg_1'},
        ]);
        await Future<void>.delayed(Duration.zero);

        expect(states[0][0].id, 'msg_1');
        expect(states[0][0].senderId, '');
        expect(states[0][0].text, '');
        await sub.cancel();
      });

      test('adds attachment fields when present', () async {
        final states = <List<ChatMessage>>[];
        final sub = repository.streamMessages('chat_1').listen(states.add);

        api.emitMessages([
          {
            'id': 'msg_2',
            'senderId': 'user_1',
            'text': 'Check this',
            'timestamp': '2026-06-27T10:00:00.000',
            'attachmentType': 'image',
            'attachmentUrl': 'https://example.com/img.jpg',
            'latitude': 24.7,
            'longitude': 46.6,
          },
        ]);
        await Future<void>.delayed(Duration.zero);

        expect(states[0][0].attachmentType, 'image');
        expect(states[0][0].attachmentUrl, 'https://example.com/img.jpg');
        expect(states[0][0].latitude, 24.7);
        expect(states[0][0].longitude, 46.6);
        await sub.cancel();
      });
    });

    group('hasActiveAcceptedOrder', () {
      test('returns true when order status is Accepted', () async {
        api.setOrdersResult([
          {'order_status': 'Accepted'},
        ]);

        final result =
            await repository.hasActiveAcceptedOrder('user_1', 'driver_1');
        expect(result, isTrue);
      });

      test('returns true when order status is In Transit', () async {
        api.setOrdersResult([
          {'status': 'In Transit'},
        ]);

        final result =
            await repository.hasActiveAcceptedOrder('user_1', 'driver_1');
        expect(result, isTrue);
      });

      test('returns false when no matching orders', () async {
        api.setOrdersResult([]);

        final result =
            await repository.hasActiveAcceptedOrder('user_1', 'driver_1');
        expect(result, isFalse);
      });

      test('returns false when status is Pending', () async {
        api.setOrdersResult([
          {'order_status': 'Pending'},
        ]);

        final result =
            await repository.hasActiveAcceptedOrder('user_1', 'driver_1');
        expect(result, isFalse);
      });

    });

    group('getCurrentUserId', () {
      test('returns the current user id from the api', () {
        api.setUserId('user_1');
        expect(repository.getCurrentUserId(), 'user_1');
      });

      test('returns null when no user is logged in', () {
        api.setUserId(null);
        expect(repository.getCurrentUserId(), isNull);
      });
    });
  });
}
