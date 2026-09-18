import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/core/network/api_exception.dart';
import 'package:codeschool_mobile/features/assignment/data/assignment_repository.dart';
import 'package:codeschool_mobile/shared/models/assignment.dart';

class MockApiClient extends Mock implements ApiClient {}

/// Mock only [ApiClient] and check [AssignmentRepository] calls the exact
/// real routes in backend/internal/submissions/routes.go.
void main() {
  late MockApiClient client;
  late AssignmentRepository repo;

  setUp(() {
    client = MockApiClient();
    repo = AssignmentRepository(client);
  });

  test('getMine hits GET /assignments/:id/submission and treats a null payload as "no submission yet"', () async {
    when(() => client.get<Submission?>('/assignments/900/submission', decode: any(named: 'decode'))).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as Submission? Function(dynamic);
      return ApiResult.ok(decode(null));
    });

    final result = await repo.getMine(900);

    expect((result as ApiOk<Submission?>).data, isNull);
  });

  test('saveDraft PUTs to /assignments/:id/submission with only the given field', () async {
    when(() => client.put<Submission>('/assignments/900/submission', data: any(named: 'data'), decode: any(named: 'decode')))
        .thenAnswer((_) async => ApiResult.err(const ApiException(statusCode: 401, code: 'UNAUTHORIZED', message: 'x')));

    await repo.saveDraft(900, answer: 'Включить свет, полить цветок');

    final captured = verify(
      () => client.put<Submission>('/assignments/900/submission', data: captureAny(named: 'data'), decode: any(named: 'decode')),
    ).captured;
    expect(captured.single, {'answer': 'Включить свет, полить цветок'});
  });

  test('submit POSTs to /assignments/:id/submit and decodes the real Response shape', () async {
    when(() => client.post<Submission>('/assignments/900/submit', decode: any(named: 'decode'))).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as Submission Function(dynamic);
      return ApiResult.ok(decode({
        'id': 1,
        'assignmentId': 900,
        'studentId': 1,
        'answer': 'Включить свет',
        'status': 'submitted',
        'updatedAt': '2026-01-01T00:00:00Z',
      }));
    });

    final result = await repo.submit(900);
    expect((result as ApiOk<Submission>).data.status, 'submitted');
  });
}
