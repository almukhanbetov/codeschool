import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/core/providers/core_providers.dart';
import 'package:codeschool_mobile/features/auth/application/auth_controller.dart';
import 'package:codeschool_mobile/features/support_chat/application/support_providers.dart';
import 'package:codeschool_mobile/features/support_chat/data/support_repository.dart';
import 'package:codeschool_mobile/features/support_chat/presentation/support_thread_list_screen.dart';
import 'package:codeschool_mobile/shared/models/app_role.dart';
import 'package:codeschool_mobile/shared/models/support.dart';
import 'package:codeschool_mobile/shared/models/user.dart';

class MockSupportRepository extends Mock implements SupportRepository {}

class _FakeStudentAuthController extends AuthController {
  @override
  Future<AppUser?> build() async => const AppUser(id: 1, firstName: 'Аружан', role: AppRole.student, isActive: true);
}

class _FakeTeacherAuthController extends AuthController {
  @override
  Future<AppUser?> build() async => const AppUser(id: 2, firstName: 'Марат', role: AppRole.teacher, isActive: true);
}

Future<void> _pump(WidgetTester tester, MockSupportRepository repo, {required bool asTeacher}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        supportRepositoryProvider.overrideWithValue(repo),
        authControllerProvider.overrideWith(() => asTeacher ? _FakeTeacherAuthController() : _FakeStudentAuthController()),
      ],
      child: const MaterialApp(home: SupportThreadListScreen()),
    ),
  );
}

void main() {
  group('SupportThreadListScreen', () {
    testWidgets('shows "not available for role" for a teacher (backend RequireRole("student","parent") only)', (tester) async {
      final repo = MockSupportRepository();
      when(() => repo.unreadCount()).thenAnswer((_) async => ApiResult.ok(const SupportUnreadCount(threads: 0, messages: 0)));

      await _pump(tester, repo, asTeacher: true);
      await tester.pumpAndSettle();

      expect(find.text('Чат поддержки недоступен для вашей роли'), findsOneWidget);
      verifyNever(() => repo.listThreads());
    });

    testWidgets('shows the empty state for a student with no threads', (tester) async {
      final repo = MockSupportRepository();
      when(() => repo.listThreads()).thenAnswer((_) async => ApiResult.ok(const []));

      await _pump(tester, repo, asTeacher: false);
      await tester.pumpAndSettle();

      expect(find.text('У вас пока нет обращений'), findsOneWidget);
    });

    testWidgets('shows real threads with an unread badge', (tester) async {
      final repo = MockSupportRepository();
      when(() => repo.listThreads()).thenAnswer(
        (_) async => ApiResult.ok([
          SupportThreadListItem(
            id: 3,
            subject: 'Вопрос по заданию',
            category: 'assignment',
            status: 'open',
            priority: 'normal',
            about: const SupportThreadAbout(studentName: 'Аружан'),
            lastMessagePreview: 'Не понимаю условие',
            lastMessageAt: DateTime.utc(2026, 9, 17),
            unreadCount: 2,
            assignedToStaff: false,
            createdAt: DateTime.utc(2026, 9, 17),
          ),
        ]),
      );

      await _pump(tester, repo, asTeacher: false);
      await tester.pumpAndSettle();

      expect(find.text('Вопрос по заданию'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });
}
