import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/features/teacher_academy/data/academy_repository.dart';
import 'package:codeschool_mobile/shared/models/academy.dart';
import 'package:codeschool_mobile/shared/models/enrollment.dart';

class MockApiClient extends Mock implements ApiClient {}

/// Mock only [ApiClient] and check [AcademyRepository] calls the exact
/// real routes in backend/internal/academy/routes.go, mounted under
/// /teacher-academy.
void main() {
  late MockApiClient client;
  late AcademyRepository repo;

  setUp(() {
    client = MockApiClient();
    repo = AcademyRepository(client);
  });

  test('listCourses hits GET /teacher-academy/courses', () async {
    when(() => client.get<List<AcademyCourseCard>>('/teacher-academy/courses', decode: any(named: 'decode'))).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as List<AcademyCourseCard> Function(dynamic);
      return ApiResult.ok(decode([
        {
          'id': 304,
          'title': 'Python с нуля',
          'slug': 'python',
          'audience': 'teacher',
          'totalLessons': 20,
          'enrolled': false,
        },
      ]));
    });

    final result = await repo.listCourses();
    final courses = (result as ApiOk<List<AcademyCourseCard>>).data;
    expect(courses.single.enrolled, false);
  });

  test('enroll POSTs to /teacher-academy/courses/:id/enroll and decodes the shared Enrollment model', () async {
    when(() => client.post<Enrollment>('/teacher-academy/courses/304/enroll', decode: any(named: 'decode'))).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as Enrollment Function(dynamic);
      return ApiResult.ok(decode({
        'id': 1,
        'studentId': 42,
        'courseId': 304,
        'status': 'active',
        'enrolledAt': '2026-09-18T10:00:00Z',
      }));
    });

    final result = await repo.enroll(304);
    expect((result as ApiOk<Enrollment>).data.courseId, 304);
  });

  test('dashboard hits GET /teacher-academy/dashboard', () async {
    when(() => client.get<AcademyDashboard>('/teacher-academy/dashboard', decode: any(named: 'decode'))).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as AcademyDashboard Function(dynamic);
      return ApiResult.ok(decode({
        'coursesInProgress': 1,
        'coursesCompleted': 0,
        'totalCourses': 1,
        'overallPercent': 30,
        'courses': [],
      }));
    });

    final result = await repo.dashboard();
    expect((result as ApiOk<AcademyDashboard>).data.overallPercent, 30);
  });

  test('myCourses hits GET /teacher-academy/me/courses', () async {
    when(() => client.get<List<AcademyMyCourse>>('/teacher-academy/me/courses', decode: any(named: 'decode'))).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as List<AcademyMyCourse> Function(dynamic);
      return ApiResult.ok(decode([]));
    });

    final result = await repo.myCourses();
    expect((result as ApiOk<List<AcademyMyCourse>>).data, isEmpty);
  });
}
