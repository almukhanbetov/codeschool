import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/core/network/api_exception.dart';
import 'package:codeschool_mobile/core/providers/core_providers.dart';
import 'package:codeschool_mobile/features/auth/application/auth_controller.dart';
import 'package:codeschool_mobile/features/catalog/application/catalog_providers.dart';
import 'package:codeschool_mobile/features/catalog/data/catalog_repository.dart';
import 'package:codeschool_mobile/features/certificates/application/certificate_providers.dart';
import 'package:codeschool_mobile/features/certificates/data/certificate_repository.dart';
import 'package:codeschool_mobile/features/home/presentation/student_home_screen.dart';
import 'package:codeschool_mobile/features/progress/application/progress_providers.dart';
import 'package:codeschool_mobile/features/progress/data/progress_repository.dart';
import 'package:codeschool_mobile/shared/models/app_role.dart';
import 'package:codeschool_mobile/shared/models/certificate.dart';
import 'package:codeschool_mobile/shared/models/enrollment.dart';
import 'package:codeschool_mobile/shared/models/progress.dart';
import 'package:codeschool_mobile/shared/models/user.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

class MockProgressRepository extends Mock implements ProgressRepository {}

class MockCertificateRepository extends Mock implements CertificateRepository {}

class _FakeStudentAuthController extends AuthController {
  @override
  Future<AppUser?> build() async => const AppUser(id: 1, firstName: 'Аружан', role: AppRole.student, isActive: true);
}

const _student = AppUser(id: 1, firstName: 'Аружан', role: AppRole.student, isActive: true);

Future<void> _pump(
  WidgetTester tester, {
  required MockCatalogRepository catalogRepo,
  required MockProgressRepository progressRepo,
  required MockCertificateRepository certificateRepo,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        catalogRepositoryProvider.overrideWithValue(catalogRepo),
        progressRepositoryProvider.overrideWithValue(progressRepo),
        certificateRepositoryProvider.overrideWithValue(certificateRepo),
        authControllerProvider.overrideWith(() => _FakeStudentAuthController()),
      ],
      child: MaterialApp(home: Scaffold(body: StudentHomeScreen(user: _student))),
    ),
  );
}

void main() {
  group('StudentHomeScreen', () {
    testWidgets('shows the empty state with a browse-catalog button when not enrolled anywhere', (tester) async {
      final catalogRepo = MockCatalogRepository();
      final progressRepo = MockProgressRepository();
      final certificateRepo = MockCertificateRepository();
      when(() => catalogRepo.listMyCourses()).thenAnswer((_) async => ApiResult.ok(const []));
      when(() => progressRepo.listMyProgress()).thenAnswer((_) async => ApiResult.ok(const []));
      when(() => certificateRepo.listMine()).thenAnswer((_) async => ApiResult.ok(const []));

      await _pump(tester, catalogRepo: catalogRepo, progressRepo: progressRepo, certificateRepo: certificateRepo);
      await tester.pumpAndSettle();

      expect(find.text('Вы ещё не записаны ни на один курс'), findsOneWidget);
      expect(find.text('Открыть каталог'), findsOneWidget);
    });

    testWidgets('shows real course cards with real percent from GET /me/progress', (tester) async {
      final catalogRepo = MockCatalogRepository();
      final progressRepo = MockProgressRepository();
      final certificateRepo = MockCertificateRepository();
      when(() => catalogRepo.listMyCourses()).thenAnswer(
        (_) async => ApiResult.ok([
          MyCourseItem(
            enrollmentId: 191,
            status: 'active',
            enrolledAt: DateTime.utc(2026, 1, 1),
            course: const CourseBrief(id: 304, title: 'Python с нуля', slug: 'python-demo-course', durationLessons: 9),
          ),
        ]),
      );
      when(() => progressRepo.listMyProgress()).thenAnswer(
        (_) async => ApiResult.ok(const [
          CourseProgress(courseId: 304, title: 'Python с нуля', completedLessons: 3, totalLessons: 9, progressPercent: 33),
        ]),
      );
      when(() => certificateRepo.listMine()).thenAnswer((_) async => ApiResult.ok(const []));
      when(() => catalogRepo.getContent(304)).thenAnswer((_) async => ApiResult.err(ApiException.network()));
      when(() => catalogRepo.getCourseProgress(304)).thenAnswer((_) async => ApiResult.err(ApiException.network()));

      await _pump(tester, catalogRepo: catalogRepo, progressRepo: progressRepo, certificateRepo: certificateRepo);
      await tester.pumpAndSettle();

      expect(find.text('Python с нуля'), findsOneWidget);
      expect(find.textContaining('33%'), findsOneWidget);
    });

    testWidgets('shows real certificates with a "view all" link', (tester) async {
      final catalogRepo = MockCatalogRepository();
      final progressRepo = MockProgressRepository();
      final certificateRepo = MockCertificateRepository();
      when(() => catalogRepo.listMyCourses()).thenAnswer((_) async => ApiResult.ok(const []));
      when(() => progressRepo.listMyProgress()).thenAnswer((_) async => ApiResult.ok(const []));
      when(() => certificateRepo.listMine()).thenAnswer(
        (_) async => ApiResult.ok([
          Certificate(
            id: 25,
            certificateNumber: 'CS-2026-000003-CHZ3',
            verificationCode: 'C1E2-19XE-0DBP-0XB4',
            course: const CertificateCourseRef(id: 304, title: 'Python с нуля'),
            learnerName: 'E2EQA',
            issuedAt: DateTime.utc(2026, 9, 17),
            completedAt: DateTime.utc(2026, 9, 17),
            status: 'active',
            verifyUrl: 'https://codeschool.kz/certificates/verify/C1E2',
          ),
        ]),
      );

      await _pump(tester, catalogRepo: catalogRepo, progressRepo: progressRepo, certificateRepo: certificateRepo);
      await tester.pumpAndSettle();

      expect(find.text('CS-2026-000003-CHZ3'), findsOneWidget);
      expect(find.text('Все сертификаты'), findsOneWidget);
    });
  });
}
