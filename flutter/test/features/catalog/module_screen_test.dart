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
import 'package:codeschool_mobile/features/catalog/application/catalog_providers.dart';
import 'package:codeschool_mobile/features/catalog/data/catalog_repository.dart';
import 'package:codeschool_mobile/features/catalog/presentation/module_screen.dart';
import 'package:codeschool_mobile/shared/models/course.dart';
import 'package:codeschool_mobile/shared/models/course_content.dart';
import 'package:codeschool_mobile/shared/models/lesson.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

final _content = CourseContent(
  course: const Course(id: 353, levelId: 134, title: 'Год 1', slug: 'codeschool-year1-logic', audience: 'student'),
  modules: [
    CourseModule(
      id: 261,
      courseId: 353,
      title: 'Компьютер и алгоритмы',
      position: 1,
      lessons: List.generate(
        8,
        (j) => Lesson(
          id: 350 + j,
          moduleId: 261,
          title: 'Урок ${j + 1}',
          description: 'Описание урока ${j + 1}',
          lessonType: j == 0 ? 'video' : 'text',
          position: j + 1,
        ),
      ),
    ),
    CourseModule(id: 262, courseId: 353, title: 'Основы логики', position: 2, lessons: const []),
  ],
);

Future<void> _pumpModule(WidgetTester tester, MockCatalogRepository repo) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final router = GoRouter(
    initialLocation: AppRoutes.moduleDetailPath(353, 261),
    routes: [
      GoRoute(
        path: AppRoutes.moduleDetail,
        builder: (context, state) => ModuleScreen(
          courseId: int.parse(state.pathParameters['courseId']!),
          moduleId: int.parse(state.pathParameters['moduleId']!),
        ),
      ),
      GoRoute(
        // A lightweight stand-in for the real LessonDetailScreen, which now
        // needs auth/assignments/progress providers of its own (covered by
        // lesson_detail_screen_test.dart) — this file only needs to prove
        // ModuleScreen navigates with the right path params.
        path: AppRoutes.lessonDetail,
        builder: (context, state) => Scaffold(
          body: Text(
            'lesson ${state.pathParameters['lessonId']} in module ${state.pathParameters['moduleId']} of course ${state.pathParameters['courseId']}',
          ),
        ),
      ),
    ],
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
}

void main() {
  group('ModuleScreen', () {
    testWidgets('shows the module title and its 8 lessons in position order', (tester) async {
      final repo = MockCatalogRepository();
      when(() => repo.getContent(353)).thenAnswer((_) async => ApiResult.ok(_content));

      await _pumpModule(tester, repo);
      await tester.pumpAndSettle();

      expect(find.text('1. Компьютер и алгоритмы'), findsOneWidget);
      expect(find.textContaining('1. Урок 1'), findsOneWidget);

      // The list only builds visible items lazily — scroll to the last
      // lesson to confirm all 8 actually made it into the widget tree.
      await tester.dragUntilVisible(
        find.textContaining('8. Урок 8'),
        find.byType(Scrollable).first,
        const Offset(0, -250),
      );
      expect(find.textContaining('8. Урок 8'), findsOneWidget);
    });

    testWidgets('shows the empty state for a module with no lessons', (tester) async {
      final repo = MockCatalogRepository();
      when(() => repo.getContent(353)).thenAnswer((_) async => ApiResult.ok(_content));

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final router = GoRouter(
        initialLocation: AppRoutes.moduleDetailPath(353, 262),
        routes: [
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
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2. Основы логики'), findsOneWidget);
      expect(find.text('Здесь пока пусто'), findsOneWidget);
    });

    testWidgets('shows the error state on a failed course content fetch', (tester) async {
      final repo = MockCatalogRepository();
      when(() => repo.getContent(353)).thenAnswer((_) async => ApiResult.err(ApiException.network()));

      await _pumpModule(tester, repo);
      await tester.pumpAndSettle();

      expect(find.text('Нет соединения с сервером'), findsOneWidget);
    });

    testWidgets('tapping a lesson navigates to its lesson/module/course route params', (tester) async {
      final repo = MockCatalogRepository();
      when(() => repo.getContent(353)).thenAnswer((_) async => ApiResult.ok(_content));

      await _pumpModule(tester, repo);
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('1. Урок 1'));
      await tester.pumpAndSettle();

      expect(find.text('lesson 350 in module 261 of course 353'), findsOneWidget);
    });
  });
}
