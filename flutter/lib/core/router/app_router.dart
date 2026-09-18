import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/assignment/presentation/assignment_screen.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/catalog/presentation/catalog_screen.dart';
import '../../features/catalog/presentation/course_detail_screen.dart';
import '../../features/catalog/presentation/module_screen.dart';
import '../../features/certificates/presentation/certificate_detail_screen.dart';
import '../../features/certificates/presentation/certificate_list_screen.dart';
import '../../features/code_runner/presentation/code_runner_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/lesson/presentation/lesson_detail_screen.dart';
import '../../features/parent/presentation/child_activity_screen.dart';
import '../../features/parent/presentation/child_course_detail_screen.dart';
import '../../features/parent/presentation/child_overview_screen.dart';
import '../../features/progress/presentation/course_progress_screen.dart';
import '../../features/quiz/presentation/quiz_screen.dart';
import '../../features/support_chat/presentation/support_new_thread_screen.dart';
import '../../features/support_chat/presentation/support_thread_detail_screen.dart';
import '../../features/support_chat/presentation/support_thread_list_screen.dart';
import '../../features/teacher/presentation/teacher_group_detail_screen.dart';
import '../../features/teacher/presentation/teacher_groups_screen.dart';
import '../../features/teacher/presentation/teacher_student_detail_screen.dart';
import '../../features/teacher/presentation/teacher_submission_detail_screen.dart';
import '../../features/teacher/presentation/teacher_submissions_screen.dart';
import '../../features/teacher_academy/presentation/academy_screen.dart';
import '../../shared/models/assignment.dart';
import '../widgets/branded_splash.dart';
import 'app_routes.dart';

/// A guest (no session) never *has* to sign in just to see what CodeSchool
/// is — `/home` itself renders the public marketing home for a `null` user
/// (see `HomeScreen`) and the catalog is real, unauthenticated `GET
/// /courses` data (established Stage 35D). Course progress is personal,
/// though, so it's excluded even though its path sits under `/catalog/...`.
/// Every other route (teacher/parent cabinets, certificates, support chat,
/// assignments) stays behind a real session — this is a curated allow-list,
/// not a weakening of any backend RBAC check.
bool _isPublicLocation(String loc) {
  if (loc == AppRoutes.boot || loc == AppRoutes.login || loc == AppRoutes.register || loc == AppRoutes.home) {
    return true;
  }
  if (loc.startsWith(AppRoutes.catalog)) return !loc.endsWith('/progress');
  return false;
}

