import 'package:freezed_annotation/freezed_annotation.dart';

import 'course.dart';
import 'lesson.dart';

part 'course_content.freezed.dart';
part 'course_content.g.dart';

/// Mirrors backend/internal/courses/dto.go `ContentResponse`
/// (GET /courses/:id/content) — the course plus every module with its
/// lessons nested inline, in one round trip.
@freezed
abstract class CourseContent with _$CourseContent {
  const factory CourseContent({
    required Course course,
    @Default([]) List<CourseModule> modules,
  }) = _CourseContent;

  factory CourseContent.fromJson(Map<String, dynamic> json) => _$CourseContentFromJson(json);
}
