import 'package:freezed_annotation/freezed_annotation.dart';

part 'parent.freezed.dart';
part 'parent.g.dart';

/// Mirrors backend/internal/parents/dto.go `ChildBrief` — never
/// email/phone/password (backend never sends them).
@freezed
abstract class ParentChildBrief with _$ParentChildBrief {
  const factory ParentChildBrief({required int id, required String firstName, String? lastName}) = _ParentChildBrief;
  factory ParentChildBrief.fromJson(Map<String, dynamic> json) => _$ParentChildBriefFromJson(json);
}

@freezed
abstract class ParentCourseBrief with _$ParentCourseBrief {
  const factory ParentCourseBrief({required int id, required String title, required String slug}) = _ParentCourseBrief;
  factory ParentCourseBrief.fromJson(Map<String, dynamic> json) => _$ParentCourseBriefFromJson(json);
}

@freezed
abstract class ParentProgressBrief with _$ParentProgressBrief {
  const factory ParentProgressBrief({
    required int completedLessons,
    required int totalLessons,
    required int progressPercent,
  }) = _ParentProgressBrief;
  factory ParentProgressBrief.fromJson(Map<String, dynamic> json) => _$ParentProgressBriefFromJson(json);
}

/// Mirrors `ChildListItem` (GET /parent/children) — one row per linked
/// child. `pendingReview`/`needsWork` roll up submitted+checking / failed
/// submissions across all of the child's courses.
@freezed
abstract class ParentChildListItem with _$ParentChildListItem {
  const factory ParentChildListItem({
    required ParentChildBrief child,
    required int coursesCount,
    required int overallProgressPercent,
    required int pendingReview,
    required int needsWork,
  }) = _ParentChildListItem;
  factory ParentChildListItem.fromJson(Map<String, dynamic> json) => _$ParentChildListItemFromJson(json);
}

@freezed
abstract class ParentChildCourseProgress with _$ParentChildCourseProgress {
  const factory ParentChildCourseProgress({
    required ParentCourseBrief course,
    required String enrollmentStatus,
    required ParentProgressBrief progress,
  }) = _ParentChildCourseProgress;
  factory ParentChildCourseProgress.fromJson(Map<String, dynamic> json) => _$ParentChildCourseProgressFromJson(json);
}

/// Mirrors `ChildOverview` (GET /parent/children/:id).
@freezed
abstract class ParentChildOverview with _$ParentChildOverview {
  const factory ParentChildOverview({
    required ParentChildBrief child,
    @Default([]) List<ParentChildCourseProgress> courses,
  }) = _ParentChildOverview;
  factory ParentChildOverview.fromJson(Map<String, dynamic> json) => _$ParentChildOverviewFromJson(json);
}

@freezed
abstract class ParentLessonProgressItem with _$ParentLessonProgressItem {
  const factory ParentLessonProgressItem({
    required int lessonId,
    required String title,
    required String status,
    DateTime? completedAt,
  }) = _ParentLessonProgressItem;
  factory ParentLessonProgressItem.fromJson(Map<String, dynamic> json) => _$ParentLessonProgressItemFromJson(json);
}

/// Mirrors `AssignmentFeedbackItem` — `status` is `""` for "no submission
/// yet" (a real Go zero-value string, not null). Quiz roll-up fields are
/// populated only for `assignmentType == 'quiz'`.
@freezed
abstract class ParentAssignmentFeedbackItem with _$ParentAssignmentFeedbackItem {
  const factory ParentAssignmentFeedbackItem({
    required int assignmentId,
    required String title,
    required String lessonTitle,
    required String assignmentType,
    required int points,
    required String status,
    int? score,
    String? teacherFeedback,
    DateTime? submittedAt,
    DateTime? checkedAt,
    int? quizAttempts,
    int? quizBestPercent,
    bool? quizPassed,
  }) = _ParentAssignmentFeedbackItem;
  factory ParentAssignmentFeedbackItem.fromJson(Map<String, dynamic> json) => _$ParentAssignmentFeedbackItemFromJson(json);
}

/// Mirrors `ChildCourseDetail` (GET /parent/children/:id/courses/:courseId).
@freezed
abstract class ParentChildCourseDetail with _$ParentChildCourseDetail {
  const factory ParentChildCourseDetail({
    required ParentChildBrief child,
    required ParentCourseBrief course,
    required ParentProgressBrief progress,
    @Default([]) List<ParentLessonProgressItem> lessons,
    @Default([]) List<ParentAssignmentFeedbackItem> assignments,
  }) = _ParentChildCourseDetail;
  factory ParentChildCourseDetail.fromJson(Map<String, dynamic> json) => _$ParentChildCourseDetailFromJson(json);
}

/// Mirrors `ActivityItem` — `type` is a free-form event kind (e.g.
/// "lesson_completed", "assignment_graded") set by the backend; rendered
/// generically rather than switched on an invented closed set.
@freezed
abstract class ParentActivityItem with _$ParentActivityItem {
  const factory ParentActivityItem({
    required String type,
    required DateTime at,
    required String courseTitle,
    required String lessonTitle,
    String? assignmentTitle,
    int? score,
    int? points,
  }) = _ParentActivityItem;
  factory ParentActivityItem.fromJson(Map<String, dynamic> json) => _$ParentActivityItemFromJson(json);
}

/// Mirrors `ActivitySummary` (GET /parent/children/:id/activity).
@freezed
abstract class ParentActivitySummary with _$ParentActivitySummary {
  const factory ParentActivitySummary({
    required ParentChildBrief child,
    @Default([]) List<ParentActivityItem> items,
  }) = _ParentActivitySummary;
  factory ParentActivitySummary.fromJson(Map<String, dynamic> json) => _$ParentActivitySummaryFromJson(json);
}
