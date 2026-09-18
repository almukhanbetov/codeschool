import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/core/providers/core_providers.dart';
import 'package:codeschool_mobile/features/quiz/application/quiz_providers.dart';
import 'package:codeschool_mobile/features/quiz/data/quiz_repository.dart';
import 'package:codeschool_mobile/features/quiz/presentation/quiz_screen.dart';
import 'package:codeschool_mobile/shared/models/assignment.dart';
import 'package:codeschool_mobile/shared/models/quiz.dart';

class MockQuizRepository extends Mock implements QuizRepository {}

const _assignment = Assignment(id: 900, lessonId: 350, title: 'Мини-квиз', assignmentType: 'quiz', points: 10, position: 1);

const _quiz = StudentQuiz(
  assignmentId: 900,
  title: 'Мини-квиз',
  passPercent: 70,
  questions: [
    StudentQuestion(
      id: 10,
      questionText: 'Что делает компьютер без команд человека?',
      questionType: 'single_choice',
      points: 1,
      position: 1,
      options: [
        StudentOption(id: 100, optionText: 'Ничего', position: 1),
        StudentOption(id: 101, optionText: 'Думает сам', position: 2),
      ],
    ),
  ],
);

Future<void> _pumpQuiz(WidgetTester tester, MockQuizRepository repo) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        quizRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: QuizScreen(assignment: _assignment)),
    ),
  );
}

void main() {
  group('QuizScreen', () {
    testWidgets('shows a start button when the backend allows it, then starts a real attempt', (tester) async {
      final repo = MockQuizRepository();
      when(() => repo.listAttempts(900)).thenAnswer(
        (_) async => ApiResult.ok(
          const QuizAttemptHistory(assignmentId: 900, title: 'Мини-квиз', passPercent: 70, attemptsUsed: 0, canStart: true, passed: false),
        ),
      );
      when(() => repo.startAttempt(900)).thenAnswer(
        (_) async => ApiResult.ok(
          StartAttemptResponse(attempt: AttemptBrief(id: 1, status: 'in_progress', startedAt: DateTime.utc(2026, 1, 1)), quiz: _quiz),
        ),
      );
      when(() => repo.getAttempt(1)).thenAnswer(
        (_) async => ApiResult.ok(
          AttemptDetail(attempt: AttemptBrief(id: 1, status: 'in_progress', startedAt: DateTime.utc(2026, 1, 1)), quiz: _quiz),
        ),
      );

      await _pumpQuiz(tester, repo);
      await tester.pumpAndSettle();

      expect(find.text('Начать квиз'), findsOneWidget);
      await tester.tap(find.text('Начать квиз'));
      await tester.pumpAndSettle();

      expect(find.text('Что делает компьютер без команд человека?'), findsOneWidget);
      verify(() => repo.startAttempt(900)).called(1);
    });

    testWidgets('answering and submitting shows the real graded result', (tester) async {
      final repo = MockQuizRepository();
      when(() => repo.listAttempts(900)).thenAnswer(
        (_) async => ApiResult.ok(
          const QuizAttemptHistory(assignmentId: 900, title: 'Мини-квиз', passPercent: 70, attemptsUsed: 0, canStart: true, passed: false, inProgressId: 1),
        ),
      );
      when(() => repo.getAttempt(1)).thenAnswer(
        (_) async => ApiResult.ok(
          AttemptDetail(attempt: AttemptBrief(id: 1, status: 'in_progress', startedAt: DateTime.utc(2026, 1, 1)), quiz: _quiz),
        ),
      );
      when(() => repo.submitAttempt(1, any())).thenAnswer(
        (_) async => ApiResult.ok(
          const AttemptResult(
            attemptId: 1,
            assignmentId: 900,
            status: 'submitted',
            score: 1,
            maxScore: 1,
            percent: 100,
            passed: true,
            passPercent: 70,
            showCorrectAnswers: true,
            questions: [
              ResultQuestion(
                questionId: 10,
                questionText: 'Что делает компьютер без команд человека?',
                questionType: 'single_choice',
                points: 1,
                pointsAwarded: 1,
                isCorrect: true,
                options: [
                  ResultOption(id: 100, optionText: 'Ничего', position: 1, selected: true, isCorrect: true),
                  ResultOption(id: 101, optionText: 'Думает сам', position: 2, selected: false, isCorrect: false),
                ],
              ),
            ],
          ),
        ),
      );

      await _pumpQuiz(tester, repo);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ничего'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ответить'));
      await tester.pumpAndSettle();

      expect(find.text('Пройдено'), findsOneWidget);
      verify(() => repo.submitAttempt(1, {10: [100]})).called(1);
    });

    testWidgets('shows "no attempts left" when the backend says so, real gate not a client guess', (tester) async {
      final repo = MockQuizRepository();
      when(() => repo.listAttempts(900)).thenAnswer(
        (_) async => ApiResult.ok(
          const QuizAttemptHistory(
            assignmentId: 900,
            title: 'Мини-квиз',
            passPercent: 70,
            maxAttempts: 1,
            attemptsUsed: 1,
            attemptsLeft: 0,
            canStart: false,
            passed: false,
            bestPercent: 40,
          ),
        ),
      );

      await _pumpQuiz(tester, repo);
      await tester.pumpAndSettle();

      expect(find.text('Попытки закончились'), findsOneWidget);
      expect(find.text('Начать квиз'), findsNothing);
    });
  });
}
