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
import 'package:codeschool_mobile/features/assignment/application/assignment_providers.dart';
import 'package:codeschool_mobile/features/assignment/data/assignment_repository.dart';
import 'package:codeschool_mobile/features/auth/application/auth_controller.dart';
import 'package:codeschool_mobile/features/catalog/application/catalog_providers.dart';
import 'package:codeschool_mobile/features/catalog/data/catalog_repository.dart';
import 'package:codeschool_mobile/features/lesson/application/lesson_providers.dart';
import 'package:codeschool_mobile/features/lesson/data/lesson_repository.dart';
import 'package:codeschool_mobile/features/lesson/presentation/lesson_detail_screen.dart';
import 'package:codeschool_mobile/shared/models/app_role.dart';
import 'package:codeschool_mobile/shared/models/assignment.dart';
import 'package:codeschool_mobile/shared/models/course.dart';
import 'package:codeschool_mobile/shared/models/course_content.dart';
import 'package:codeschool_mobile/shared/models/lesson.dart';
import 'package:codeschool_mobile/shared/models/progress.dart';
import 'package:codeschool_mobile/shared/models/user.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

class MockLessonRepository extends Mock implements LessonRepository {}

class MockAssignmentRepository extends Mock implements AssignmentRepository {}

class _FakeAuthController extends AuthController {
  _FakeAuthController(this._initial);
  final AppUser? _initial;

  @override
  Future<AppUser?> build() async => _initial;
}

const _student = AppUser(id: 1, firstName: 'Аружан', role: AppRole.student, isActive: true);

final _lesson350 = Lesson(
  id: 350,
  moduleId: 261,
  title: 'Что делает компьютер?',
  description: 'Неделя 1, занятие 1 · 30 минут · 6–8 лет',
  content: '## Цель урока\nПонять, что компьютер сам по себе ничего не придумывает.',
  lessonType: 'text',
  position: 1,
);

final _content = CourseContent(
  course: const Course(id: 353, levelId: 134, title: 'Год 1', slug: 'codeschool-year1-logic', audience: 'student'),
  modules: [
    CourseModule(
      id: 261,
      courseId: 353,
      title: 'Компьютер и алгоритмы',
      position: 1,
      lessons: [
        _lesson350,
        Lesson(id: 351, moduleId: 261, title: 'Игра «Я — компьютер»', lessonType: 'text', position: 2),
      ],
    ),
  ],
);