/// Bridges Riverpod's `authControllerProvider` to go_router's
/// `refreshListenable`, so a *single* [GoRouter] instance re-runs its
/// `redirect` callback whenever auth state changes, instead of the whole
/// router (and its in-memory navigation location) being torn down and
/// rebuilt from `initialLocation` on every login/logout/session-expiry.
///
/// Stage 35H originally kept the older "new GoRouter per auth state" shape,
/// but that made a real bug reproducible: right after a successful login,
/// re-deriving location from `initialLocation` raced with returning the
/// user to the protected page they actually asked for (`?next=...`), and
/// sometimes won, silently dropping them back on the generic home screen
/// instead. A `refreshListenable` on one long-lived router is the
/// standard go_router fix and removes that race entirely.
class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(Ref ref) {
    _sub = ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
  late final ProviderSubscription<AsyncValue<Object?>> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.boot,
    refreshListenable: refresh,
    redirect: (context, state) {
      // `ref.read`, not `watch` — this provider must build exactly once so
      // the router (and its navigation history) survives auth changes;
      // `refresh` above is what re-triggers this callback on each change.
      final auth = ref.read(authControllerProvider);
      if (auth.isLoading) return null; // stay on the boot splash
      final isAuthed = auth.valueOrNull != null;
      final loc = state.matchedLocation;

      // Stage 35H: the splash always resolves to /home — whether that's
      // the public marketing page or a personal cabinet is /home's own
      // decision (based on auth state), not the router's. This is the fix
      // for "app always opens straight to login": the old rule here only
      // ever sent an *authenticated* user on from boot, so a guest fell
      // through to the "not authed + not a public page" rule below and
      // landed on /login before ever seeing a home screen.
      if (loc == AppRoutes.boot) return AppRoutes.home;

      final isAuthPage = loc == AppRoutes.login || loc == AppRoutes.register;
      if (isAuthed && isAuthPage) {
        final next = state.uri.queryParameters['next'];
        return next != null && next.isNotEmpty ? Uri.decodeComponent(next) : AppRoutes.home;
      }
      // A protected route with no session — bounce to login, but remember
      // where they were headed (enroll, progress, a teacher/parent screen,
      // ...) so they land back there once signed in, not just on /home.
      // Covers both a cold deep-link and a session that expired mid-use
      // (AuthController clears its state on a 401 from anywhere, which
      // flows through this same `auth` watch).
      if (!isAuthed && !_isPublicLocation(loc)) {
        return AppRoutes.loginWithNext(state.uri.toString());
      }
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.boot, builder: (context, state) => const BrandedSplash()),
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (context, state) => const RegisterScreen()),
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: AppRoutes.catalog, builder: (context, state) => const CatalogScreen()),
      GoRoute(
        path: AppRoutes.courseDetail,
        builder: (context, state) => CourseDetailScreen(courseId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: AppRoutes.moduleDetail,
        builder: (context, state) => ModuleScreen(
          courseId: int.parse(state.pathParameters['courseId']!),
          moduleId: int.parse(state.pathParameters['moduleId']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.lessonDetail,
        builder: (context, state) => LessonDetailScreen(
          courseId: int.parse(state.pathParameters['courseId']!),
          moduleId: int.parse(state.pathParameters['moduleId']!),
          lessonId: int.parse(state.pathParameters['lessonId']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.assignmentDetail,
        builder: (context, state) => AssignmentScreen(assignment: state.extra as Assignment),
      ),
      GoRoute(
        path: AppRoutes.assignmentQuiz,
        builder: (context, state) => QuizScreen(assignment: state.extra as Assignment),
      ),
      GoRoute(
        path: AppRoutes.assignmentCode,
        builder: (context, state) => CodeRunnerScreen(assignment: state.extra as Assignment),
      ),
      GoRoute(
        path: AppRoutes.courseProgress,
        builder: (context, state) => CourseProgressScreen(courseId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(path: AppRoutes.certificates, builder: (context, state) => const CertificateListScreen()),
      GoRoute(
        path: AppRoutes.certificateDetail,
        builder: (context, state) => CertificateDetailScreen(certificateId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(path: AppRoutes.teacherGroups, builder: (context, state) => const TeacherGroupsScreen()),
      GoRoute(
        path: AppRoutes.teacherGroupDetail,
        builder: (context, state) => TeacherGroupDetailScreen(groupId: int.parse(state.pathParameters['groupId']!)),
      ),
      GoRoute(
        path: AppRoutes.teacherStudentDetail,
        builder: (context, state) => TeacherStudentDetailScreen(
          groupId: int.parse(state.pathParameters['groupId']!),
          studentId: int.parse(state.pathParameters['studentId']!),
        ),
      ),
      GoRoute(path: AppRoutes.teacherSubmissions, builder: (context, state) => const TeacherSubmissionsScreen()),
      GoRoute(
        path: AppRoutes.teacherSubmissionDetail,
        builder: (context, state) => TeacherSubmissionDetailScreen(submissionId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(path: AppRoutes.teacherAcademy, builder: (context, state) => const AcademyScreen()),
      GoRoute(
        path: AppRoutes.parentChildDetail,
        builder: (context, state) => ChildOverviewScreen(childId: int.parse(state.pathParameters['childId']!)),
      ),
      GoRoute(
        path: AppRoutes.parentChildCourseDetail,
        builder: (context, state) => ChildCourseDetailScreen(
          childId: int.parse(state.pathParameters['childId']!),
          courseId: int.parse(state.pathParameters['courseId']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.parentChildActivity,
        builder: (context, state) => ChildActivityScreen(childId: int.parse(state.pathParameters['childId']!)),
      ),
      GoRoute(path: AppRoutes.supportThreads, builder: (context, state) => const SupportThreadListScreen()),
      GoRoute(path: AppRoutes.supportNewThread, builder: (context, state) => const SupportNewThreadScreen()),
      GoRoute(
        path: AppRoutes.supportThreadDetail,
        builder: (context, state) => SupportThreadDetailScreen(threadId: int.parse(state.pathParameters['id']!)),
      ),
    ],
  );
});
