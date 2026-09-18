import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/core/network/api_exception.dart';
import 'package:codeschool_mobile/core/providers/core_providers.dart';
import 'package:codeschool_mobile/features/catalog/application/catalog_providers.dart';
import 'package:codeschool_mobile/features/catalog/data/catalog_repository.dart';
import 'package:codeschool_mobile/features/catalog/presentation/catalog_screen.dart';
import 'package:codeschool_mobile/shared/models/course.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

Course _course(int id, String title) =>
    Course(id: id, levelId: 1, title: title, slug: 'course-$id', durationLessons: 8, audience: 'student');

Future<void> _pumpCatalog(WidgetTester tester, MockCatalogRepository repo) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const CatalogScreen()),
      GoRoute(path: '/catalog/course/:id', builder: (context, state) => const SizedBox.shrink()),
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
  setUpAll(() {
    registerFallbackValue(0);
  });

  group('CatalogScreen', () {
    testWidgets('shows a loading indicator while the courses fetch is in flight', (tester) async {
      final repo = MockCatalogRepository();
      final completer = Completer<ApiResult<List<Course>>>();
      when(() => repo.listCourses(ageFrom: null, ageTo: null, levelId: null)).thenAnswer((_) => completer.future);

      await _pumpCatalog(tester, repo);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      completer.complete(ApiResult.ok([]));
      await tester.pumpAndSettle();
    });

    testWidgets('renders a course card per returned course', (tester) async {
      final repo = MockCatalogRepository();
      when(() => repo.listCourses(ageFrom: null, ageTo: null, levelId: null)).thenAnswer(
        (_) async => ApiResult.ok([_course(1, 'Scratch Junior'), _course(2, 'Python для детей')]),
      );

      await _pumpCatalog(tester, repo);
      await tester.pumpAndSettle();

      expect(find.text('Scratch Junior'), findsOneWidget);
      expect(find.text('Python для детей'), findsOneWidget);
    });

    testWidgets('shows the empty state when the API returns no courses', (tester) async {
      final repo = MockCatalogRepository();
      when(() => repo.listCourses(ageFrom: null, ageTo: null, levelId: null))
          .thenAnswer((_) async => ApiResult.ok([]));

      await _pumpCatalog(tester, repo);
      await tester.pumpAndSettle();

      expect(find.text('По этому фильтру курсов не найдено'), findsOneWidget);
    });

    testWidgets('shows the error state with a retry button on API failure', (tester) async {
      final repo = MockCatalogRepository();
      when(() => repo.listCourses(ageFrom: null, ageTo: null, levelId: null))
          .thenAnswer((_) async => ApiResult.err(ApiException.network()));

      await _pumpCatalog(tester, repo);
      await tester.pumpAndSettle();

      expect(find.text('Нет соединения с сервером'), findsOneWidget);
      expect(find.text('Повторить'), findsOneWidget);
    });

    testWidgets('typing in the search field filters the visible list', (tester) async {
      final repo = MockCatalogRepository();
      when(() => repo.listCourses(ageFrom: null, ageTo: null, levelId: null)).thenAnswer(
        (_) async => ApiResult.ok([_course(1, 'Scratch Junior'), _course(2, 'Python для детей')]),
      );

      await _pumpCatalog(tester, repo);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'python');
      await tester.pumpAndSettle();

      expect(find.text('Python для детей'), findsOneWidget);
      expect(find.text('Scratch Junior'), findsNothing);
    });
  });
}
