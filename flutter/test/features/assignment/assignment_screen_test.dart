import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/core/providers/core_providers.dart';
import 'package:codeschool_mobile/features/assignment/application/assignment_providers.dart';
import 'package:codeschool_mobile/features/assignment/data/assignment_repository.dart';
import 'package:codeschool_mobile/features/assignment/presentation/assignment_screen.dart';
import 'package:codeschool_mobile/shared/models/assignment.dart';

class MockAssignmentRepository extends Mock implements AssignmentRepository {}

const _textAssignment = Assignment(
  id: 900,
  lessonId: 350,
  title: 'Придумай 3 команды',
  description: 'Опиши команды для робота-помощника',
  assignmentType: 'text',
  points: 5,
  position: 1,
);

const _quizAssignment = Assignment(id: 901, lessonId: 350, title: 'Мини-квиз', assignmentType: 'quiz', points: 10, position: 2);
const _codeAssignment = Assignment(id: 902, lessonId: 350, title: 'Напиши код', assignmentType: 'code', points: 10, position: 3);

/// Builds the widget tree directly (bypassing GoRouter's initial-location
/// limitation with `extra`) for the common case: just render
/// [AssignmentScreen] with the assignment handed in directly.
Future<void> _pumpDirect(WidgetTester tester, Assignment assignment, MockAssignmentRepository repo) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        assignmentRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(home: AssignmentScreen(assignment: assignment)),
    ),
  );
}

void main() {
  group('AssignmentScreen — text/project submission', () {
    testWidgets('shows an empty answer field and lets the student save a draft', (tester) async {
      final repo = MockAssignmentRepository();
      when(() => repo.getMine(900)).thenAnswer((_) async => ApiResult.ok(null));
      when(() => repo.saveDraft(900, answer: any(named: 'answer'))).thenAnswer(
        (_) async => ApiResult.ok(
          Submission(id: 1, assignmentId: 900, studentId: 1, answer: 'Включить свет', status: 'draft', updatedAt: DateTime.utc(2026, 1, 1)),
        ),
      );

      await _pumpDirect(tester, _textAssignment, repo);
      await tester.pumpAndSettle();

      expect(find.text('Придумай 3 команды'), findsWidgets);
      await tester.enterText(find.byType(TextField), 'Включить свет');
      await tester.tap(find.text('Сохранить черновик'));
      await tester.pumpAndSettle();

      verify(() => repo.saveDraft(900, answer: 'Включить свет')).called(1);
    });

    testWidgets('pre-fills the field from an existing draft and shows the status badge', (tester) async {
      final repo = MockAssignmentRepository();
      when(() => repo.getMine(900)).thenAnswer(
        (_) async => ApiResult.ok(
          Submission(id: 1, assignmentId: 900, studentId: 1, answer: 'Черновик ответа', status: 'draft', updatedAt: DateTime.utc(2026, 1, 1)),
        ),
      );

      await _pumpDirect(tester, _textAssignment, repo);
      await tester.pumpAndSettle();

      expect(find.text('Черновик ответа'), findsOneWidget);
      expect(find.text('Черновик'), findsOneWidget);
    });

    testWidgets('a graded submission is read-only and shows score + teacher feedback', (tester) async {
      final repo = MockAssignmentRepository();
      when(() => repo.getMine(900)).thenAnswer(
        (_) async => ApiResult.ok(
          Submission(
            id: 1,
            assignmentId: 900,
            studentId: 1,
            answer: 'Финальный ответ',
            status: 'passed',
            score: 5,
            teacherFeedback: 'Отличная работа!',
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        ),
      );

      await _pumpDirect(tester, _textAssignment, repo);
      await tester.pumpAndSettle();

      expect(find.text('Принято'), findsOneWidget);
      expect(find.text('Отличная работа!'), findsOneWidget);
      expect(find.text('Сохранить черновик'), findsNothing);
      expect(find.text('Отправить на проверку'), findsNothing);

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.enabled, isFalse);
    });
  });

  group('AssignmentScreen — quiz/code hand-off', () {
    testWidgets('a quiz assignment shows a "start quiz" button', (tester) async {
      final repo = MockAssignmentRepository();
      await _pumpDirect(tester, _quizAssignment, repo);
      await tester.pumpAndSettle();

      expect(find.text('Начать квиз'), findsOneWidget);
    });

    testWidgets('a code assignment shows a "open code editor" button', (tester) async {
      final repo = MockAssignmentRepository();
      await _pumpDirect(tester, _codeAssignment, repo);
      await tester.pumpAndSettle();

      expect(find.text('Редактор кода'), findsOneWidget);
    });
  });
}
