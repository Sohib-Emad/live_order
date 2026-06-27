import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_order/features/user_chat/logic/cubit.dart';
import 'package:live_order/features/user_chat/logic/state.dart';
import 'package:live_order/features/user_chat/data/repository/chat_repository.dart';
import 'package:live_order/features/user_chat/data/model/chat_message.dart';

class MockMarketChatRepository implements MarketChatRepository {
  final _messagesCtrl = StreamController<List<ChatMessage>>.broadcast();
  bool? _hasActiveOrder;
  bool _hasActiveOrderThrows = false;
  String? _userId;

  void setUserId(String? id) => _userId = id;
  void setHasActiveOrder(bool value) => _hasActiveOrder = value;
  void throwOnHasActiveOrder() => _hasActiveOrderThrows = true;
  void emitMessages(List<ChatMessage> messages) => _messagesCtrl.add(messages);

  @override
  String? getCurrentUserId() => _userId;

  @override
  Future<bool> hasActiveAcceptedOrder(String myUid, String driverId) async {
    if (_hasActiveOrderThrows) throw Exception('Test error');
    return _hasActiveOrder ?? false;
  }

  @override
  Stream<List<ChatMessage>> streamMessages(String chatId) =>
      _messagesCtrl.stream;

  @override
  Future<void> sendMessage(String chatId, ChatMessage message) async {}

  void dispose() {
    _messagesCtrl.close();
  }
}

void main() {
  group('MarketChatCubit', () {
    late MockMarketChatRepository repository;
    late MarketChatCubit cubit;

    setUp(() {
      repository = MockMarketChatRepository();
      repository.setUserId('client_1');
      cubit = MarketChatCubit(repository);
    });

    tearDown(() {
      cubit.close();
      repository.dispose();
    });

    test('initial state is MarketChatInitial', () {
      expect(cubit.state, isA<MarketChatInitial>());
    });

    group('loadMessages', () {
      test('emits MarketChatLoading then MarketChatRestricted when no active order', () async {
        repository.setHasActiveOrder(false);

        final states = <MarketChatState>[];
        final sub = cubit.stream.listen(states.add);

        cubit.loadMessages('driver_1');
        await Future<void>.delayed(Duration.zero);

        expect(states.length, 2);
        expect(states[0], isA<MarketChatLoading>());
        expect(states[1], isA<MarketChatRestricted>());
        await sub.cancel();
      });

      test('emits MarketChatLoading then MarketChatLoaded with stream messages', () async {
        repository.setHasActiveOrder(true);

        final states = <MarketChatState>[];
        final sub = cubit.stream.listen(states.add);

        cubit.loadMessages('driver_1');
        await Future<void>.delayed(Duration.zero);
        expect(states.length, 1);
        expect(states[0], isA<MarketChatLoading>());

        repository.emitMessages([
          ChatMessage(
            id: 'm1',
            senderId: 'client_1',
            text: 'Hello',
            timestamp: DateTime.now(),
          ),
        ]);
        await Future<void>.delayed(Duration.zero);

        expect(states.length, 2);
        expect(states[1], isA<MarketChatLoaded>());
        expect((states[1] as MarketChatLoaded).messages.length, 1);
        await sub.cancel();
      });

      test('emits MarketChatError on stream error', () async {
        repository.setHasActiveOrder(true);

        final states = <MarketChatState>[];
        final sub = cubit.stream.listen(states.add);

        cubit.loadMessages('driver_1');
        await Future<void>.delayed(Duration.zero);
        expect(states.length, 1);
        expect(states[0], isA<MarketChatLoading>());

        repository._messagesCtrl.addError('Stream failure');
        await Future<void>.delayed(Duration.zero);

        expect(states.length, 2);
        expect(states[1], isA<MarketChatError>());
        await sub.cancel();
      });

      test('emits MarketChatError when user is not logged in', () async {
        final repo = MockMarketChatRepository();
        repo.setUserId(null);
        final localCubit = MarketChatCubit(repo);

        final states = <MarketChatState>[];
        final sub = localCubit.stream.listen(states.add);

        localCubit.loadMessages('driver_1');
        await Future<void>.delayed(Duration.zero);

        expect(states.length, 1);
        expect(states[0], isA<MarketChatError>());

        await sub.cancel();
        localCubit.close();
        repo.dispose();
      });

      test('emits MarketChatError on exception in hasActiveAcceptedOrder', () async {
        repository.throwOnHasActiveOrder();

        final states = <MarketChatState>[];
        final sub = cubit.stream.listen(states.add);

        cubit.loadMessages('driver_1');
        await Future<void>.delayed(Duration.zero);

        expect(states.length, 2);
        expect(states[0], isA<MarketChatLoading>());
        expect(states[1], isA<MarketChatError>());
        await sub.cancel();
      });
    });
  });
}
