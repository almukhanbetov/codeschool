import '../../../core/network/api_client.dart';
import '../../../shared/models/support.dart';

/// Talks to the student/parent support-chat endpoints — exact routes in
/// backend/internal/support/routes.go, mounted under `/support` behind
/// `RequireRole("student","parent")` (teachers have no support-chat access
/// per the backend's own comment — this repository is never wired up for a
/// teacher session). This is also the real "notifications" surface: the
/// backend has no separate notifications feed/list endpoint anywhere
/// (confirmed by a full-repo search) — `unreadCount()` and the thread list
/// are what actually exist.
class SupportRepository {
  SupportRepository(this._client);
  final ApiClient _client;

  Future<ApiResult<List<SupportThreadListItem>>> listThreads() => _client.get<List<SupportThreadListItem>>(
        '/support/threads',
        decode: (json) => (json as List).map((e) => SupportThreadListItem.fromJson(e as Map<String, dynamic>)).toList(),
      );

  Future<ApiResult<SupportUnreadCount>> unreadCount() => _client.get<SupportUnreadCount>(
        '/support/unread-count',
        decode: (json) => SupportUnreadCount.fromJson(json as Map<String, dynamic>),
      );

  Future<ApiResult<SupportThreadDetail>> getThread(int id) => _client.get<SupportThreadDetail>(
        '/support/threads/$id',
        decode: (json) => SupportThreadDetail.fromJson(json as Map<String, dynamic>),
      );

  Future<ApiResult<List<SupportMessage>>> listMessages(int threadId) => _client.get<List<SupportMessage>>(
        '/support/threads/$threadId/messages',
        decode: (json) => (json as List).map((e) => SupportMessage.fromJson(e as Map<String, dynamic>)).toList(),
      );

  Future<ApiResult<SupportMessage>> postMessage(int threadId, String body) => _client.post<SupportMessage>(
        '/support/threads/$threadId/messages',
        data: {'body': body},
        decode: (json) => SupportMessage.fromJson(json as Map<String, dynamic>),
      );

  Future<ApiResult<void>> markRead(int threadId) => _client.post<void>('/support/threads/$threadId/read', decode: (_) {});

  /// [category] must be one of [supportThreadCategories]. [studentId] is
  /// only meaningful (and only read by the backend) for a parent thread —
  /// it must be one of the parent's own linked children, enforced
  /// server-side, never assumed here.
  Future<ApiResult<SupportThreadDetail>> createThread({
    required String subject,
    required String category,
    required String message,
    int? courseId,
    int? lessonId,
    int? assignmentId,
    int? studentId,
  }) =>
      _client.post<SupportThreadDetail>(
        '/support/threads',
        data: {
          'subject': subject,
          'category': category,
          'message': message,
          'courseId': ?courseId,
          'lessonId': ?lessonId,
          'assignmentId': ?assignmentId,
          'studentId': ?studentId,
        },
        decode: (json) => SupportThreadDetail.fromJson(json as Map<String, dynamic>),
      );
}
