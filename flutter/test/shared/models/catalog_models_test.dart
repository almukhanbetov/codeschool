import 'package:flutter_test/flutter_test.dart';

import 'package:codeschool_mobile/shared/models/course.dart';
import 'package:codeschool_mobile/shared/models/course_content.dart';
import 'package:codeschool_mobile/shared/models/enrollment.dart';

void main() {
  group('Course.fromJson', () {
    test('decodes a real /courses response row (codeschool-year1-logic)', () {
      final course = Course.fromJson({
        'id': 353,
        'levelId': 134,
        'title': 'Год 1: Визуальная логика и алгоритмическое мышление',
        'slug': 'codeschool-year1-logic',
        'description': '36 недель, 72 занятия, 9 модулей',
        'shortDescription': 'Год 1: с чего начинается программирование',
        'imageUrl': null,
        'ageFrom': 6,
        'ageTo': 8,
        'durationLessons': 72,
        'projectsCount': 1,
        'difficulty': 'beginner',
        'audience': 'student',
      });

      expect(course.id, 353);
      expect(course.slug, 'codeschool-year1-logic');
      expect(course.ageFrom, 6);
      expect(course.ageTo, 8);
      expect(course.durationLessons, 72);
      expect(course.imageUrl, isNull);
      expect(course.audience, 'student');
    });

    test('nullable fields decode to null when absent from the JSON', () {
      final course = Course.fromJson({
        'id': 1,
        'levelId': 1,
        'title': 'Minimal',
        'slug': 'minimal',
        'audience': 'student',
      });

      expect(course.description, isNull);
      expect(course.ageFrom, isNull);
      expect(course.difficulty, isNull);
    });
  });

  group('CourseContent.fromJson', () {
    test('decodes a course + 9 modules with lessons nested inline', () {
      final content = CourseContent.fromJson({
        'course': {
          'id': 353,
          'levelId': 134,
          'title': 'Год 1',
          'slug': 'codeschool-year1-logic',
          'audience': 'student',
        },
        'modules': List.generate(
          9,
          (i) => {
            'id': i + 1,
            'courseId': 353,
            'title': 'Модуль ${i + 1}',
            'position': i + 1,
            'lessons': List.generate(
              8,
              (j) => {
                'id': (i * 8) + j + 1,
                'moduleId': i + 1,
                'title': 'Урок ${j + 1}',
                'lessonType': 'text',
                'position': j + 1,
              },
            ),
          },
        ),
      });

      expect(content.course.slug, 'codeschool-year1-logic');
      expect(content.modules, hasLength(9));
      final totalLessons = content.modules.fold<int>(0, (sum, m) => sum + m.lessons.length);
      expect(totalLessons, 72);
      expect(content.modules.first.lessons.first.lessonType, 'text');
    });
  });

  group('Enrollment.fromJson', () {
    test('decodes a POST /courses/:id/enroll response', () {
      final enrollment = Enrollment.fromJson({
        'id': 10,
        'studentId': 5,
        'courseId': 353,
        'status': 'active',
        'enrolledAt': '2026-09-17T10:00:00Z',
      });

      expect(enrollment.status, 'active');
      expect(enrollment.completedAt, isNull);
      expect(enrollment.courseId, 353);
    });
  });
}
