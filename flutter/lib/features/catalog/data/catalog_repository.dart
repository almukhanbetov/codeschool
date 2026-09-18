import '../../../core/network/api_client.dart';
import '../../../shared/models/course.dart';
import '../../../shared/models/course_content.dart';
import '../../../shared/models/enrollment.dart';
import '../../../shared/models/lesson.dart';
import '../../../shared/models/progress.dart';

/// Talks to GET /courses, /courses/:id, /courses/slug/:slug,
/// /courses/:id/content and POST /courses/:id/enroll — the exact routes
/// registered in backend/internal/courses/routes.go and
/// backend/internal/enrollments/routes.go. No local course data: every
/// screen this feeds renders whatever the API returns, nothing invented.
class CatalogRepository {
  CatalogRepository(this._client);
  final ApiClient _client;

  /// The backend has no server-side search — only `age_from`/`age_to`/
  /// `level_id` query params (see courses/handler.go `parseListFilter`).
  /// Text search is therefore done client-side over this result, not by a
  /// fabricated `?q=` param the backend doesn't support.
  Future<ApiResult<List<Course>>> listCourses({int? ageFrom, int? ageTo, int? levelId}) {
    return _client.get<List<Course>>(
      '/courses',
      query: {
        'age_from': ?ageFrom,
        'age_to': ?ageTo,
        'level_id': ?levelId,
      },
      auth: false,
      decode: (json) => (json as List).map((e) => Course.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<ApiResult<Course>> getById(int id) => _client.get<Course>(
        '/courses/$id',
        auth: false,
        decode: (json) => Course.fromJson(json as Map<String, dynamic>),
      );

  Future<ApiResult<Course>> getBySlug(String slug) => _client.get<Course>(
        '/courses/slug/$slug',
        auth: false,
        decode: (json) => Course.fromJson(json as Map<String, dynamic>),
      );

  Future<ApiResult<CourseContent>> getContent(int id) => _client.get<CourseContent>(
        '/courses/$id/content',
        auth: false,
        decode: (json) => CourseContent.fromJson(json as Map<String, dynamic>),
      );

  /// GET /courses/:id/modules (backend/internal/modules/routes.go) — the
  /// standalone modules resource. The course detail/module screens mostly
  /// reuse the already-fetched `/courses/:id/content` aggregate instead
  /// (avoids a second round trip for data already in hand), but this stays
  /// a real, independently callable method for anything that only needs
  /// the module list.
  Future<ApiResult<List<CourseModule>>> listModules(int courseId) => _client.get<List<CourseModule>>(
        '/courses/$courseId/modules',
        auth: false,
        decode: (json) => (json as List).map((e) => CourseModule.fromJson(e as Map<String, dynamic>)).toList(),
      );

  /// GET /modules/:id/lessons (backend/internal/lessons/routes.go).
  Future<ApiResult<List<Lesson>>> listLessonsByModule(int moduleId) => _client.get<List<Lesson>>(
        '/modules/$moduleId/lessons',
        auth: false,
        decode: (json) => (json as List).map((e) => Lesson.fromJson(e as Map<String, dynamic>)).toList(),
      );

  /// GET /lessons/:id (backend/internal/lessons/routes.go) — the Lesson
  /// Details stub screen fetches its own lesson fresh here rather than only
  /// trusting whatever the course/module screens already had cached, so it
  /// stays correct even reached directly (deep link, back-stack restore).
  Future<ApiResult<Lesson>> getLessonById(int lessonId) => _client.get<Lesson>(
        '/lessons/$lessonId',
        auth: false,
        decode: (json) => Lesson.fromJson(json as Map<String, dynamic>),
      );

  /// GET /me/courses/:id/progress (backend/internal/progress/routes.go) —
  /// student + auth only, and the backend itself 403s with `ErrNotEnrolled`
  /// if the caller isn't enrolled in this course yet. Callers should treat
  /// that 403 as "no progress to show", not as a failure.
  Future<ApiResult<CourseProgressDetail>> getCourseProgress(int courseId) => _client.get<CourseProgressDetail>(
        '/me/courses/$courseId/progress',
        decode: (json) => CourseProgressDetail.fromJson(json as Map<String, dynamic>),
      );

  /// Requires an authenticated student — the backend derives the student id
  /// from the access token, never from the request body (enrollments
  /// handler.go). A non-student role gets a real 403 from the backend, not
  /// a client-side guess.
  Future<ApiResult<Enrollment>> enroll(int courseId) => _client.post<Enrollment>(
        '/courses/$courseId/enroll',
        decode: (json) => Enrollment.fromJson(json as Map<String, dynamic>),
      );

  /// Mirrors GET /me/courses — used to show "already enrolled" instead of
  /// a plain "Enroll" button on the course detail screen.
  Future<ApiResult<List<MyCourseItem>>> listMyCourses() => _client.get<List<MyCourseItem>>(
        '/me/courses',
        decode: (json) => (json as List).map((e) => MyCourseItem.fromJson(e as Map<String, dynamic>)).toList(),
      );
}
