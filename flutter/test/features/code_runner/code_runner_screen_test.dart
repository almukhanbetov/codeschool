import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/core/providers/core_providers.dart';
import 'package:codeschool_mobile/features/assignment/application/assignment_providers.dart';
import 'package:codeschool_mobile/features/assignment/data/assignment_repository.dart';
import 'package:codeschool_mobile/features/code_runner/application/code_runner_providers.dart';
import 'package:codeschool_mobile/features/code_runner/data/code_runner_repository.dart';
import 'package:codeschool_mobile/features/code_runner/presentation/code_runner_screen.dart';
import 'package:codeschool_mobile/shared/models/assignment.dart';
import 'package:codeschool_mobile/shared/models/run.dart';

class MockAssignmentRepository extends Mock implements AssignmentRepository {}

class MockCodeRunnerRepository extends Mock implements CodeRunnerRepository {}

const _assignment = Assignment(
  id: 900,
  lessonId: 350,
  title: 'Напиши приветствие',
  assignmentType: 'code',
  starterCode: 'print("hello")',
  language: 'python',
  points: 10,
  position: 1,
);

Future<void> _pumpCodeRunner(
  WidgetTester tester,
  MockAssignmentRepository assignmentRepo,
  MockCodeRunnerRepository codeRepo,
) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  when(() => codeRepo.getTests(900)).thenAnswer((_) async => ApiResult.ok(const TestsResponse(hasTests: false, total: 0)));
  // The screen best-effort saves the code as a draft on dispose (leaving
  // the screen) — stub it once here so every test doesn't have to.
  when(() => assignmentRepo.saveDraft(900, code: any(named: 'code'))).thenAnswer(
    (_) async => ApiResult.ok(
      Submission(id: 1, assignmentId: 900, studentId: 1, status: 'draft', updatedAt: DateTime.utc(2026, 1, 1)),
    ),
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        assignmentRepositoryProvider.overrideWithValue(assignmentRepo),
        codeRunnerRepositoryProvider.overrideWithValue(codeRepo),
      ],
      child: const MaterialApp(home: CodeRunnerScreen(assignment: _assignment)),
    ),
  );
}

void main() {
  group('CodeRunnerScreen', () {
    testWidgets('loads the starter code and shows real stdout after Run', (tester) async {
      final assignmentRepo = MockAssignmentRepository();
      final codeRepo = MockCodeRunnerRepository();
      when(() => assignmentRepo.getMine(900)).thenAnswer((_) async => ApiResult.ok(null));
      when(() => codeRepo.run(900, code: any(named: 'code'), stdin: any(named: 'stdin'))).thenAnswer(
        (_) async => ApiResult.ok(
          RunResult(
            runId: 1,
            language: 'python',
            status: 'ok',
            stdout: 'hello\n',
            stderr: '',
            exitCode: 0,
            timedOut: false,
            truncated: false,
            durationMs: 12,
            createdAt: DateTime.utc(2026, 1, 1),
          ),
        ),
      );

      await _pumpCodeRunner(tester, assignmentRepo, codeRepo);
      await tester.pumpAndSettle();

      expect(find.text('print("hello")'), findsWidgets);

      await tester.tap(find.text('Запустить'));
      await tester.pumpAndSettle();

      expect(find.text('hello\n'), findsOneWidget);
      verify(() => codeRepo.run(900, code: 'print("hello")', stdin: '')).called(1);
    });

    testWidgets('resumes from a saved draft instead of the starter code', (tester) async {
      final assignmentRepo = MockAssignmentRepository();
      final codeRepo = MockCodeRunnerRepository();
      when(() => assignmentRepo.getMine(900)).thenAnswer(
        (_) async => ApiResult.ok(
          Submission(id: 1, assignmentId: 900, studentId: 1, code: 'print("draft")', status: 'draft', updatedAt: DateTime.utc(2026, 1, 1)),
        ),
      );

      await _pumpCodeRunner(tester, assignmentRepo, codeRepo);
      await tester.pumpAndSettle();

      expect(find.text('print("draft")'), findsWidgets);
      expect(find.text('print("hello")'), findsNothing);
    });

    testWidgets('submitting for grading shows the real GradeResult with test outcomes', (tester) async {
      final assignmentRepo = MockAssignmentRepository();
      final codeRepo = MockCodeRunnerRepository();
      when(() => assignmentRepo.getMine(900)).thenAnswer((_) async => ApiResult.ok(null));
      when(() => codeRepo.submitCode(900, code: any(named: 'code'))).thenAnswer(
        (_) async => ApiResult.ok(
          const GradeResult(
            submissionId: 1,
            status: 'passed',
            passed: true,
            points: 10,
            percent: 100,
            testsPassed: 2,
            testsTotal: 2,
            feedback: 'Все тесты пройдены',
            outcomes: [
              TestOutcome(testId: 1, name: 'test 1', hidden: false, passed: true, timedOut: false),
              TestOutcome(testId: 2, name: 'test 2', hidden: true, passed: true, timedOut: false),
            ],
          ),
        ),
      );

      await _pumpCodeRunner(tester, assignmentRepo, codeRepo);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Отправить решение'));
      await tester.pumpAndSettle();

      expect(find.textContaining('2/2'), findsOneWidget);
      expect(find.text('Все тесты пройдены'), findsOneWidget);
      verify(() => codeRepo.submitCode(900, code: 'print("hello")')).called(1);
    });

    testWidgets('shows the real timeout/truncated flags from the backend', (tester) async {
      final assignmentRepo = MockAssignmentRepository();
      final codeRepo = MockCodeRunnerRepository();
      when(() => assignmentRepo.getMine(900)).thenAnswer((_) async => ApiResult.ok(null));
      when(() => codeRepo.run(900, code: any(named: 'code'), stdin: any(named: 'stdin'))).thenAnswer(
        (_) async => ApiResult.ok(
          RunResult(
            runId: 1,
            language: 'python',
            status: 'timeout',
            stdout: '',
            stderr: '',
            timedOut: true,
            truncated: false,
            createdAt: DateTime.utc(2026, 1, 1),
          ),
        ),
      );

      await _pumpCodeRunner(tester, assignmentRepo, codeRepo);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Запустить'));
      await tester.pumpAndSettle();

      expect(find.text('Превышено время выполнения'), findsOneWidget);
    });
  });
}
