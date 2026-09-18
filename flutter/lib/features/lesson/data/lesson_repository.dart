import '../../../core/network/api_client.dart';
import '../../../shared/models/assignment.dart';
import '../../../shared/models/progress.dart';

/// Talks to the lesson-scoped student endpoints — exact routes registered
/// in backend/internal/assignments/routes.go and
/// backend/internal/progress/routes.go. All three require an authenticated,
/// enrolled student (`RequireRole("student")`); the backend enforces
/// enrollment itself (`ErrNotEnrolled` → 403), this repository never
/// pre-checks that client-side.
class LessonRepository {
  LessonRepository(this._client);
  final ApiClient _client;

  /// GET /lessons/:id/assignments.
  Future<ApiResult<List<Assignment>>> listAssignments(int lessonId) => _client.get<List<Assignment>>(
        '/lessons/$lessonId/assignments',
        decode: (json) => (json as List).map((e) => Assignment.fromJson(e as Map<String, dynamic>)).toList(),
      );

  /// POST /lessons/:id/start — marks the lesson as started (idempotent on
  /// the backend, safe to call every time the lesson screen opens).
  Future<ApiResult<LessonProgress>> startLesson(int lessonId) => _client.post<LessonProgress>(
        '/lessons/$lessonId/start',
        decode: (json) => LessonProgress.fromJson(json as Map<String, dynamic>),
      );

  /// POST /lessons/:id/complete — the backend requires every published
  /// assignment on the lesson to already have a non-draft submission
  /// (progress/service.go `CompleteLesson`); a real 409 `ErrAssignmentIncomplete`
  /// comes back otherwise, never silently accepted.
  Future<ApiResult<CompleteLessonResult>> completeLesson(int lessonId) => _client.post<CompleteLessonResult>(
        '/lessons/$lessonId/complete',
        decode: (json) => CompleteLessonResult.fromJson(json as Map<String, dynamic>),
      );
}
