import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/core/network/api_exception.dart';
import 'package:codeschool_mobile/core/providers/core_providers.dart';
import 'package:codeschool_mobile/core/router/app_routes.dart';
import 'package:codeschool_mobile/features/auth/application/auth_controller.dart';
import 'package:codeschool_mobile/features/catalog/application/catalog_providers.dart';
import 'package:codeschool_mobile/features/catalog/data/catalog_repository.dart';
import 'package:codeschool_mobile/features/catalog/presentation/course_detail_screen.dart';
import 'package:codeschool_mobile/features/catalog/presentation/module_screen.dart';
import 'package:codeschool_mobile/shared/models/app_role.dart';
import 'package:codeschool_mobile/shared/models/course.dart';
import 'package:codeschool_mobile/shared/models/course_content.dart';
import 'package:codeschool_mobile/shared/models/enrollment.dart';
import 'package:codeschool_mobile/shared/models/lesson.dart';
import 'package:codeschool_mobile/shared/models/progress.dart';
import 'package:codeschool_mobile/shared/models/user.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

class _FakeAuthController extends AuthController {
  _FakeAuthController(this._initial);
  final AppUser? _initial;

  @override
  Future<AppUser?> build() async => _initial;
}

final _course353 = Course(
  id: 353,
  levelId: 134,
  title: 'Год 1: Визуальная логика',
  slug: 'codeschool-year1-logic',
  description: '36 недель, 72 занятия, 9 модулей',
  ageFrom: 6,
  ageTo: 8,
  durationLessons: 72,
  projectsCount: 1,
  audience: 'student',
);

final _content = CourseContent(
  course: _course353,
  modules: List.generate(
    9,
    (i) => CourseModule(
      id: i + 1,
      courseId: 353,
      title: 'Модуль ${i + 1}',
      position: i + 1,
      lessons: List.generate(
        8,
        (j) => Lesson(id: i * 8 + j + 1, moduleId: i + 1, title: 'Урок ${j + 1}', lessonType: 'text', position: j + 1),
      ),
    ),
  ),
);

