import '../../../core/network/api_client.dart';
import '../../../shared/models/academy.dart';
import '../../../shared/models/course_content.dart';
import '../../../shared/models/enrollment.dart';

/// Talks to the Teacher Academy endpoints — exact routes in
/// backend/internal/academy/routes.go, mounted under `/teacher-academy`
/// behind `RequireRole("teacher")`. `getContent`/`enroll` reuse the same
/// response shapes as the student catalog (`courses.ContentResponse` /
/// `enrollments.Enrollment` — confirmed by reading `academy/service.go`,
/// which literally calls the student-flow services), so they decode into
/// the already-existing [CourseContent]/[Enrollment] models rather than
/// duplicating them.
///
/// Scope note: taking an academy lesson (viewing content, running code,
/// submitting a quiz) hits the *exact same* `/lessons`, `/assignments`,
/// `/quiz`, `/run` handlers as the student flow, just re-mounted under this
/// prefix (`cmd/api/main.go`) — real, not invented. Stage 35G wires the
/// catalog/dashboard/enrollment surface (this repository); reusing the
/// existing lesson/assignment/quiz/code-runner screens for the academy
/// prefix too would mean making every provider in those features
/// prefix-aware, a cross-cutting change documented as a limitation in this
/// stage's report rather than done as a rushed side effect here.
class AcademyRepository {
  AcademyRepository(this._client);
  final ApiClient _client;

  Future<ApiResult<List<AcademyCourseCard>>> listCourses() => _client.get<List<AcademyCourseCard>>(
        '/teacher-academy/courses',
        decode: (json) => (json as List).map((e) => AcademyCourseCard.fromJson(e as Map<String, dynamic>)).toList(),
      );

  Future<ApiResult<CourseContent>> getContent(int courseId) => _client.get<CourseContent>(
        '/teacher-academy/courses/$courseId/content',
        decode: (json) => CourseContent.fromJson(json as Map<String, dynamic>),
      );

  Future<ApiResult<Enrollment>> enroll(int courseId) => _client.post<Enrollment>(
        '/teacher-academy/courses/$courseId/enroll',
        decode: (json) => Enrollment.fromJson(json as Map<String, dynamic>),
      );

  Future<ApiResult<List<AcademyMyCourse>>> myCourses() => _client.get<List<AcademyMyCourse>>(
        '/teacher-academy/me/courses',
        decode: (json) => (json as List).map((e) => AcademyMyCourse.fromJson(e as Map<String, dynamic>)).toList(),
      );

  Future<ApiResult<AcademyDashboard>> dashboard() => _client.get<AcademyDashboard>(
        '/teacher-academy/dashboard',
        decode: (json) => AcademyDashboard.fromJson(json as Map<String, dynamic>),
      );
}
