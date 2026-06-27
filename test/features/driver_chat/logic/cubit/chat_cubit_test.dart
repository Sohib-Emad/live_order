import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:live_order/features/driver_chat/logic/cubit/chat_cubit.dart';
import 'package:live_order/features/driver_chat/data/repo/chat_repo.dart';

class MockChatRepo implements ChatRepo {
  Either<String, String>? _senderNameResult;
  Either<String, void>? _sendMessageResult;

  void setSenderNameSuccess(String name) => _senderNameResult = Right(name);
  void setSenderNameError(String error) => _senderNameResult = Left(error);
  void setSendMessageSuccess() => _sendMessageResult = const Right(null);
  void setSendMessageError(String error) => _sendMessageResult = Left(error);

  @override
  Future<Either<String, String>> getSenderName(String userId) async {
    return _senderNameResult ?? const Right('Test User');
  }

  @override
  Future<Either<String, void>> sendMessage(
    String chatId, {
    required String text,
    required String senderId,
    required String senderName,
  }) async {
    return _sendMessageResult ?? const Right(null);
  }

  @override
  Stream<List<Map<String, dynamic>>> streamMessages(String chatId) =>
      const Stream.empty();

  @override
  Stream<List<Map<String, dynamic>>> streamClientData(String clientId) =>
      const Stream.empty();

  @override
  Future<Either<String, void>> markMessageAsRead(
      String chatId, String messageId) async {
    return const Right(null);
  }
}

void main() {
  group('ChatCubit', () {
    late MockChatRepo mockRepo;
    late ChatCubit cubit;

    setUp(() {
      mockRepo = MockChatRepo();
      cubit = ChatCubit(chatRepo: mockRepo);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is ChatInitial', () {
      expect(cubit.state, isA<ChatInitial>());
    });

    group('sendMessage', () {
      test('emits ChatLoading then ChatSuccess on success', () async {
        mockRepo.setSenderNameSuccess('Driver Name');
        mockRepo.setSendMessageSuccess();

        final states = <ChatState>[];
        final sub = cubit.stream.listen(states.add);

        cubit.sendMessage('chat_1', text: 'Hello', senderId: 'driver_1');
        await Future<void>.delayed(Duration.zero);

        expect(states.length, 2);
        expect(states[0], isA<ChatLoading>());
        expect(states[1], isA<ChatSuccess>());
        await sub.cancel();
      });

      test('emits ChatLoading then ChatError when getSenderName fails',
          () async {
        mockRepo.setSenderNameError('User not found');

        final states = <ChatState>[];
        final sub = cubit.stream.listen(states.add);

        cubit.sendMessage('chat_1', text: 'Hello', senderId: 'unknown');
        await Future<void>.delayed(Duration.zero);

        expect(states.length, 2);
        expect(states[0], isA<ChatLoading>());
        expect(states[1], isA<ChatError>());
        expect((states[1] as ChatError).message, 'User not found');
        await sub.cancel();
      });

      test('emits ChatLoading then ChatError when sendMessage fails', () async {
        mockRepo.setSenderNameSuccess('Driver Name');
        mockRepo.setSendMessageError('Network error');

        final states = <ChatState>[];
        final sub = cubit.stream.listen(states.add);

        cubit.sendMessage('chat_1', text: 'Hello', senderId: 'driver_1');
        await Future<void>.delayed(Duration.zero);

        expect(states.length, 2);
        expect(states[0], isA<ChatLoading>());
        expect(states[1], isA<ChatError>());
        expect((states[1] as ChatError).message, 'Network error');
        await sub.cancel();
      });
    });
  });
}
