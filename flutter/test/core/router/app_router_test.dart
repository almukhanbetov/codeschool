import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codeschool_mobile/app.dart';
import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/core/providers/core_providers.dart';
import 'package:codeschool_mobile/features/auth/application/auth_controller.dart';
import 'package:codeschool_mobile/features/catalog/application/catalog_providers.dart';
import 'package:codeschool_mobile/features/catalog/data/catalog_repository.dart';
import 'package:codeschool_mobile/features/certificates/application/certificate_providers.dart';
import 'package:codeschool_mobile/features/certificates/data/certificate_repository.dart';
import 'package:codeschool_mobile/features/progress/application/progress_providers.dart';
import 'package:codeschool_mobile/features/progress/data/progress_repository.dart';
import 'package:codeschool_mobile/shared/models/app_role.dart';
import 'package:codeschool_mobile/shared/models/user.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

class MockProgressRepository extends Mock implements ProgressRepository {}

class MockCertificateRepository extends Mock implements CertificateRepository {}

const _student = AppUser(id: 9, firstName: 'Тест', role: AppRole.student, isActive: true);

/// A controllable fake so a test can drive real login()/logout() calls the
/// same way the UI does (LoginScreen calls `.login(...)`, HomeScreen calls
/// `.logout()`) without hitting the network — the router reacts to `state`
/// exactly like it does with the real [AuthController].
class _FakeTogglingAuthController extends AuthController {
  _FakeTogglingAuthController(this._initial);
  final AppUser? _initial;

  @override
  Future<AppUser?> build() async => _initial;

  @override
  Future<ApiResult<AppUser>> login({String? email, String? phone, required String password}) async {
    state = const AsyncData(_student);
    return ApiResult.ok(_student);
  }

  @override
  Future<void> logout() async {
    state = const AsyncData(null);
  }
}

Future<void> _pump(
  WidgetTester tester, {
  required AppUser? initialUser,
  required MockCatalogRepository catalogRepo,
  MockProgressRepository? progressRepo,
  MockCertificateRepository? certificateRepo,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  // Public home + most protected screens render taller than the default
  // 600px test viewport.
  tester.view.physicalSize = const Size(800, 3200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        catalogRepositoryProvider.overrideWithValue(catalogRepo),
        if (progressRepo != null) progressRepositoryProvider.overrideWithValue(progressRepo),
        if (certificateRepo != null) certificateRepositoryProvider.overrideWithValue(certificateRepo),
        authControllerProvider.overrideWith(() => _FakeTogglingAuthController(initialUser)),
      ],
      child: const CodeschoolApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('App router — Stage 35H public home / navigation fix', () {
    testWidgets('a guest at boot lands on the public home, never forced to /login', (tester) async {
      final catalogRepo = MockCatalogRepository();
      when(() => catalogRepo.listCourses(ageFrom: null, ageTo: null, levelId: null)).thenAnswer((_) async => ApiResult.ok(const []));

      await _pump(tester, initialUser: null, catalogRepo: catalogRepo);

      // The real bug this stage fixes: the app used to redirect straight to
      // /login before a guest ever saw a home screen.
      expect(find.text('Вход'), findsNothing);
      expect(find.text('CodeSchool.kz'), findsOneWidget);
      expect(find.text('Посмотреть курсы'), findsOneWidget);
    });

    testWidgets('guest can open the public catalog without being redirected to login', (tester) async {
      final catalogRepo = MockCatalogRepository();
      when(() => catalogRepo.listCourses(ageFrom: null, ageTo: null, levelId: null)).thenAnswer((_) async => ApiResult.ok(const []));

      await _pump(tester, initialUser: null, catalogRepo: catalogRepo);

      await tester.tap(find.text('Посмотреть курсы'));
      await tester.pumpAndSettle();

      expect(find.text('Вход'), findsNothing);
      expect(find.text('Каталог курсов'), findsOneWidget);
    });

    testWidgets('an unauthenticated deep link to a protected route redirects to login, then returns there after signing in', (tester) async {
      final catalogRepo = MockCatalogRepository();
      final certificateRepo = MockCertificateRepository();
      when(() => catalogRepo.listCourses(ageFrom: null, ageTo: null, levelId: null)).thenAnswer((_) async => ApiResult.ok(const []));
      when(() => certificateRepo.listMine()).thenAnswer((_) async => ApiResult.ok(const []));

      await _pump(tester, initialUser: null, catalogRepo: catalogRepo, certificateRepo: certificateRepo);

      final context = tester.element(find.byType(Scaffold).first);
      GoRouter.of(context).go('/certificates');
      await tester.pumpAndSettle();

      // Protected route + no session -> bounced to login (brief §3/§4:
      // "Авторизацию запрашивай только для защищённых действий").
      expect(find.text('Вход'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'test@codeschool.local');
      await tester.enterText(find.byType(TextField).last, 'Password123!');
      await tester.tap(find.text('Войти').last);
      await tester.pumpAndSettle();

      // Signed in -> returned to the certificates screen it originally
      // asked for, not dumped on the generic home screen (brief §3: "После
      // успешного входа возвращай пользователя к запрошенному действию").
      expect(find.text('Сертификаты'), findsOneWidget);
    });

    testWidgets('logging out from the personal cabinet returns to the public home, not the login screen', (tester) async {
      final catalogRepo = MockCatalogRepository();
      final progressRepo = MockProgressRepository();
      final certificateRepo = MockCertificateRepository();
      when(() => catalogRepo.listMyCourses()).thenAnswer((_) async => ApiResult.ok(const []));
      when(() => progressRepo.listMyProgress()).thenAnswer((_) async => ApiResult.ok(const []));
      when(() => certificateRepo.listMine()).thenAnswer((_) async => ApiResult.ok(const []));

      await _pump(
        tester,
        initialUser: _student,
        catalogRepo: catalogRepo,
        progressRepo: progressRepo,
        certificateRepo: certificateRepo,
      );

      // Signed-in student home (Stage 35F) — the only place logout lives.
      expect(find.text('Здравствуйте, Тест'), findsOneWidget);

      await tester.tap(find.byTooltip('Выйти'));
      await tester.pumpAndSettle();

      expect(find.text('Вход'), findsNothing);
      expect(find.text('CodeSchool.kz'), findsOneWidget);
      expect(find.text('Посмотреть курсы'), findsOneWidget);
    });
  });
}