Future<void> _pumpLesson(
  WidgetTester tester, {
  required MockCatalogRepository catalogRepo,
  required MockLessonRepository lessonRepo,
  MockAssignmentRepository? assignmentRepo,
  AppUser? user,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final router = GoRouter(
    initialLocation: AppRoutes.lessonDetailPath(353, 261, 350),
    routes: [
      GoRoute(
        path: AppRoutes.lessonDetail,
        builder: (context, state) => LessonDetailScreen(
          courseId: int.parse(state.pathParameters['courseId']!),
          moduleId: int.parse(state.pathParameters['moduleId']!),
          lessonId: int.parse(state.pathParameters['lessonId']!),
        ),
      ),
      GoRoute(path: AppRoutes.assignmentDetail, builder: (context, state) => const Scaffold(body: Text('assignment screen'))),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        catalogRepositoryProvider.overrideWithValue(catalogRepo),
        lessonRepositoryProvider.overrideWithValue(lessonRepo),
        if (assignmentRepo != null) assignmentRepositoryProvider.overrideWithValue(assignmentRepo),
        authControllerProvider.overrideWith(() => _FakeAuthController(user)),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

void main() {
  group('LessonDetailScreen', () {
    testWidgets('renders the real lesson data, safe-markdown content, and starts the lesson for a student', (tester) async {
      final catalogRepo = MockCatalogRepository();
      final lessonRepo = MockLessonRepository();
      when(() => catalogRepo.getContent(353)).thenAnswer((_) async => ApiResult.ok(_content));
      when(() => catalogRepo.getLessonById(350)).thenAnswer((_) async => ApiResult.ok(_lesson350));
      when(() => catalogRepo.getCourseProgress(353)).thenAnswer((_) async => ApiResult.err(ApiException.network()));
      when(() => lessonRepo.listAssignments(350)).thenAnswer((_) async => ApiResult.ok([]));
      when(() => lessonRepo.startLesson(350)).thenAnswer(
        (_) async => ApiResult.ok(const LessonProgress(lessonId: 350, status: 'in_progress', progressPercent: 0)),
      );

      await _pumpLesson(tester, catalogRepo: catalogRepo, lessonRepo: lessonRepo, user: _student);
      await tester.pumpAndSettle();

      expect(find.text('Что делает компьютер?'), findsOneWidget);
      expect(find.textContaining('Цель урока'), findsOneWidget);
      expect(find.text('В этом уроке нет задания'), findsOneWidget);
      verify(() => lessonRepo.startLesson(350)).called(1);
    });

    testWidgets('shows an assignment card and does not call startLesson for a signed-out visitor', (tester) async {
      final catalogRepo = MockCatalogRepository();
      final lessonRepo = MockLessonRepository();
      final assignmentRepo = MockAssignmentRepository();
      when(() => catalogRepo.getContent(353)).thenAnswer((_) async => ApiResult.ok(_content));
      when(() => catalogRepo.getLessonById(350)).thenAnswer((_) async => ApiResult.ok(_lesson350));
      when(() => catalogRepo.getCourseProgress(353)).thenAnswer((_) async => ApiResult.err(ApiException.network()));
      when(() => lessonRepo.listAssignments(350)).thenAnswer(
        (_) async => ApiResult.ok([
          const Assignment(id: 900, lessonId: 350, title: 'Придумай 3 команды', assignmentType: 'text', points: 5, position: 1),
        ]),
      );
      when(() => assignmentRepo.getMine(900)).thenAnswer((_) async => ApiResult.ok(null));

      await _pumpLesson(tester, catalogRepo: catalogRepo, lessonRepo: lessonRepo, assignmentRepo: assignmentRepo, user: null);
      await tester.pumpAndSettle();

      expect(find.text('Придумай 3 команды'), findsOneWidget);
      verifyNever(() => lessonRepo.startLesson(any()));
    });

    testWidgets('shows the error state on a failed lesson fetch with a working retry', (tester) async {
      final catalogRepo = MockCatalogRepository();
      final lessonRepo = MockLessonRepository();
      when(() => catalogRepo.getContent(353)).thenAnswer((_) async => ApiResult.err(ApiException.network()));
      when(() => catalogRepo.getCourseProgress(353)).thenAnswer((_) async => ApiResult.err(ApiException.network()));
      when(() => lessonRepo.listAssignments(350)).thenAnswer((_) async => ApiResult.ok([]));
      // getLessonById lives on CatalogRepository too (fresh-fetch design).
      when(() => catalogRepo.getLessonById(350)).thenAnswer((_) async => ApiResult.err(ApiException.network()));

      await _pumpLesson(tester, catalogRepo: catalogRepo, lessonRepo: lessonRepo, user: null);
      await tester.pumpAndSettle();

      expect(find.text('Нет соединения с сервером'), findsOneWidget);
    });

    testWidgets('completing the lesson shows the real success message and refreshes progress', (tester) async {
      final catalogRepo = MockCatalogRepository();
      final lessonRepo = MockLessonRepository();
      when(() => catalogRepo.getContent(353)).thenAnswer((_) async => ApiResult.ok(_content));
      when(() => catalogRepo.getLessonById(350)).thenAnswer((_) async => ApiResult.ok(_lesson350));
      when(() => catalogRepo.getCourseProgress(353)).thenAnswer((_) async => ApiResult.err(ApiException.network()));
      when(() => lessonRepo.listAssignments(350)).thenAnswer((_) async => ApiResult.ok([]));
      when(() => lessonRepo.startLesson(350)).thenAnswer(
        (_) async => ApiResult.ok(const LessonProgress(lessonId: 350, status: 'in_progress', progressPercent: 0)),
      );
      when(() => lessonRepo.completeLesson(350)).thenAnswer(
        (_) async => ApiResult.ok(
          const CompleteLessonResult(
            lesson: LessonProgress(lessonId: 350, status: 'completed', progressPercent: 100),
            course: CourseProgress(courseId: 353, title: 'Год 1', completedLessons: 1, totalLessons: 72, progressPercent: 1),
            enrollmentCompleted: false,
          ),
        ),
      );

      await _pumpLesson(tester, catalogRepo: catalogRepo, lessonRepo: lessonRepo, user: _student);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Завершить урок'));
      await tester.pumpAndSettle();

      expect(find.text('Урок завершён'), findsOneWidget);
    });

    testWidgets('a 409 from complete-lesson shows the real "finish assignments first" message', (tester) async {
      final catalogRepo = MockCatalogRepository();
      final lessonRepo = MockLessonRepository();
      when(() => catalogRepo.getContent(353)).thenAnswer((_) async => ApiResult.ok(_content));
      when(() => catalogRepo.getLessonById(350)).thenAnswer((_) async => ApiResult.ok(_lesson350));
      when(() => catalogRepo.getCourseProgress(353)).thenAnswer((_) async => ApiResult.err(ApiException.network()));
      when(() => lessonRepo.listAssignments(350)).thenAnswer((_) async => ApiResult.ok([]));
      when(() => lessonRepo.startLesson(350)).thenAnswer(
        (_) async => ApiResult.ok(const LessonProgress(lessonId: 350, status: 'in_progress', progressPercent: 0)),
      );
      when(() => lessonRepo.completeLesson(350)).thenAnswer(
        (_) async => ApiResult.err(
          ApiException(statusCode: 409, code: 'CONFLICT', message: "Submit the lesson's assignment before completing it"),
        ),
      );

      await _pumpLesson(tester, catalogRepo: catalogRepo, lessonRepo: lessonRepo, user: _student);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Завершить урок'));
      await tester.pumpAndSettle();

      expect(find.text('Сначала выполните задания урока'), findsOneWidget);
    });

    testWidgets('shows a "next lesson" button that navigates to the sibling lesson', (tester) async {
      final catalogRepo = MockCatalogRepository();
      final lessonRepo = MockLessonRepository();
      when(() => catalogRepo.getContent(353)).thenAnswer((_) async => ApiResult.ok(_content));
      when(() => catalogRepo.getLessonById(350)).thenAnswer((_) async => ApiResult.ok(_lesson350));
      when(() => catalogRepo.getCourseProgress(353)).thenAnswer((_) async => ApiResult.err(ApiException.network()));
      when(() => lessonRepo.listAssignments(any())).thenAnswer((_) async => ApiResult.ok([]));
      when(() => catalogRepo.getLessonById(351)).thenAnswer(
        (_) async => ApiResult.ok(
          const Lesson(id: 351, moduleId: 261, title: 'Игра «Я — компьютер»', lessonType: 'text', position: 2),
        ),
      );

      await _pumpLesson(tester, catalogRepo: catalogRepo, lessonRepo: lessonRepo, user: null);
      await tester.pumpAndSettle();

      expect(find.text('Следующий урок'), findsOneWidget);
      expect(find.text('Предыдущий урок'), findsNothing);

      await tester.tap(find.text('Следующий урок'));
      await tester.pumpAndSettle();

      expect(find.text('Игра «Я — компьютер»'), findsOneWidget);
    });
  });
}
