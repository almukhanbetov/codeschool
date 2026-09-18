import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/core/providers/core_providers.dart';
import 'package:codeschool_mobile/features/auth/application/auth_controller.dart';
import 'package:codeschool_mobile/features/catalog/application/catalog_providers.dart';
import 'package:codeschool_mobile/features/catalog/data/catalog_repository.dart';
import 'package:codeschool_mobile/features/home/presentation/public_home_screen.dart';
import 'package:codeschool_mobile/shared/models/course.dart';
import 'package:codeschool_mobile/shared/models/user.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

class _FakeGuestAuthController extends AuthController {
  @override
  Future<AppUser?> build() async => null;
}

Future<void> _pump(WidgetTester tester, MockCatalogRepository repo) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  // The page is taller than the default 600px test viewport (hero + 4
  // sections) — a lazy ListView only builds what's near the viewport, so
  // without this, sections past the fold (e.g. "Преимущества платформы")
  // never get an Element and can't be found by `find.text`.
  tester.view.physicalSize = const Size(800, 3200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        catalogRepositoryProvider.overrideWithValue(repo),
        authControllerProvider.overrideWith(() => _FakeGuestAuthController()),
      ],
      child: const MaterialApp(home: PublicHomeScreen()),
    ),
  );
}

void main() {
  group('PublicHomeScreen', () {
    testWidgets('shows the hero, category, advantages and audience sections for a guest', (tester) async {
      final repo = MockCatalogRepository();
      when(() => repo.listCourses(ageFrom: null, ageTo: null, levelId: null)).thenAnswer((_) async => ApiResult.ok(const []));

      await _pump(tester, repo);
      await tester.pumpAndSettle();

      expect(find.text('CodeSchool.kz'), findsOneWidget);
      expect(find.textContaining('Начать обучение'), findsWidgets);
      expect(find.text('Посмотреть курсы'), findsOneWidget);
      expect(find.text('Направления обучения'), findsOneWidget);
      expect(find.text('Программирование'), findsOneWidget);
      expect(find.text('Робототехника'), findsOneWidget);
      expect(find.text('Искусственный интеллект'), findsOneWidget);
      expect(find.text('Преимущества платформы'), findsOneWidget);
      expect(find.text('Кому подойдёт CodeSchool'), findsOneWidget);
      expect(find.text('Ученикам'), findsOneWidget);
      expect(find.text('Родителям'), findsOneWidget);
      expect(find.text('Преподавателям'), findsOneWidget);
      // Bottom nav (brief §2 "Нижнюю навигацию").
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('shows real courses from GET /courses, not a fabricated list', (tester) async {
      final repo = MockCatalogRepository();
      when(() => repo.listCourses(ageFrom: null, ageTo: null, levelId: null)).thenAnswer(
        (_) async => ApiResult.ok(const [
          Course(id: 304, levelId: 1, title: 'Python с нуля', slug: 'python', ageFrom: 9, ageTo: 14, durationLessons: 20, audience: 'student'),
        ]),
      );

      await _pump(tester, repo);
      await tester.pumpAndSettle();

      expect(find.text('Python с нуля'), findsOneWidget);
      expect(find.textContaining('9–14'), findsOneWidget);
    });

    testWidgets('shows the empty-programs message when the backend has no courses, never invented ones', (tester) async {
      final repo = MockCatalogRepository();
      when(() => repo.listCourses(ageFrom: null, ageTo: null, levelId: null)).thenAnswer((_) async => ApiResult.ok(const []));

      await _pump(tester, repo);
      await tester.pumpAndSettle();

      expect(find.text('Курсы временно недоступны'), findsOneWidget);
    });
  });
}
