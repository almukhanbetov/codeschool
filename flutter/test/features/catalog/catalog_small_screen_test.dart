import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/core/providers/core_providers.dart';
import 'package:codeschool_mobile/features/auth/application/auth_controller.dart';
import 'package:codeschool_mobile/features/catalog/application/catalog_providers.dart';
import 'package:codeschool_mobile/features/catalog/data/catalog_repository.dart';
import 'package:codeschool_mobile/features/catalog/presentation/catalog_screen.dart';
import 'package:codeschool_mobile/features/catalog/presentation/course_detail_screen.dart';
import 'package:codeschool_mobile/shared/models/course.dart';
import 'package:codeschool_mobile/shared/models/course_content.dart';
import 'package:codeschool_mobile/shared/models/lesson.dart';
import 'package:codeschool_mobile/shared/models/user.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

class _FakeUnauthController extends AuthController {
  @override
  Future<AppUser?> build() async => null;
}

/// No real Android device/emulator is available in this environment
/// (confirmed via `adb devices` — empty list), so small-screen behavior is
/// verified honestly at the smallest common Android width (Galaxy
/// A-series-class devices, 360x640 logical px) via Flutter's test surface
/// size rather than claimed on a device that was never actually run.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CatalogScreen renders a full card list at 360x640 without overflow', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = const Size(720, 1280); // 360x640 logical at 2.0 dpr
    tester.view.devicePixelRatio = 2.0;
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = MockCatalogRepository();
    when(() => repo.listCourses(ageFrom: null, ageTo: null, levelId: null)).thenAnswer(
      (_) async => ApiResult.ok([
        const Course(
          id: 353,
          levelId: 134,
          title: 'Год 1: Визуальная логика и алгоритмическое мышление',
          slug: 'codeschool-year1-logic',
          shortDescription: 'Год 1: с чего начинается программирование — без кода, но по-настоящему.',
          ageFrom: 6,
          ageTo: 8,
          durationLessons: 72,
          projectsCount: 1,
          audience: 'student',
        ),
      ]),
    );

    final router = GoRouter(
      initialLocation: '/',
      routes: [GoRoute(path: '/', builder: (context, state) => const CatalogScreen())],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          catalogRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Год 1: Визуальная логика и алгоритмическое мышление'), findsOneWidget);
  });

  testWidgets('CourseDetailScreen renders modules/lessons at 360x640 without overflow', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = const Size(720, 1280); // 360x640 logical at 2.0 dpr
    tester.view.devicePixelRatio = 2.0;
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = MockCatalogRepository();
    final content = CourseContent(
      course: const Course(
        id: 353,
        levelId: 134,
        title: 'Год 1: Визуальная логика и алгоритмическое мышление',
        slug: 'codeschool-year1-logic',
        description: '36 недель, 72 занятия, 9 модулей: команды и алгоритмы, логика, циклы.',
        ageFrom: 6,
        ageTo: 8,
        durationLessons: 72,
        projectsCount: 1,
        audience: 'student',
      ),
      modules: List.generate(
        9,
        (i) => CourseModule(
          id: i + 1,
          courseId: 353,
          title: 'Модуль ${i + 1}: длинное название модуля для проверки переноса текста',
          position: i + 1,
          lessons: List.generate(
            8,
            (j) => Lesson(id: i * 8 + j + 1, moduleId: i + 1, title: 'Урок ${j + 1}', lessonType: 'text', position: j + 1),
          ),
        ),
      ),
    );
    when(() => repo.getContent(353)).thenAnswer((_) async => ApiResult.ok(content));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          catalogRepositoryProvider.overrideWithValue(repo),
          authControllerProvider.overrideWith(() => _FakeUnauthController()),
        ],
        child: const MaterialApp(home: CourseDetailScreen(courseId: 353)),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    // Scroll the whole way to the last module — proves the long 9-module
    // list is fully scrollable without a render overflow at this width,
    // which is the actual risk on a small phone (long titles, badges wrap).
    await tester.dragUntilVisible(
      find.textContaining('Модуль 9'),
      find.byType(Scrollable).first,
      const Offset(0, -250),
    );
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Модуль 9'), findsWidgets);
  });
}
