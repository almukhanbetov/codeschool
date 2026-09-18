import '../../../core/network/api_client.dart';
import '../../../shared/models/teacher.dart';

/// Talks to the teacher endpoints — exact routes in
/// backend/internal/groups/routes.go, all mounted under `/teacher` behind
/// `RequireRole("teacher")`. No local groups/students/submissions are ever
/// invented — every screen this feeds renders whatever the API returns.
class TeacherRepository {
  TeacherRepository(this._client);
  final ApiClient _client;

  Future<ApiResult<TeacherDashboard>> dashboard() => _client.get<TeacherDashboard>(
        '/teacher/dashboard',
        decode: (json) => TeacherDashboard.fromJson(json as Map<String, dynamic>),
      );

  Future<ApiResult<List<TeacherGroupListItem>>> listGroups() => _client.get<List<TeacherGroupListItem>>(
        '/teacher/groups',
        decode: (json) => (json as List).map((e) => TeacherGroupListItem.fromJson(e as Map<String, dynamic>)).toList(),
      );

  Future<ApiResult<TeacherGroupDetail>> getGroup(int id) => _client.get<TeacherGroupDetail>(
        '/teacher/groups/$id',
        decode: (json) => TeacherGroupDetail.fromJson(json as Map<String, dynamic>),
      );

  Future<ApiResult<List<TeacherGroupStudentItem>>> listGroupStudents(int groupId) =>
      _client.get<List<TeacherGroupStudentItem>>(
        '/teacher/groups/$groupId/students',
        decode: (json) => (json as List).map((e) => TeacherGroupStudentItem.fromJson(e as Map<String, dynamic>)).toList(),
      );

  Future<ApiResult<TeacherStudentDetail>> getGroupStudent(int groupId, int studentId) => _client.get<TeacherStudentDetail>(
        '/teacher/groups/$groupId/students/$studentId',
        decode: (json) => TeacherStudentDetail.fromJson(json as Map<String, dynamic>),
      );

  /// GET /teacher/submissions?status=&group_id=&course_id=&page=&limit= —
  /// the review queue. `status` is one of the real `submissions` CHECK
  /// values ('submitted'|'checking'|'passed'|'failed'); omitted = all. The
  /// backend replies `{"data": items, "meta": {page,limit,total}}` — `meta`
  /// is a sibling of `data`, not nested inside it, so it comes back via
  /// [ApiOk.meta] rather than through `decode`.
  Future<ApiResult<TeacherSubmissionListResult>> listSubmissions({
    String? status,
    int? groupId,
    int? courseId,
    int page = 1,
    int limit = 20,
  }) async {
    final result = await _client.get<List<TeacherSubmissionListItem>>(
      '/teacher/submissions',
      query: {
        'status': ?status,
        'group_id': ?groupId,
        'course_id': ?courseId,
        'page': page,
        'limit': limit,
      },
      decode: (json) => (json as List).map((e) => TeacherSubmissionListItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
    return switch (result) {
      ApiOk(:final data, :final meta) => ApiResult.ok(
          TeacherSubmissionListResult(
            items: data,
            meta: meta != null
                ? TeacherSubmissionListMeta.fromJson(meta)
                : TeacherSubmissionListMeta(page: page, limit: limit, total: data.length),
          ),
        ),
      ApiErr(:final error) => ApiResult.err(error),
    };
  }

  Future<ApiResult<TeacherSubmissionDetail>> getSubmission(int id) => _client.get<TeacherSubmissionDetail>(
        '/teacher/submissions/$id',
        decode: (json) => TeacherSubmissionDetail.fromJson(json as Map<String, dynamic>),
      );

  Future<ApiResult<TeacherSubmissionDetail>> startReview(int id) => _client.post<TeacherSubmissionDetail>(
        '/teacher/submissions/$id/start-review',
        decode: (json) => TeacherSubmissionDetail.fromJson(json as Map<String, dynamic>),
      );

  /// [status] must be 'passed' or 'failed' (`ReviewRequest.Status`,
  /// `binding:"required"`) — the server also requires non-empty feedback
  /// when [status] is 'failed' (`ErrFeedbackRequired`).
  Future<ApiResult<TeacherSubmissionDetail>> review(
    int id, {
    int? score,
    required String feedback,
    required String status,
  }) =>
      _client.post<TeacherSubmissionDetail>(
        '/teacher/submissions/$id/review',
        data: {
          'score': ?score,
          'feedback': feedback,
          'status': status,
        },
        decode: (json) => TeacherSubmissionDetail.fromJson(json as Map<String, dynamic>),
      );
}
