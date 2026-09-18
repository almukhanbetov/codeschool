import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/core/network/api_exception.dart';
import 'package:codeschool_mobile/features/quiz/data/quiz_repository.dart';
import 'package:codeschool_mobile/shared/models/quiz.dart';

class MockApiClient extends Mock implements ApiClient {}

/// Mock only [ApiClient] and check [QuizRepository] calls the exact real
/// routes in backend/internal/quizzes/routes.go, with the real
/// `SubmitRequest{answers:[{questionId,selectedOptionIds}]}` body shape —
/// correctness is always computed server-side, never locally.
void main() {
  late MockApiClient client;
  late QuizRepository repo;

  setUp(() {
    client = MockApiClient();
    repo = QuizRepository(client);
  });

  test('startAttempt POSTs to /assignments/:id/quiz/attempts', () async {
    when(() => client.post<StartAttemptResponse>('/assignments/900/quiz/attempts', decode: any(named: 'decode')))
        .thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as StartAttemptResponse Function(dynamic);
      return ApiResult.ok(decode({
        'attempt': {'id': 1, 'status': 'in_progress', 'startedAt': '2026-01-01T00:00:00Z'},
        'quiz': {'assignmentId': 900, 'title': 'Квиз', 'passPercent': 70, 'questions': []},
      }));
    });

    final result = await repo.startAttempt(900);
    expect((result as ApiOk<StartAttemptResponse>).data.attempt.id, 1);
  });

  test('submitAttempt POSTs to /quiz/attempts/:id/submit with the real answers shape', () async {
    when(() => client.post<AttemptResult>('/quiz/attempts/1/submit', data: any(named: 'data'), decode: any(named: 'decode')))
        .thenAnswer((_) async => ApiResult.err(const ApiException(statusCode: 401, code: 'UNAUTHORIZED', message: 'x')));

    await repo.submitAttempt(1, {10: [100, 101], 11: [102]});

    final captured = verify(
      () => client.post<AttemptResult>('/quiz/attempts/1/submit', data: captureAny(named: 'data'), decode: any(named: 'decode')),
    ).captured;
    expect(captured.single, {
      'answers': [
        {'questionId': 10, 'selectedOptionIds': [100, 101]},
        {'questionId': 11, 'selectedOptionIds': [102]},
      ],
    });
  });

  test('getAttempt hits GET /quiz/attempts/:id', () async {
    when(() => client.get<AttemptDetail>('/quiz/attempts/1', decode: any(named: 'decode'))).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as AttemptDetail Function(dynamic);
      return ApiResult.ok(decode({
        'attempt': {'id': 1, 'status': 'in_progress', 'startedAt': '2026-01-01T00:00:00Z'},
        'quiz': {'assignmentId': 900, 'title': 'Квиз', 'passPercent': 70, 'questions': []},
      }));
    });

    final result = await repo.getAttempt(1);
    expect((result as ApiOk<AttemptDetail>).data.quiz, isNotNull);
    expect((result).data.result, isNull);
  });
}
