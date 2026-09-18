import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/core/network/api_exception.dart';
import 'package:codeschool_mobile/features/lesson/data/lesson_repository.dart';
import 'package:codeschool_mobile/shared/models/assignment.dart';
import 'package:codeschool_mobile/shared/models/progress.dart';

class MockApiClient extends Mock implements ApiClient {}

/// Mock only [ApiClient] and check [LessonRepository] calls the exact real
/// routes in backend/internal/assignments/routes.go and
/// backend/internal/progress/routes.go.
void main() {
  late MockApiClient client;
  late LessonRepository repo;

  setUp(() {
    client = MockApiClient();
    repo = LessonRepository(client);
  });

  test('listAssignments hits GET /lessons/:id/assignments and decodes the real Response shape', () async {
    when(() => client.get<List<Assignment>>('/lessons/350/assignments', decode: any(named: 'decode')))
        .thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as List<Assignment> Function(dynamic);
      return ApiResult.ok(decode([
        {
          'id': 900,
          'lessonId': 350,
          'title': 'Придумай 3 команды',
          'assignmentType': 'text',
          'points': 5,
          'position': 1,
        },
      ]));
    });

    final result = await repo.listAssignments(350);
    final assignments = (result as ApiOk<List<Assignment>>).data;
    expect(assignments.single.title, 'Придумай 3 команды');
    expect(assignments.single.assignmentType, 'text');
  });

  test('startLesson POSTs to /lessons/:id/start', () async {
    when(() => client.post<LessonProgress>('/lessons/350/start', decode: any(named: 'decode')))
        .thenAnswer((_) async => ApiResult.err(const ApiException(statusCode: 401, code: 'UNAUTHORIZED', message: 'x')));

    await repo.startLesson(350);

    verify(() => client.post<LessonProgress>('/lessons/350/start', decode: any(named: 'decode'))).called(1);
  });

  test('completeLesson POSTs to /lessons/:id/complete and surfaces a real 409 (assignment incomplete)', () async {
    when(() => client.post<CompleteLessonResult>('/lessons/350/complete', decode: any(named: 'decode'))).thenAnswer(
      (_) async => ApiResult.err(
        const ApiException(statusCode: 409, code: 'CONFLICT', message: "Submit the lesson's assignment before completing it"),
      ),
    );

    final result = await repo.completeLesson(350);

    expect((result as ApiErr<CompleteLessonResult>).error.statusCode, 409);
  });
}
