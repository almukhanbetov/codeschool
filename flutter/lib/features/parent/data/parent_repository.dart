import '../../../core/network/api_client.dart';
import '../../../shared/models/parent.dart';

/// Talks to the parent endpoints — exact routes in
/// backend/internal/parents/routes.go, all mounted under `/parent` behind
/// `RequireRole("parent")`. Every route is read-only. The backend itself is
/// the access boundary for "only my own linked children" — `ListChildren`
/// etc. all key off the caller's own id from the JWT
/// (`authctx.UserID(c)`), never an id the client supplies, so there is no
/// child-id parameter to spoof on the *list* call; the per-child routes
/// below still 404/403 server-side if a parent ever tried a child id that
/// isn't actually linked to them (see `ParentRepository` doc on
/// `getChild`).
class ParentRepository {
  ParentRepository(this._client);
  final ApiClient _client;

  Future<ApiResult<List<ParentChildListItem>>> listChildren() => _client.get<List<ParentChildListItem>>(
        '/parent/children',
        decode: (json) => (json as List).map((e) => ParentChildListItem.fromJson(e as Map<String, dynamic>)).toList(),
      );

  /// A child id that isn't actually linked to the calling parent is
  /// rejected server-side (RBAC, not a client-side guess) — this repository
  /// never filters or double-checks that itself.
  Future<ApiResult<ParentChildOverview>> getChild(int childId) => _client.get<ParentChildOverview>(
        '/parent/children/$childId',
        decode: (json) => ParentChildOverview.fromJson(json as Map<String, dynamic>),
      );

  Future<ApiResult<ParentChildCourseDetail>> getChildCourse(int childId, int courseId) =>
      _client.get<ParentChildCourseDetail>(
        '/parent/children/$childId/courses/$courseId',
        decode: (json) => ParentChildCourseDetail.fromJson(json as Map<String, dynamic>),
      );

  Future<ApiResult<ParentActivitySummary>> getChildActivity(int childId) => _client.get<ParentActivitySummary>(
        '/parent/children/$childId/activity',
        decode: (json) => ParentActivitySummary.fromJson(json as Map<String, dynamic>),
      );
}
