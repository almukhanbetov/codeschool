import '../../../core/network/api_client.dart';
import '../../../shared/models/assignment.dart';

/// Talks to the text/project submission endpoints — exact routes in
/// backend/internal/submissions/routes.go. Student + enrollment enforced by
/// the backend (`ErrNotEnrolled` → 403, `ErrLocked` → 409 once a teacher has
/// graded it). Never computes a score or "passed" locally — every verdict
/// shown to the user comes straight from `Submission.status`/`score`.
class AssignmentRepository {
  AssignmentRepository(this._client);
  final ApiClient _client;

  /// GET /assignments/:id/submission — `data: null` (no submission yet) is
  /// a normal 200, not an error (submissions/handler.go `GetMine`).
  Future<ApiResult<Submission?>> getMine(int assignmentId) => _client.get<Submission?>(
        '/assignments/$assignmentId/submission',
        decode: (json) => json == null ? null : Submission.fromJson(json as Map<String, dynamic>),
      );

  /// PUT /assignments/:id/submission — saves a draft; either field may be
  /// omitted depending on assignment type (`code` for code assignments,
  /// `answer` for text/project).
  Future<ApiResult<Submission>> saveDraft(int assignmentId, {String? code, String? answer}) => _client.put<Submission>(
        '/assignments/$assignmentId/submission',
        data: {
          'code': ?code,
          'answer': ?answer,
        },
        decode: (json) => Submission.fromJson(json as Map<String, dynamic>),
      );

  /// POST /assignments/:id/submit — finalizes the current draft.
  Future<ApiResult<Submission>> submit(int assignmentId) => _client.post<Submission>(
        '/assignments/$assignmentId/submit',
        decode: (json) => Submission.fromJson(json as Map<String, dynamic>),
      );
}
