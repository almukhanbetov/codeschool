import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress.freezed.dart';
part 'progress.g.dart';

/// Mirrors backend/internal/progress/dto.go `LessonProgressResponse`.
@freezed
abstract class LessonProgress with _$LessonProgress {
  const factory LessonProgress({
    required int lessonId,
    required String status,
    required int progressPercent,
    DateTime? startedAt,
    DateTime? completedAt,
  }) = _LessonProgress;

  factory LessonProgress.fromJson(Map<String, dynamic> json) => _$LessonProgressFromJson(json);
}

/// Mirrors backend/internal/progress/dto.go `CourseProgressResponse`
/// (one row of GET /me/progress).
@freezed
abstract class CourseProgress with _$CourseProgress {
  const factory CourseProgress({
    required int courseId,
    required String title,
    required int completedLessons,
    required int totalLessons,
    required int progressPercent,
  }) = _CourseProgress;

  factory CourseProgress.fromJson(Map<String, dynamic> json) => _$CourseProgressFromJson(json);
}

/// Mirrors `CourseDetailResponse` (GET /me/courses/:id/progress).
@freezed
abstract class CourseProgressDetail with _$CourseProgressDetail {
  const factory CourseProgressDetail({
    required int courseId,
    required String title,
    required int completedLessons,
    required int totalLessons,
    required int progressPercent,
    required String enrollmentStatus,
    @Default([]) List<LessonProgress> lessons,
  }) = _CourseProgressDetail;

  factory CourseProgressDetail.fromJson(Map<String, dynamic> json) => _$CourseProgressDetailFromJson(json);
}

/// Mirrors `CompleteLessonResponse` (POST /lessons/:id/complete).
@freezed
abstract class CompleteLessonResult with _$CompleteLessonResult {
  const factory CompleteLessonResult({
    required LessonProgress lesson,
    required CourseProgress course,
    required bool enrollmentCompleted,
  }) = _CompleteLessonResult;

  factory CompleteLessonResult.fromJson(Map<String, dynamic> json) => _$CompleteLessonResultFromJson(json);
}
