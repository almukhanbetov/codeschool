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
import 'package:codeschool_mobile/features/certificates/application/certificate_providers.dart';
import 'package:codeschool_mobile/features/certificates/data/certificate_repository.dart';
import 'package:codeschool_mobile/features/lesson/application/lesson_providers.dart';
import 'package:codeschool_mobile/features/lesson/data/lesson_repository.dart';
import 'package:codeschool_mobile/features/progress/presentation/course_progress_screen.dart';
import 'package:codeschool_mobile/features/quiz/application/quiz_providers.dart';
import 'package:codeschool_mobile/features/quiz/data/quiz_repository.dart';
import 'package:codeschool_mobile/shared/models/app_role.dart';
import 'package:codeschool_mobile/shared/models/course.dart';
import 'package:codeschool_mobile/shared/models/course_content.dart';
import 'package:codeschool_mobile/shared/models/lesson.dart';
import 'package:codeschool_mobile/shared/models/progress.dart';
import 'package:codeschool_mobile/shared/models/user.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

class MockLessonRepository extends Mock implements LessonRepository {}

class MockAssignmentRepository extends Mock implements AssignmentRepository {}

class MockQuizRepository extends Mock implements QuizRepository {}

class MockCertificateRepository extends Mock implements CertificateRepository {}

class _FakeStudentAuthController extends AuthController {
  @override
  Future<AppUser?> build() async => const AppUser(id: 1, firstName: 'Аружан', role: AppRole.student, isActive: true);
}

final _content = CourseContent(
  course: const Course(id: 304, levelId: 106, title: 'Python с нуля', slug: 'python-demo-course', audience: 'student'),
  modules: [
    CourseModule(
      id: 220,
      courseId: 304,
      title: 'Основы Python',
      position: 1,
      lessons: [
        const Lesson(id: 293, moduleId: 220, title: 'Что такое программа', lessonType: 'text', position: 1),
        const Lesson(id: 294, moduleId: 220, title: 'Команда print()', lessonType: 'text', position: 2),
      ],
    ),
  ],
);

Future<void> _pumpScreen(
  WidgetTester tester, {
  required MockCatalogRepository catalogRepo,
  required MockLessonRepository lessonRepo,
  required MockCertificateRepository certificateRepo,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final router = GoRouter(
    initialLocation: AppRoutes.courseProgressPath(304),
    routes: [
      GoRoute(
        path: AppRoutes.courseProgress,
        builder: (context, state) => CourseProgressScreen(courseId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(path: AppRoutes.lessonDetail, builder: (context, state) => const Scaffold(body: Text('lesson screen'))),
      GoRoute(path: AppRoutes.certificateDetail, builder: (context, state) => const Scaffold(body: Text('certificate screen'))),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        catalogRepositoryProvider.overrideWithValue(catalogRepo),
        lessonRepositoryProvider.overrideWithValue(lessonRepo),
        assignmentRepositoryProvider.overrideWithValue(MockAssignmentRepository()),
        quizRepositoryProvider.overrideWithValue(MockQuizRepository()),
        certificateRepositoryProvider.overrideWithValue(certificateRepo),
        authControllerProvider.overrideWith(() => _FakeStudentAuthController()),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

void main() {
  group('CourseProgressScreen', () {
    testWidgets('shows overall + per-module progress and a continue button for an in-progress course', (tester) async {
      final catalogRepo = MockCatalogRepository();
      final lessonRepo = MockLessonRepository();
      final certificateRepo = MockCertificateRepository();
      when(() => catalogRepo.getContent(304)).thenAnswer((_) async => ApiResult.ok(_content));
      when(() => catalogRepo.getCourseProgress(304)).thenAnswer(
        (_) async => ApiResult.ok(
          const CourseProgressDetail(
            courseId: 304,
            title: 'Python с нуля',
            completedLessons: 1,
            totalLessons: 2,
            progressPercent: 50,
            enrollmentStatus: 'active',
            lessons: [
              LessonProgress(lessonId: 293, status: 'completed', progressPercent: 100),
              LessonProgress(lessonId: 294, status: 'not_started', progressPercent: 0),
            ],
          ),
        ),
      );
      when(() => lessonRepo.listAssignments(293)).thenAnswer((_) async => ApiResult.ok([]));

      await _pumpScreen(tester, catalogRepo: catalogRepo, lessonRepo: lessonRepo, certificateRepo: certificateRepo);
      await tester.pumpAndSettle();

      expect(find.text('Python с нуля'), findsOneWidget);
      expect(find.textContaining('Уроков пройдено: 1/2'), findsOneWidget);
      expect(find.text('1. Основы Python'), findsOneWidget);
      expect(find.textContaining('Продолжить обучение'), findsOneWidget);

      await tester.tap(find.textContaining('Продолжить обучение'));
      await tester.pumpAndSettle();
      expect(find.text('lesson screen'), findsOneWidget);
    });

    testWidgets('shows the certificate CTA once the course is completed', (tester) async {
      final catalogRepo = MockCatalogRepository();
      final lessonRepo = MockLessonRepository();
      final certificateRepo = MockCertificateRepository();
      when(() => catalogRepo.getContent(304)).thenAnswer((_) async => ApiResult.ok(_content));
      when(() => catalogRepo.getCourseProgress(304)).thenAnswer(
        (_) async => ApiResult.ok(
          const CourseProgressDetail(
            courseId: 304,
            title: 'Python с нуля',
            completedLessons: 2,
            totalLessons: 2,
            progressPercent: 100,
            enrollmentStatus: 'completed',
            lessons: [
              LessonProgress(lessonId: 293, status: 'completed', progressPercent: 100),
              LessonProgress(lessonId: 294, status: 'completed', progressPercent: 100),
            ],
          ),
        ),
      );
      when(() => lessonRepo.listAssignments(any())).thenAnswer((_) async => ApiResult.ok([]));
      when(() => certificateRepo.listMine()).thenAnswer((_) async => ApiResult.ok([]));

      await _pumpScreen(tester, catalogRepo: catalogRepo, lessonRepo: lessonRepo, certificateRepo: certificateRepo);
      await tester.pumpAndSettle();

      expect(find.text('Курс завершён'), findsOneWidget);
      expect(find.text('Получить сертификат'), findsOneWidget);
    });

    testWidgets('shows "not enrolled" empty state (not an error banner) for the real 403 ErrNotEnrolled', (tester) async {
      final catalogRepo = MockCatalogRepository();
      final lessonRepo = MockLessonRepository();
      final certificateRepo = MockCertificateRepository();
      // courseProgressProvider (catalog feature, Stage 35D) maps a 403 to
      // `null` — "not enrolled" is a real, expected state, not an error.
      when(() => catalogRepo.getCourseProgress(304)).thenAnswer(
        (_) async => ApiResult.err(const ApiException(statusCode: 403, code: 'FORBIDDEN', message: 'Enroll in this course first')),
      );

      await _pumpScreen(tester, catalogRepo: catalogRepo, lessonRepo: lessonRepo, certificateRepo: certificateRepo);
      await tester.pumpAndSettle();

      expect(find.text('Запишитесь на курс, чтобы увидеть прогресс'), findsOneWidget);
    });
  });
}
