import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/core/network/api_exception.dart';
import 'package:codeschool_mobile/core/providers/core_providers.dart';
import 'package:codeschool_mobile/features/certificates/application/certificate_providers.dart';
import 'package:codeschool_mobile/features/certificates/data/certificate_repository.dart';
import 'package:codeschool_mobile/features/certificates/presentation/certificate_detail_screen.dart';
import 'package:codeschool_mobile/shared/models/certificate.dart';

class MockCertificateRepository extends Mock implements CertificateRepository {}

/// This screen's actual PDF download is already covered at the repository
/// level (`certificate_repository_test.dart`'s `downloadPdf` tests, real
/// bytes + real 404 access-denied case) — opening the saved file with the
/// system viewer and the Share Sheet are thin OS plugin calls
/// (`open_filex`/`share_plus`) that need a real device to mean anything, the
/// same scoping already used for platform-plugin-heavy paths in Stage 35E.
/// This file covers what a widget test *can* honestly verify: real
/// certificate data rendering, the revoked-status badge, and the real
/// access-denied (404) error path.
Future<void> _pumpDetail(WidgetTester tester, MockCertificateRepository repo, int id) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        certificateRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(home: CertificateDetailScreen(certificateId: id)),
    ),
  );
}

void main() {
  group('CertificateDetailScreen', () {
    testWidgets('renders the real certificate fields', (tester) async {
      final repo = MockCertificateRepository();
      when(() => repo.getMine(25)).thenAnswer(
        (_) async => ApiResult.ok(
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
        ),
      );

      await _pumpDetail(tester, repo, 25);
      await tester.pumpAndSettle();

      expect(find.text('Python с нуля'), findsOneWidget);
      expect(find.text('E2EQA'), findsOneWidget);
      expect(find.text('CS-2026-000003-CHZ3'), findsOneWidget);
      expect(find.text('C1E2-19XE-0DBP-0XB4'), findsOneWidget);
      expect(find.text('Сертификат отозван'), findsNothing);
    });

    testWidgets('shows the revoked badge for a revoked certificate', (tester) async {
      final repo = MockCertificateRepository();
      when(() => repo.getMine(26)).thenAnswer(
        (_) async => ApiResult.ok(
          Certificate(
            id: 26,
            certificateNumber: 'CS-2026-000004-ABCD',
            verificationCode: 'C1E2-XXXX-0000-1111',
            course: const CertificateCourseRef(id: 304, title: 'Python с нуля'),
            learnerName: 'E2EQA',
            issuedAt: DateTime.utc(2026, 9, 17),
            completedAt: DateTime.utc(2026, 9, 17),
            status: 'revoked',
            verifyUrl: 'https://codeschool.kz/certificates/verify/C1E2',
          ),
        ),
      );

      await _pumpDetail(tester, repo, 26);
      await tester.pumpAndSettle();

      expect(find.text('Сертификат отозван'), findsOneWidget);
    });

    testWidgets('shows the real 404 for a certificate that belongs to someone else', (tester) async {
      final repo = MockCertificateRepository();
      when(() => repo.getMine(99)).thenAnswer(
        (_) async => ApiResult.err(const ApiException(statusCode: 404, code: 'NOT_FOUND', message: 'Certificate not found')),
      );

      await _pumpDetail(tester, repo, 99);
      await tester.pumpAndSettle();

      expect(find.text('Не найдено'), findsOneWidget);
    });
  });
}
