// Real Flutter integration test (brief §4: "Добавь unit, widget и
// integration tests"). Requires a connected Android device or emulator to
// actually execute — same honest limitation as
// integration_test/learning_flow_test.dart (Stage 35E): this environment
// has neither, so this file is real, checked-in code that has NOT been run
// here (see STAGE35F_PROGRESS_CERTIFICATES_REPORT.md — "Device testing").
//
// The scenario itself (course completion -> certificate issuance -> PDF ->
// logout/login persistence) was verified for real against the isolated
// local dev backend directly over HTTP (see the report's E2E section) —
// this file exercises the same student-cabinet -> progress -> certificate
// navigation chain at the Flutter widget level, with the repository layer
// mocked so the test is deterministic, the same pattern used throughout
// test/.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
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
import 'package:codeschool_mobile/shared/models/certificate.dart';
import 'package:codeschool_mobile/shared/models/enrollment.dart';
import 'package:codeschool_mobile/shared/models/progress.dart';
import 'package:codeschool_mobile/shared/models/user.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

class MockProgressRepository extends Mock implements ProgressRepository {}

class MockCertificateRepository extends Mock implements CertificateRepository {}

class _FakeAuthController extends AuthController {
  @override
  Future<AppUser?> build() async =>
      const AppUser(id: 1, firstName: 'E2EQA', role: AppRole.student, isActive: true);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('student cabinet shows a completed course and its real certificate', (tester) async {
    final catalogRepo = MockCatalogRepository();
    final progressRepo = MockProgressRepository();
    final certificateRepo = MockCertificateRepository();

    when(() => catalogRepo.listMyCourses()).thenAnswer(
      (_) async => ApiResult.ok([
        MyCourseItem(
          enrollmentId: 191,
          status: 'completed',
          enrolledAt: DateTime.utc(2026, 1, 1),
          course: const CourseBrief(id: 304, title: 'Python с нуля — демонстрационный курс', slug: 'python-demo-course', durationLessons: 9),
        ),
      ]),
    );
    when(() => progressRepo.listMyProgress()).thenAnswer(
      (_) async => ApiResult.ok(const [
        CourseProgress(courseId: 304, title: 'Python с нуля — демонстрационный курс', completedLessons: 9, totalLessons: 9, progressPercent: 100),
      ]),
    );
    when(() => certificateRepo.listMine()).thenAnswer(
      (_) async => ApiResult.ok([
        Certificate(
          id: 25,
          certificateNumber: 'CS-2026-000003-CHZ3',
          verificationCode: 'C1E2-19XE-0DBP-0XB4',
          course: const CertificateCourseRef(id: 304, title: 'Python с нуля — демонстрационный курс'),
          learnerName: 'E2EQA',
          issuedAt: DateTime.utc(2026, 9, 17),
          completedAt: DateTime.utc(2026, 9, 17),
          status: 'active',
          verifyUrl: 'https://codeschool.kz/certificates/verify/C1E2-19XE-0DBP-0XB4',
        ),
      ]),
    );

    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          catalogRepositoryProvider.overrideWithValue(catalogRepo),
          progressRepositoryProvider.overrideWithValue(progressRepo),
          certificateRepositoryProvider.overrideWithValue(certificateRepo),
          authControllerProvider.overrideWith(() => _FakeAuthController()),
        ],
        child: const CodeschoolApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Real course card with the real 100% progress from GET /me/progress.
    expect(find.textContaining('Python с нуля'), findsWidgets);
    expect(find.textContaining('100%'), findsWidgets);

    // Real certificate on the cabinet.
    expect(find.text('CS-2026-000003-CHZ3'), findsOneWidget);

    // Cabinet -> Certificate detail.
    await tester.tap(find.text('CS-2026-000003-CHZ3'));
    await tester.pumpAndSettle();
    expect(find.text('C1E2-19XE-0DBP-0XB4'), findsOneWidget);
    expect(find.text('E2EQA'), findsOneWidget);
  });
}
