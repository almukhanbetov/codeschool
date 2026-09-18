import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/core/network/api_exception.dart';
import 'package:codeschool_mobile/features/parent/data/parent_repository.dart';
import 'package:codeschool_mobile/shared/models/parent.dart';

class MockApiClient extends Mock implements ApiClient {}

/// Mock only [ApiClient] and check [ParentRepository] calls the exact real
/// routes in backend/internal/parents/routes.go, keyed only off the id the
/// caller passes in (the backend, not this repository, is the RBAC gate —
/// see `requireLinked` in parents/service.go).
void main() {
  late MockApiClient client;
  late ParentRepository repo;

  setUp(() {
    client = MockApiClient();
    repo = ParentRepository(client);
  });

  test('listChildren hits GET /parent/children', () async {
    when(() => client.get<List<ParentChildListItem>>('/parent/children', decode: any(named: 'decode'))).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as List<ParentChildListItem> Function(dynamic);
      return ApiResult.ok(decode([
        {
          'child': {'id': 12, 'firstName': 'Nurlan'},
          'coursesCount': 2,
          'overallProgressPercent': 40,
          'pendingReview': 1,
          'needsWork': 0,
        },
      ]));
    });

    final result = await repo.listChildren();
    final children = (result as ApiOk<List<ParentChildListItem>>).data;
    expect(children.single.child.firstName, 'Nurlan');
  });

  test('getChild hits GET /parent/children/:childId', () async {
    when(() => client.get<ParentChildOverview>('/parent/children/12', decode: any(named: 'decode'))).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as ParentChildOverview Function(dynamic);
      return ApiResult.ok(decode({
        'child': {'id': 12, 'firstName': 'Nurlan'},
        'courses': [],
      }));
    });

    final result = await repo.getChild(12);
    expect((result as ApiOk<ParentChildOverview>).data.child.id, 12);
  });

  test('getChild surfaces the backend RBAC 403 as-is for a non-linked child id (no client-side masking)', () async {
    when(() => client.get<ParentChildOverview>('/parent/children/999', decode: any(named: 'decode'))).thenAnswer(
      (_) async => ApiResult.err(const ApiException(statusCode: 403, code: 'FORBIDDEN', message: 'not your child')),
    );

    final result = await repo.getChild(999);
    expect(result, isA<ApiErr<ParentChildOverview>>());
    expect((result as ApiErr<ParentChildOverview>).error.statusCode, 403);
  });

  test('getChildCourse hits GET /parent/children/:childId/courses/:courseId', () async {
    when(() => client.get<ParentChildCourseDetail>('/parent/children/12/courses/304', decode: any(named: 'decode'))).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as ParentChildCourseDetail Function(dynamic);
      return ApiResult.ok(decode({
        'child': {'id': 12, 'firstName': 'Nurlan'},
        'course': {'id': 304, 'title': 'Python с нуля', 'slug': 'python'},
        'progress': {'completedLessons': 3, 'totalLessons': 10, 'progressPercent': 30},
        'lessons': [],
        'assignments': [],
      }));
    });

    final result = await repo.getChildCourse(12, 304);
    expect((result as ApiOk<ParentChildCourseDetail>).data.course.id, 304);
  });

  test('getChildActivity hits GET /parent/children/:childId/activity', () async {
    when(() => client.get<ParentActivitySummary>('/parent/children/12/activity', decode: any(named: 'decode'))).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as ParentActivitySummary Function(dynamic);
      return ApiResult.ok(decode({
        'child': {'id': 12, 'firstName': 'Nurlan'},
        'items': [],
      }));
    });

    final result = await repo.getChildActivity(12);
    expect((result as ApiOk<ParentActivitySummary>).data.child.id, 12);
  });
}
