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
import 'package:codeschool_mobile/features/certificates/application/certificate_providers.dart';
import 'package:codeschool_mobile/features/certificates/data/certificate_repository.dart';
import 'package:codeschool_mobile/features/certificates/presentation/certificate_list_screen.dart';
import 'package:codeschool_mobile/shared/models/certificate.dart';

class MockCertificateRepository extends Mock implements CertificateRepository {}

Future<void> _pumpList(WidgetTester tester, MockCertificateRepository repo) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final router = GoRouter(
    initialLocation: AppRoutes.certificates,
    routes: [
      GoRoute(path: AppRoutes.certificates, builder: (context, state) => const CertificateListScreen()),
      GoRoute(path: AppRoutes.certificateDetail, builder: (context, state) => const Scaffold(body: Text('detail screen'))),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        certificateRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

void main() {
  group('CertificateListScreen', () {
    testWidgets('shows the empty state when the student has no certificates', (tester) async {
      final repo = MockCertificateRepository();
      when(() => repo.listMine()).thenAnswer((_) async => ApiResult.ok(const []));

      await _pumpList(tester, repo);
      await tester.pumpAndSettle();

      expect(find.text('Пока нет сертификатов'), findsOneWidget);
    });

    testWidgets('lists real certificates and navigates to the detail screen on tap', (tester) async {
      final repo = MockCertificateRepository();
      final cert = Certificate(
        id: 25,
        certificateNumber: 'CS-2026-000003-CHZ3',
        verificationCode: 'C1E2-19XE-0DBP-0XB4',
        course: const CertificateCourseRef(id: 304, title: 'Python с нуля'),
        learnerName: 'E2EQA',
        issuedAt: DateTime.utc(2026, 9, 17),
        completedAt: DateTime.utc(2026, 9, 17),
        status: 'active',
        verifyUrl: 'https://codeschool.kz/certificates/verify/C1E2',
      );
      when(() => repo.listMine()).thenAnswer((_) async => ApiResult.ok([cert]));

      await _pumpList(tester, repo);
      await tester.pumpAndSettle();

      expect(find.text('Python с нуля'), findsOneWidget);
      expect(find.text('CS-2026-000003-CHZ3'), findsOneWidget);

      await tester.tap(find.text('Python с нуля'));
      await tester.pumpAndSettle();
      expect(find.text('detail screen'), findsOneWidget);
    });

    testWidgets('shows the error state with retry on a failed fetch', (tester) async {
      final repo = MockCertificateRepository();
      when(() => repo.listMine()).thenAnswer((_) async => ApiResult.err(ApiException.network()));

      await _pumpList(tester, repo);
      await tester.pumpAndSettle();

      expect(find.text('Нет соединения с сервером'), findsOneWidget);
      expect(find.text('Повторить'), findsOneWidget);
    });
  });
}
