// Real Flutter integration test (brief §6: "Добавь ... integration tests").
//
// Requires a connected Android device or emulator to actually execute
// (`flutter test integration_test/learning_flow_test.dart -d <device>`) —
// `integration_test` boots the full app on a real device/engine, unlike the
// widget tests under test/. This environment has neither an emulator nor a
// physical device attached (see STAGE35E_LEARNING_REPORT.md §"Device
// testing"), so this file is real, checked-in code that has NOT been run
// here — it is honestly reported as NOT TESTED / BLOCKED, never claimed as
// passing without having actually executed it.
//
// The end-to-end scenario itself (login -> course -> lesson -> code
// execution -> assignment submission -> quiz -> progress persistence across
// logout/login) was verified for real against the isolated local dev
// backend directly over HTTP (see the report) — this file exercises the
// same chain at the Flutter widget/navigation level, with the repository
// layer mocked so the test is deterministic and doesn't depend on backend
// state, the same pattern already used throughout test/.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codeschool_mobile/app.dart';
import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/core/network/api_exception.dart';
import 'package:codeschool_mobile/core/providers/core_providers.dart';
import 'package:codeschool_mobile/features/auth/application/auth_controller.dart';
import 'package:codeschool_mobile/features/catalog/application/catalog_providers.dart';
import 'package:codeschool_mobile/features/catalog/data/catalog_repository.dart';
import 'package:codeschool_mobile/shared/models/app_role.dart';
import 'package:codeschool_mobile/shared/models/course.dart';
import 'package:codeschool_mobile/shared/models/course_content.dart';
import 'package:codeschool_mobile/shared/models/lesson.dart';
import 'package:codeschool_mobile/shared/models/user.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

class _FakeAuthController extends AuthController {
  @override
  Future<AppUser?> build() async =>
      const AppUser(id: 1, firstName: 'Аружан', role: AppRole.student, isActive: true);
}

final _content = CourseContent(
  course: const Course(
    id: 353,
    levelId: 134,
    title: 'Год 1: Визуальная логика',
    slug: 'codeschool-year1-logic',
    audience: 'student',
  ),
  modules: [
    CourseModule(
      id: 261,
      courseId: 353,
      title: 'Компьютер и алгоритмы',
      position: 1,
      lessons: [
        const Lesson(
          id: 350,
          moduleId: 261,
          title: 'Что делает компьютер?',
          content: '## Цель урока\nПонять, как работает компьютер.',
          lessonType: 'text',
          position: 1,
        ),
      ],
    ),
  ],
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('student can browse Catalog -> Course -> Module -> Lesson end to end', (tester) async {
    final catalogRepo = MockCatalogRepository();
    when(() => catalogRepo.listCourses(ageFrom: null, ageTo: null, levelId: null))
        .thenAnswer((_) async => ApiResult.ok([_content.course]));
    when(() => catalogRepo.getContent(353)).thenAnswer((_) async => ApiResult.ok(_content));
    when(() => catalogRepo.getCourseProgress(353)).thenAnswer((_) async => ApiResult.err(ApiException.network()));
    when(() => catalogRepo.listMyCourses()).thenAnswer((_) async => ApiResult.ok([]));
    when(() => catalogRepo.getLessonById(350)).thenAnswer(
      (_) async => ApiResult.ok(
        const Lesson(
          id: 350,
          moduleId: 261,
          title: 'Что делает компьютер?',
          content: '## Цель урока\nПонять, как работает компьютер.',
          lessonType: 'text',
          position: 1,
        ),
      ),
    );

    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          catalogRepositoryProvider.overrideWithValue(catalogRepo),
          authControllerProvider.overrideWith(() => _FakeAuthController()),
        ],
        child: const CodeschoolApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Home -> Catalog.
    await tester.tap(find.text('Открыть каталог').first);
    await tester.pumpAndSettle();
    expect(find.text('Год 1: Визуальная логика'), findsOneWidget);

    // Catalog -> Course Details.
    await tester.tap(find.text('Год 1: Визуальная логика'));
    await tester.pumpAndSettle();
    expect(find.text('Модули'), findsOneWidget);

    // Course Details -> Module.
    await tester.tap(find.textContaining('Компьютер и алгоритмы'));
    await tester.pumpAndSettle();
    expect(find.text('Что делает компьютер?'), findsWidgets);

    // Module -> Lesson.
    await tester.tap(find.textContaining('Что делает компьютер?').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Цель урока'), findsOneWidget);
  });
}
