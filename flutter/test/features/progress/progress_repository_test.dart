import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/features/progress/data/progress_repository.dart';
import 'package:codeschool_mobile/shared/models/progress.dart';

class MockApiClient extends Mock implements ApiClient {}

/// Mock only [ApiClient] and check [ProgressRepository] calls the exact real
/// route in backend/internal/progress/routes.go.
void main() {
  late MockApiClient client;
  late ProgressRepository repo;

  setUp(() {
    client = MockApiClient();
    repo = ProgressRepository(client);
  });

  test('listMyProgress hits GET /me/progress and decodes the real per-course rows', () async {
    when(() => client.get<List<CourseProgress>>('/me/progress', decode: any(named: 'decode'))).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as List<CourseProgress> Function(dynamic);
      return ApiResult.ok(decode([
        {'courseId': 304, 'title': 'Python с нуля', 'completedLessons': 9, 'totalLessons': 9, 'progressPercent': 100},
      ]));
    });

    final result = await repo.listMyProgress();
    final rows = (result as ApiOk<List<CourseProgress>>).data;
    expect(rows.single.progressPercent, 100);
    verify(() => client.get<List<CourseProgress>>('/me/progress', decode: any(named: 'decode'))).called(1);
  });
}
