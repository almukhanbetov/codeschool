import '../../../core/network/api_client.dart';
import '../../../shared/models/progress.dart';

/// Talks to GET /me/progress (backend/internal/progress/routes.go) — one
/// row per enrolled course, used for the student cabinet's course cards so
/// the percent for every course loads in a single request instead of one
/// `GET /me/courses/:id/progress` per card. Per-course detail (module/lesson
/// breakdown) still goes through `CatalogRepository.getCourseProgress`
/// (already built in Stage 35D) — not duplicated here.
class ProgressRepository {
  ProgressRepository(this._client);
  final ApiClient _client;

  Future<ApiResult<List<CourseProgress>>> listMyProgress() => _client.get<List<CourseProgress>>(
        '/me/progress',
        decode: (json) => (json as List).map((e) => CourseProgress.fromJson(e as Map<String, dynamic>)).toList(),
      );
}
