import 'package:freezed_annotation/freezed_annotation.dart';

part 'course.freezed.dart';
part 'course.g.dart';

/// Mirrors backend/internal/courses/dto.go `Response` exactly.
@freezed
abstract class Course with _$Course {
  const factory Course({
    required int id,
    required int levelId,
    required String title,
    required String slug,
    String? description,
    String? shortDescription,
    String? imageUrl,
    int? ageFrom,
    int? ageTo,
    int? durationLessons,
    int? projectsCount,
    String? difficulty,
    required String audience,
  }) = _Course;

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
}
