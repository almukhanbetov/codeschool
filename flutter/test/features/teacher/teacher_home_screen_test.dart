import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/core/providers/core_providers.dart';
import 'package:codeschool_mobile/features/auth/application/auth_controller.dart';
import 'package:codeschool_mobile/features/teacher/application/teacher_providers.dart';
import 'package:codeschool_mobile/features/teacher/data/teacher_repository.dart';
import 'package:codeschool_mobile/features/teacher/presentation/teacher_home_screen.dart';
import 'package:codeschool_mobile/shared/models/app_role.dart';
import 'package:codeschool_mobile/shared/models/teacher.dart';
import 'package:codeschool_mobile/shared/models/user.dart';

class MockTeacherRepository extends Mock implements TeacherRepository {}

class _FakeTeacherAuthController extends AuthController {
  @override
  Future<AppUser?> build() async => const AppUser(id: 2, firstName: 'Марат', role: AppRole.teacher, isActive: true);
}

const _teacher = AppUser(id: 2, firstName: 'Марат', role: AppRole.teacher, isActive: true);

Future<void> _pump(WidgetTester tester, MockTeacherRepository repo) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        teacherRepositoryProvider.overrideWithValue(repo),
        authControllerProvider.overrideWith(() => _FakeTeacherAuthController()),
      ],
      child: MaterialApp(home: Scaffold(body: TeacherHomeScreen(user: _teacher))),
    ),
  );
}

void main() {
  group('TeacherHomeScreen', () {
    testWidgets('shows real dashboard numbers from GET /teacher/dashboard', (tester) async {
      final repo = MockTeacherRepository();
      when(() => repo.dashboard()).thenAnswer(
        (_) async => ApiResult.ok(
          const TeacherDashboard(groupsCount: 3, studentsCount: 40, pendingSubmissions: 5, reviewedSubmissions: 20),
        ),
      );

      await _pump(tester, repo);
      await tester.pumpAndSettle();

      expect(find.text('Кабинет преподавателя'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('shows a pending-review badge on the submissions quick link when > 0', (tester) async {
      final repo = MockTeacherRepository();
      when(() => repo.dashboard()).thenAnswer(
        (_) async => ApiResult.ok(
          const TeacherDashboard(groupsCount: 1, studentsCount: 10, pendingSubmissions: 4, reviewedSubmissions: 0),
        ),
      );

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pump(tester, repo);
      await tester.pumpAndSettle();

      expect(find.byType(Badge), findsOneWidget);
    });
  });
}