Future<void> _pumpDetail(WidgetTester tester, MockCatalogRepository repo, {AppUser? user}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final router = GoRouter(
    initialLocation: AppRoutes.courseDetailPath(353),
    routes: [
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
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        catalogRepositoryProvider.overrideWithValue(repo),
        authControllerProvider.overrideWith(() => _FakeAuthController(user)),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

void main() {
  group('CourseDetailScreen', () {
    testWidgets('lists all 9 modules and navigates into a module to show its 8 lessons', (tester) async {
      final repo = MockCatalogRepository();
      when(() => repo.getContent(353)).thenAnswer((_) async => ApiResult.ok(_content));
      when(() => repo.listMyCourses()).thenAnswer((_) async => ApiResult.ok([]));

      await _pumpDetail(tester, repo);
      await tester.pumpAndSettle();

      expect(find.text('Год 1: Визуальная логика'), findsOneWidget);
      expect(find.textContaining('Модуль 1'), findsOneWidget);

      // Catalog -> Course Details -> Module: tapping a module navigates,
      // it doesn't expand lessons inline.
      await tester.tap(find.textContaining('Модуль 1').first);
      await tester.pumpAndSettle();

      expect(find.text('1. Модуль 1'), findsOneWidget);
      expect(find.textContaining('Урок 1'), findsOneWidget);

      // The lesson list only builds visible items lazily — scroll to the
      // last lesson to confirm all 8 (not just the ones that fit on
      // screen) actually made it into the widget tree.
      await tester.dragUntilVisible(
        find.textContaining('Урок 8'),
        find.byType(Scrollable).first,
        const Offset(0, -250),
      );
      expect(find.textContaining('Урок 8'), findsOneWidget);
    });

    testWidgets('all 9 modules are reachable by scrolling the course detail list', (tester) async {
      final repo = MockCatalogRepository();
      when(() => repo.getContent(353)).thenAnswer((_) async => ApiResult.ok(_content));
      when(() => repo.listMyCourses()).thenAnswer((_) async => ApiResult.ok([]));

      await _pumpDetail(tester, repo);
      await tester.pumpAndSettle();

      // The module list only builds visible items lazily — scroll to the
      // last module to confirm all 9 (not just the ones that fit on
      // screen) actually made it into the widget tree.
      await tester.dragUntilVisible(
        find.textContaining('Модуль 9'),
        find.byType(Scrollable).first,
        const Offset(0, -300),
      );
      expect(find.textContaining('Модуль 9'), findsOneWidget);
    });

    testWidgets('shows a login prompt instead of an enroll button for a signed-out visitor', (tester) async {
      final repo = MockCatalogRepository();
      when(() => repo.getContent(353)).thenAnswer((_) async => ApiResult.ok(_content));

      await _pumpDetail(tester, repo, user: null);
      await tester.pumpAndSettle();

      expect(find.text('Войти'), findsOneWidget);
      expect(find.text('Записаться'), findsNothing);
    });

    testWidgets('an enrolled student sees the disabled "already enrolled" state', (tester) async {
      final repo = MockCatalogRepository();
      final student = const AppUser(id: 1, firstName: 'Аружан', role: AppRole.student, isActive: true);
      when(() => repo.getContent(353)).thenAnswer((_) async => ApiResult.ok(_content));
      when(() => repo.listMyCourses()).thenAnswer(
        (_) async => ApiResult.ok([
          MyCourseItem(
            enrollmentId: 1,
            status: 'active',
            enrolledAt: DateTime.utc(2026, 1, 1),
            course: const CourseBrief(id: 353, title: 'Год 1', slug: 'codeschool-year1-logic'),
          ),
        ]),
      );
      // Not yet fetched from the real backend in this fixture — the screen
      // must degrade to "no progress card" rather than crash on this call.
      when(() => repo.getCourseProgress(353)).thenAnswer((_) async => ApiResult.err(ApiException.network()));

      await _pumpDetail(tester, repo, user: student);
      await tester.pumpAndSettle();

      expect(find.text('Вы записаны'), findsOneWidget);
    });

    testWidgets('a not-yet-enrolled student can tap Enroll and see a success snackbar', (tester) async {
      final repo = MockCatalogRepository();
      final student = const AppUser(id: 1, firstName: 'Аружан', role: AppRole.student, isActive: true);
      when(() => repo.getContent(353)).thenAnswer((_) async => ApiResult.ok(_content));
      when(() => repo.listMyCourses()).thenAnswer((_) async => ApiResult.ok([]));
      when(() => repo.getCourseProgress(353)).thenAnswer((_) async => ApiResult.err(ApiException.network()));
      when(() => repo.enroll(353)).thenAnswer(
        (_) async => ApiResult.ok(
          Enrollment(id: 1, studentId: 1, courseId: 353, status: 'active', enrolledAt: DateTime.utc(2026, 1, 1)),
        ),
      );

      await _pumpDetail(tester, repo, user: student);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Записаться'));
      await tester.pumpAndSettle();

      expect(find.text('Запись на курс успешна'), findsOneWidget);
      verify(() => repo.enroll(353)).called(1);
    });

    testWidgets('shows a real progress bar when the backend provides course progress', (tester) async {
      final repo = MockCatalogRepository();
      final student = const AppUser(id: 1, firstName: 'Аружан', role: AppRole.student, isActive: true);
      when(() => repo.getContent(353)).thenAnswer((_) async => ApiResult.ok(_content));
      when(() => repo.listMyCourses()).thenAnswer(
        (_) async => ApiResult.ok([
          MyCourseItem(
            enrollmentId: 1,
            status: 'active',
            enrolledAt: DateTime.utc(2026, 1, 1),
            course: const CourseBrief(id: 353, title: 'Год 1', slug: 'codeschool-year1-logic'),
          ),
        ]),
      );
      when(() => repo.getCourseProgress(353)).thenAnswer(
        (_) async => ApiResult.ok(
          const CourseProgressDetail(
            courseId: 353,
            title: 'Год 1',
            completedLessons: 8,
            totalLessons: 72,
            progressPercent: 11,
            enrollmentStatus: 'active',
          ),
        ),
      );

      await _pumpDetail(tester, repo, user: student);
      await tester.pumpAndSettle();

      expect(find.textContaining('8/72'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
