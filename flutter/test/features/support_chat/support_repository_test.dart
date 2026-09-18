import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/features/support_chat/data/support_repository.dart';
import 'package:codeschool_mobile/shared/models/support.dart';

class MockApiClient extends Mock implements ApiClient {}

/// Mock only [ApiClient] and check [SupportRepository] calls the exact
/// real routes in backend/internal/support/routes.go.
void main() {
  late MockApiClient client;
  late SupportRepository repo;

  setUp(() {
    client = MockApiClient();
    repo = SupportRepository(client);
  });

  test('listThreads hits GET /support/threads', () async {
    when(() => client.get<List<SupportThreadListItem>>('/support/threads', decode: any(named: 'decode'))).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as List<SupportThreadListItem> Function(dynamic);
      return ApiResult.ok(decode([
        {
          'id': 3,
          'subject': 'Вопрос по заданию',
          'category': 'assignment',
          'status': 'open',
          'priority': 'normal',
          'about': {'studentName': 'Aigerim'},
          'lastMessagePreview': 'Не понимаю условие',
          'lastMessageAt': '2026-09-17T10:00:00Z',
          'unreadCount': 2,
          'assignedToStaff': false,
          'createdAt': '2026-09-17T09:00:00Z',
        },
      ]));
    });

    final result = await repo.listThreads();
    final threads = (result as ApiOk<List<SupportThreadListItem>>).data;
    expect(threads.single.unreadCount, 2);
  });

  test('unreadCount hits GET /support/unread-count', () async {
    when(() => client.get<SupportUnreadCount>('/support/unread-count', decode: any(named: 'decode'))).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as SupportUnreadCount Function(dynamic);
      return ApiResult.ok(decode({'threads': 1, 'messages': 3}));
    });

    final result = await repo.unreadCount();
    expect((result as ApiOk<SupportUnreadCount>).data.messages, 3);
  });

  test('postMessage POSTs {body} to /support/threads/:id/messages', () async {
    when(() => client.post<SupportMessage>(
          '/support/threads/3/messages',
          data: {'body': 'Спасибо!'},
          decode: any(named: 'decode'),
        )).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as SupportMessage Function(dynamic);
      return ApiResult.ok(decode({
        'id': 9,
        'body': 'Спасибо!',
        'messageType': 'text',
        'senderRole': 'student',
        'senderName': 'Aigerim',
        'mine': true,
        'isInternal': false,
        'createdAt': '2026-09-18T10:00:00Z',
      }));
    });

    final result = await repo.postMessage(3, 'Спасибо!');
    expect((result as ApiOk<SupportMessage>).data.body, 'Спасибо!');
  });

  test('markRead POSTs to /support/threads/:id/read', () async {
    when(() => client.post<void>('/support/threads/3/read', decode: any(named: 'decode'))).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as void Function(dynamic);
      decode(null);
      return ApiResult.ok(null);
    });

    final result = await repo.markRead(3);
    expect(result, isA<ApiOk<void>>());
    verify(() => client.post<void>('/support/threads/3/read', decode: any(named: 'decode'))).called(1);
  });

  test('createThread omits null optional fields via the null-aware map syntax', () async {
    when(() => client.post<SupportThreadDetail>(
          '/support/threads',
          data: {'subject': 'Помогите', 'category': 'general', 'message': 'Привет'},
          decode: any(named: 'decode'),
        )).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as SupportThreadDetail Function(dynamic);
      return ApiResult.ok(decode({
        'id': 4,
        'subject': 'Помогите',
        'category': 'general',
        'status': 'open',
        'priority': 'normal',
        'about': {'studentName': 'Aigerim'},
        'lastMessagePreview': 'Привет',
        'lastMessageAt': '2026-09-18T10:00:00Z',
        'unreadCount': 0,
        'assignedToStaff': false,
        'createdAt': '2026-09-18T10:00:00Z',
        'isParentThread': false,
      }));
    });

    final result = await repo.createThread(subject: 'Помогите', category: 'general', message: 'Привет');
    expect((result as ApiOk<SupportThreadDetail>).data.id, 4);
  });
}
