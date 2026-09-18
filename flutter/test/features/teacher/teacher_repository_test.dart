import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/features/teacher/data/teacher_repository.dart';
import 'package:codeschool_mobile/shared/models/teacher.dart';

class MockApiClient extends Mock implements ApiClient {}

/// Mock only [ApiClient] and check [TeacherRepository] calls the exact
/// real routes in backend/internal/groups/routes.go.
void main() {
  late MockApiClient client;
  late TeacherRepository repo;

  setUp(() {
    client = MockApiClient();
    repo = TeacherRepository(client);
  });

  test('dashboard hits GET /teacher/dashboard', () async {
    when(() => client.get<TeacherDashboard>('/teacher/dashboard', decode: any(named: 'decode'))).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as TeacherDashboard Function(dynamic);
      return ApiResult.ok(decode({'groupsCount': 3, 'studentsCount': 40, 'pendingSubmissions': 5, 'reviewedSubmissions': 20}));
    });

    final result = await repo.dashboard();
    expect((result as ApiOk<TeacherDashboard>).data.groupsCount, 3);
  });

  test('listGroups hits GET /teacher/groups and decodes a list', () async {
    when(() => client.get<List<TeacherGroupListItem>>('/teacher/groups', decode: any(named: 'decode'))).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as List<TeacherGroupListItem> Function(dynamic);
      return ApiResult.ok(decode([
        {
          'id': 7,
          'title': 'Python-101',
          'status': 'active',
          'studentCount': 12,
          'avgProgressPercent': 55,
          'course': {'id': 304, 'title': 'Python с нуля', 'slug': 'python'},
        },
      ]));
    });

    final result = await repo.listGroups();
    final groups = (result as ApiOk<List<TeacherGroupListItem>>).data;
    expect(groups.single.title, 'Python-101');
  });

  test('getGroupStudent hits GET /teacher/groups/:id/students/:studentId', () async {
    when(() => client.get<TeacherStudentDetail>('/teacher/groups/7/students/42', decode: any(named: 'decode'))).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as TeacherStudentDetail Function(dynamic);
      return ApiResult.ok(decode({
        'student': {'id': 42, 'firstName': 'Aigerim'},
        'course': {'id': 304, 'title': 'Python с нуля', 'slug': 'python'},
        'progress': {'completedLessons': 5, 'totalLessons': 10, 'progressPercent': 50},
        'lessons': [],
        'submissions': [],
        'quizResults': [],
      }));
    });

    final result = await repo.getGroupStudent(7, 42);
    expect((result as ApiOk<TeacherStudentDetail>).data.student.firstName, 'Aigerim');
  });

  test('listSubmissions reads meta from the sibling ApiOk.meta field, not from inside data', () async {
    when(() => client.get<List<TeacherSubmissionListItem>>(
          '/teacher/submissions',
          query: {'page': 1, 'limit': 20},
          decode: any(named: 'decode'),
        )).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as List<TeacherSubmissionListItem> Function(dynamic);
      final items = decode([
        {
          'id': 91,
          'status': 'submitted',
          'student': {'id': 42, 'firstName': 'Aigerim'},
          'course': {'id': 304, 'title': 'Python с нуля', 'slug': 'python'},
          'lesson': {'id': 12, 'title': 'Циклы'},
          'assignment': {'id': 55, 'title': 'Задание 1', 'points': 10},
        },
      ]);
      return ApiResult.ok(items, meta: {'page': 1, 'limit': 20, 'total': 1});
    });

    final result = await repo.listSubmissions();
    final data = (result as ApiOk<TeacherSubmissionListResult>).data;
    expect(data.items.single.id, 91);
    expect(data.meta.total, 1);
  });

  test('listSubmissions falls back to a synthesized meta when the backend sends none', () async {
    when(() => client.get<List<TeacherSubmissionListItem>>(
          '/teacher/submissions',
          query: {'status': 'passed', 'page': 1, 'limit': 20},
          decode: any(named: 'decode'),
        )).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as List<TeacherSubmissionListItem> Function(dynamic);
      return ApiResult.ok(decode([]));
    });

    final result = await repo.listSubmissions(status: 'passed');
    final data = (result as ApiOk<TeacherSubmissionListResult>).data;
    expect(data.items, isEmpty);
    expect(data.meta.total, 0);
  });

  test('review POSTs score/feedback/status to /teacher/submissions/:id/review', () async {
    when(() => client.post<TeacherSubmissionDetail>(
          '/teacher/submissions/91/review',
          data: {'score': 9, 'feedback': 'Отлично', 'status': 'passed'},
          decode: any(named: 'decode'),
        )).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as TeacherSubmissionDetail Function(dynamic);
      return ApiResult.ok(decode({
        'id': 91,
        'status': 'passed',
        'score': 9,
        'student': {'id': 42, 'firstName': 'Aigerim'},
        'group': {'id': 7, 'title': 'Python-101'},
        'course': {'id': 304, 'title': 'Python с нуля', 'slug': 'python'},
        'module': {'id': 3, 'title': 'Модуль 1'},
        'lesson': {'id': 12, 'title': 'Циклы'},
        'assignment': {'id': 55, 'title': 'Задание 1', 'assignmentType': 'code', 'points': 10},
      }));
    });

    final result = await repo.review(91, score: 9, feedback: 'Отлично', status: 'passed');
    expect((result as ApiOk<TeacherSubmissionDetail>).data.status, 'passed');
    verify(() => client.post<TeacherSubmissionDetail>(
          '/teacher/submissions/91/review',
          data: {'score': 9, 'feedback': 'Отлично', 'status': 'passed'},
          decode: any(named: 'decode'),
        )).called(1);
  });
}
