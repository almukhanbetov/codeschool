/// Centralized route path constants. Kept as plain strings (not an enum)
/// so `go_router`'s path-matching and `GoRoute.path` can share the same
/// literal without an extra mapping layer. Extended stage-by-stage as each
/// feature's screens land (auth in 35C, catalog in 35D, ...).
class AppRoutes {
  const AppRoutes._();

  static const boot = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const catalog = '/catalog';
  static const courseDetail = '/catalog/course/:id';
  static const moduleDetail = '/catalog/course/:courseId/module/:moduleId';
  static const lessonDetail = '/catalog/course/:courseId/module/:moduleId/lesson/:lessonId';

  static const assignmentDetail = '/assignment/:assignmentId';
  static const assignmentQuiz = '/assignment/:assignmentId/quiz';
  static const assignmentCode = '/assignment/:assignmentId/code';

  static const courseProgress = '/catalog/course/:id/progress';
  static const certificates = '/certificates';
  static const certificateDetail = '/certificates/:id';

  // Stage 35G — teacher cabinet.
  static const teacherGroups = '/teacher/groups';
  static const teacherGroupDetail = '/teacher/groups/:groupId';
  static const teacherStudentDetail = '/teacher/groups/:groupId/students/:studentId';
  static const teacherSubmissions = '/teacher/submissions';
  static const teacherSubmissionDetail = '/teacher/submissions/:id';
  static const teacherAcademy = '/teacher/academy';

  // Stage 35G — parent cabinet.
  static const parentChildDetail = '/parent/children/:childId';
  static const parentChildCourseDetail = '/parent/children/:childId/courses/:courseId';
  static const parentChildActivity = '/parent/children/:childId/activity';

  // Stage 35G — support chat / notifications.
  static const supportThreads = '/support';
  static const supportThreadDetail = '/support/threads/:id';
  static const supportNewThread = '/support/new';

  static String courseDetailPath(int id) => '/catalog/course/$id';
  static String moduleDetailPath(int courseId, int moduleId) => '/catalog/course/$courseId/module/$moduleId';
  static String lessonDetailPath(int courseId, int moduleId, int lessonId) =>
      '/catalog/course/$courseId/module/$moduleId/lesson/$lessonId';
  static String assignmentDetailPath(int assignmentId) => '/assignment/$assignmentId';
  static String assignmentQuizPath(int assignmentId) => '/assignment/$assignmentId/quiz';
  static String assignmentCodePath(int assignmentId) => '/assignment/$assignmentId/code';
  static String courseProgressPath(int courseId) => '/catalog/course/$courseId/progress';
  static String certificateDetailPath(int id) => '/certificates/$id';

  static String teacherGroupDetailPath(int groupId) => '/teacher/groups/$groupId';
  static String teacherStudentDetailPath(int groupId, int studentId) => '/teacher/groups/$groupId/students/$studentId';
  static String teacherSubmissionDetailPath(int id) => '/teacher/submissions/$id';

  static String parentChildDetailPath(int childId) => '/parent/children/$childId';
  static String parentChildCourseDetailPath(int childId, int courseId) => '/parent/children/$childId/courses/$courseId';
  static String parentChildActivityPath(int childId) => '/parent/children/$childId/activity';

  static String supportThreadDetailPath(int id) => '/support/threads/$id';

  /// Stage 35H — a protected route pushes here instead of bare [login] so
  /// the router's redirect (see `app_router.dart`) can send the user back
  /// to the action they actually wanted once they've signed in, rather
  /// than always dumping them on the generic home screen.
  static String loginWithNext(String path) => '$login?next=${Uri.encodeComponent(path)}';
}
