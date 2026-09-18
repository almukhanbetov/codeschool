import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/core/network/api_exception.dart';
import 'package:codeschool_mobile/features/catalog/data/catalog_repository.dart';
import 'package:codeschool_mobile/shared/models/course.dart';
import 'package:codeschool_mobile/shared/models/course_content.dart';
import 'package:codeschool_mobile/shared/models/enrollment.dart';
import 'package:codeschool_mobile/shared/models/lesson.dart';
import 'package:codeschool_mobile/shared/models/progress.dart';

class MockApiClient extends Mock implements ApiClient {}

/// Repository-level tests: mock only [ApiClient] (the one HTTP boundary in
/// the app, per `core/network/api_client.dart`'s own doc comment) and check
/// that [CatalogRepository] calls the exact real backend routes with the
/// exact real query params — the same routes verified live against the dev
/// backend in this stage's report, never invented ones.
void main() {
  late MockApiClient client;
  late CatalogRepository repo;

  setUp(() {
    client = MockApiClient();
    repo = CatalogRepository(client);
  });

  group('listCourses', () {
    test('hits GET /courses with no query params for "all ages"', () async {
      when(() => client.get<List<Course>>(
            '/courses',
            query: <String, dynamic>{},
            auth: false,
            decode: any(named: 'decode'),
          )).thenAnswer((_) async => ApiResult.ok([]));

      await repo.listCourses();

      verify(() => client.get<List<Course>>(
            '/courses',
            query: <String, dynamic>{},
            auth: false,
            decode: any(named: 'decode'),
          )).called(1);
    });

    test('passes age_from/age_to as the real snake_case query params the backend expects', () async {
      when(() => client.get<List<Course>>(
            '/courses',
            query: any(named: 'query'),
            auth: false,
            decode: any(named: 'decode'),
          )).thenAnswer((_) async => ApiResult.ok([]));

      await repo.listCourses(ageFrom: 6, ageTo: 8);

      final captured = verify(() => client.get<List<Course>>(
            '/courses',
            query: captureAny(named: 'query'),
            auth: false,
            decode: any(named: 'decode'),
          )).captured;
      expect(captured.single, {'age_from': 6, 'age_to': 8});
    });

    test('decodes the real /courses response shape into Course objects', () async {
      when(() => client.get<List<Course>>(
            '/courses',
            query: any(named: 'query'),
            auth: false,
            decode: any(named: 'decode'),
          )).thenAnswer((invocation) async {
        final decode = invocation.namedArguments[#decode] as List<Course> Function(dynamic);
        return ApiResult.ok(decode([
          {
            'id': 353,
            'levelId': 134,
            'title': 'Год 1',
            'slug': 'codeschool-year1-logic',
            'audience': 'student',
            'ageFrom': 6,
            'ageTo': 8,
            'durationLessons': 72,
          },
        ]));
      });

      final result = await repo.listCourses();
      final courses = (result as ApiOk<List<Course>>).data;
      expect(courses.single.slug, 'codeschool-year1-logic');
      expect(courses.single.durationLessons, 72);
    });
  });

  test('getContent hits GET /courses/:id/content', () async {
    when(() => client.get<CourseContent>('/courses/353/content', auth: false, decode: any(named: 'decode')))
        .thenAnswer((_) async => ApiResult.err(ApiException(statusCode: 404, code: 'NOT_FOUND', message: 'x')));

    await repo.getContent(353);

    verify(() => client.get<CourseContent>('/courses/353/content', auth: false, decode: any(named: 'decode'))).called(1);
  });

  test('listModules hits GET /courses/:id/modules', () async {
    when(() => client.get<List<CourseModule>>('/courses/353/modules', auth: false, decode: any(named: 'decode')))
        .thenAnswer((_) async => ApiResult.ok([]));

    await repo.listModules(353);

    verify(() => client.get<List<CourseModule>>('/courses/353/modules', auth: false, decode: any(named: 'decode')))
        .called(1);
  });

  test('listLessonsByModule hits GET /modules/:id/lessons', () async {
    when(() => client.get<List<Lesson>>('/modules/261/lessons', auth: false, decode: any(named: 'decode')))
        .thenAnswer((_) async => ApiResult.ok([]));

    await repo.listLessonsByModule(261);

    verify(() => client.get<List<Lesson>>('/modules/261/lessons', auth: false, decode: any(named: 'decode'))).called(1);
  });

  test('getLessonById hits GET /lessons/:id and decodes the real single-lesson shape', () async {
    when(() => client.get<Lesson>('/lessons/350', auth: false, decode: any(named: 'decode'))).thenAnswer((invocation) async {
      final decode = invocation.namedArguments[#decode] as Lesson Function(dynamic);
      return ApiResult.ok(decode({
        'id': 350,
        'moduleId': 261,
        'title': 'Что делает компьютер?',
        'slug': 'y1-m1-l1-what-computer-does',
        'lessonType': 'text',
        'position': 1,
      }));
    });

    final result = await repo.getLessonById(350);
    final lesson = (result as ApiOk<Lesson>).data;
    expect(lesson.title, 'Что делает компьютер?');
    expect(lesson.moduleId, 261);
  });

  test('enroll POSTs to /courses/:id/enroll with auth (defaults to true)', () async {
    when(() => client.post<Enrollment>('/courses/353/enroll', decode: any(named: 'decode')))
        .thenAnswer((_) async => ApiResult.err(ApiException(statusCode: 401, code: 'UNAUTHORIZED', message: 'x')));

    await repo.enroll(353);

    verify(() => client.post<Enrollment>('/courses/353/enroll', decode: any(named: 'decode'))).called(1);
  });

  test('getCourseProgress hits the authenticated GET /me/courses/:id/progress', () async {
    when(() => client.get<CourseProgressDetail>('/me/courses/353/progress', decode: any(named: 'decode')))
        .thenAnswer((_) async => ApiResult.err(ApiException(statusCode: 403, code: 'FORBIDDEN', message: 'x')));

    final result = await repo.getCourseProgress(353);

    verify(() => client.get<CourseProgressDetail>('/me/courses/353/progress', decode: any(named: 'decode'))).called(1);
    expect((result as ApiErr<CourseProgressDetail>).error.statusCode, 403);
  });
}
