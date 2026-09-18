import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson.freezed.dart';
part 'lesson.g.dart';

/// Mirrors backend/internal/lessons/dto.go `Response`. `isPublished` is
/// intentionally not part of the public DTO (backend filters it server-side)
/// — not omitted here by mistake.
@freezed
abstract class Lesson with _$Lesson {
  const factory Lesson({
    required int id,
    required int moduleId,
    required String title,
    String? slug,
    String? description,
    String? content,
    String? videoUrl,
    required String lessonType,
    required int position,
  }) = _Lesson;

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
}

/// Mirrors backend/internal/courses/dto.go `ModuleWithLessons` (an embedded
/// `modules.Response` plus a nested `lessons` array) — used only by
/// `GET /courses/:id/content`.
@freezed
abstract class CourseModule with _$CourseModule {
  const factory CourseModule({
    required int id,
    required int courseId,
    required String title,
    String? description,
    required int position,
    @Default([]) List<Lesson> lessons,
  }) = _CourseModule;

  factory CourseModule.fromJson(Map<String, dynamic> json) => _$CourseModuleFromJson(json);
}
