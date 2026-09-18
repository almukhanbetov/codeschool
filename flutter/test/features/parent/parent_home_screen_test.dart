import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/core/providers/core_providers.dart';
import 'package:codeschool_mobile/features/auth/application/auth_controller.dart';
import 'package:codeschool_mobile/features/parent/application/parent_providers.dart';
import 'package:codeschool_mobile/features/parent/data/parent_repository.dart';
import 'package:codeschool_mobile/features/parent/presentation/parent_home_screen.dart';
import 'package:codeschool_mobile/shared/models/app_role.dart';
import 'package:codeschool_mobile/shared/models/parent.dart';
import 'package:codeschool_mobile/shared/models/user.dart';

class MockParentRepository extends Mock implements ParentRepository {}

class _FakeParentAuthController extends AuthController {
  @override
  Future<AppUser?> build() async => const AppUser(id: 3, firstName: 'Гульнара', role: AppRole.parent, isActive: true);
}

const _parent = AppUser(id: 3, firstName: 'Гульнара', role: AppRole.parent, isActive: true);

Future<void> _pump(WidgetTester tester, MockParentRepository repo) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        parentRepositoryProvider.overrideWithValue(repo),
        authControllerProvider.overrideWith(() => _FakeParentAuthController()),
      ],
      child: MaterialApp(home: Scaffold(body: ParentHomeScreen(user: _parent))),
    ),
  );
}

void main() {
  group('ParentHomeScreen', () {
    testWidgets('shows the empty state when the parent has no linked children', (tester) async {
      final repo = MockParentRepository();
      when(() => repo.listChildren()).thenAnswer((_) async => ApiResult.ok(const []));

      await _pump(tester, repo);
      await tester.pumpAndSettle();

      expect(find.text('Нет привязанных детей'), findsOneWidget);
    });

    testWidgets('shows only the linked children returned by GET /parent/children', (tester) async {
      final repo = MockParentRepository();
      when(() => repo.listChildren()).thenAnswer(
        (_) async => ApiResult.ok(const [
          ParentChildListItem(
            child: ParentChildBrief(id: 12, firstName: 'Нурлан'),
            coursesCount: 2,
            overallProgressPercent: 40,
            pendingReview: 1,
            needsWork: 0,
          ),
        ]),
      );

      await _pump(tester, repo);
      await tester.pumpAndSettle();

      expect(find.text('Нурлан'), findsOneWidget);
      expect(find.textContaining('40%'), findsOneWidget);
    });
  });
}
