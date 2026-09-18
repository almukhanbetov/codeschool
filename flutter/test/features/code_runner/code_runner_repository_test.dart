import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/core/network/api_exception.dart';
import 'package:codeschool_mobile/features/code_runner/data/code_runner_repository.dart';
import 'package:codeschool_mobile/shared/models/run.dart';

class MockApiClient extends Mock implements ApiClient {}

/// Mock only [ApiClient] and check [CodeRunnerRepository] calls the exact
/// real routes in backend/internal/runs/routes.go, with the real request
/// body shapes (`RunRequest{code,stdin}`, `GradeRequest{code}`) — nothing
/// ever executes locally, every call just POSTs source to the backend.
void main() {
  late MockApiClient client;
  late CodeRunnerRepository repo;

  setUp(() {
    client = MockApiClient();
    repo = CodeRunnerRepository(client);
  });

  test('run POSTs to /assignments/:id/run with {code,stdin} and decodes a real RunResult', () async {
    when(() => client.post<RunResult>('/assignments/900/run', data: any(named: 'data'), decode: any(named: 'decode')))
        .thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as RunResult Function(dynamic);
      return ApiResult.ok(decode({
        'runId': 1,
        'language': 'python',
        'status': 'ok',
        'stdout': 'Hello\n',
        'stderr': '',
        'exitCode': 0,
        'timedOut': false,
        'truncated': false,
        'durationMs': 42,
        'createdAt': '2026-01-01T00:00:00Z',
      }));
    });

    await repo.run(900, code: 'print("Hello")', stdin: '');

    final captured = verify(
      () => client.post<RunResult>('/assignments/900/run', data: captureAny(named: 'data'), decode: any(named: 'decode')),
    ).captured;
    expect(captured.single, {'code': 'print("Hello")', 'stdin': ''});
  });

  test('getTests hits GET /assignments/:id/tests', () async {
    when(() => client.get<TestsResponse>('/assignments/900/tests', decode: any(named: 'decode')))
        .thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as TestsResponse Function(dynamic);
      return ApiResult.ok(decode({'hasTests': true, 'total': 3, 'visible': []}));
    });

    final result = await repo.getTests(900);
    expect((result as ApiOk<TestsResponse>).data.total, 3);
  });

  test('submitCode POSTs to /assignments/:id/code/submit and surfaces a real 409 throttle error', () async {
    when(() => client.post<GradeResult>('/assignments/900/code/submit', data: any(named: 'data'), decode: any(named: 'decode')))
        .thenAnswer(
      (_) async => ApiResult.err(const ApiException(statusCode: 409, code: 'CONFLICT', message: 'Too many runs — wait a moment')),
    );

    final result = await repo.submitCode(900, code: 'print(1)');
    expect((result as ApiErr<GradeResult>).error.statusCode, 409);
  });
}
