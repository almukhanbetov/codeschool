import 'package:freezed_annotation/freezed_annotation.dart';

part 'teacher.freezed.dart';
part 'teacher.g.dart';

/// Mirrors backend/internal/groups/dto.go `CourseBrief`.
@freezed
abstract class TeacherCourseBrief with _$TeacherCourseBrief {
  const factory TeacherCourseBrief({required int id, required String title, required String slug}) = _TeacherCourseBrief;
  factory TeacherCourseBrief.fromJson(Map<String, dynamic> json) => _$TeacherCourseBriefFromJson(json);
}

/// Mirrors `StudentBrief` — deliberately no email/phone (backend never
/// sends them to a teacher).
@freezed
abstract class TeacherStudentBrief with _$TeacherStudentBrief {
  const factory TeacherStudentBrief({required int id, required String firstName, String? lastName}) = _TeacherStudentBrief;
  factory TeacherStudentBrief.fromJson(Map<String, dynamic> json) => _$TeacherStudentBriefFromJson(json);
}

@freezed
abstract class TeacherProgressBrief with _$TeacherProgressBrief {
  const factory TeacherProgressBrief({
    required int completedLessons,
    required int totalLessons,
    required int progressPercent,
  }) = _TeacherProgressBrief;
  factory TeacherProgressBrief.fromJson(Map<String, dynamic> json) => _$TeacherProgressBriefFromJson(json);
}

/// Mirrors `Dashboard` (GET /teacher/dashboard).
@freezed
abstract class TeacherDashboard with _$TeacherDashboard {
  const factory TeacherDashboard({
    required int groupsCount,
    required int studentsCount,
    required int pendingSubmissions,
    required int reviewedSubmissions,
  }) = _TeacherDashboard;
  factory TeacherDashboard.fromJson(Map<String, dynamic> json) => _$TeacherDashboardFromJson(json);
}

/// Mirrors `GroupListItem` (GET /teacher/groups) — status is 'draft' |
/// 'active' | 'completed' | 'cancelled' (migration 00012 CHECK constraint).
@freezed
abstract class TeacherGroupListItem with _$TeacherGroupListItem {
  const factory TeacherGroupListItem({
    required int id,
    required String title,
    required String status,
    required int studentCount,
    required int avgProgressPercent,
    DateTime? startDate,
    required TeacherCourseBrief course,
  }) = _TeacherGroupListItem;
  factory TeacherGroupListItem.fromJson(Map<String, dynamic> json) => _$TeacherGroupListItemFromJson(json);
}

/// Mirrors `GroupDetail` (GET /teacher/groups/:id) — a Go-embedded
/// `GroupListItem` flattened into the same JSON level.
@freezed
abstract class TeacherGroupDetail with _$TeacherGroupDetail {
  const factory TeacherGroupDetail({
    required int id,
    required String title,
    required String status,
    required int studentCount,
    required int avgProgressPercent,
    DateTime? startDate,
    required TeacherCourseBrief course,
    String? description,
    DateTime? endDate,
    int? maxStudents,
  }) = _TeacherGroupDetail;
  factory TeacherGroupDetail.fromJson(Map<String, dynamic> json) => _$TeacherGroupDetailFromJson(json);
}

/// Mirrors `GroupStudentItem` (GET /teacher/groups/:id/students).
@freezed
abstract class TeacherGroupStudentItem with _$TeacherGroupStudentItem {
  const factory TeacherGroupStudentItem({
    required TeacherStudentBrief student,
    required TeacherProgressBrief progress,
    required int pendingSubmissions,
    required DateTime joinedAt,
  }) = _TeacherGroupStudentItem;
  factory TeacherGroupStudentItem.fromJson(Map<String, dynamic> json) => _$TeacherGroupStudentItemFromJson(json);
}

@freezed
abstract class TeacherLessonProgressItem with _$TeacherLessonProgressItem {
  const factory TeacherLessonProgressItem({
    required int lessonId,
    required String title,
    required String status,
    DateTime? completedAt,
  }) = _TeacherLessonProgressItem;
  factory TeacherLessonProgressItem.fromJson(Map<String, dynamic> json) => _$TeacherLessonProgressItemFromJson(json);
}

/// `status` is `""` when the student has no submission yet — never null,
/// per the Go comment on the field (matches JSON `""` for a Go zero-value
/// string, not `null`).
@freezed
abstract class TeacherSubmissionSummaryItem with _$TeacherSubmissionSummaryItem {
  const factory TeacherSubmissionSummaryItem({
    int? submissionId,
    required int assignmentId,
    required String assignmentTitle,
    required String lessonTitle,
    required int points,
    required String status,
    int? score,
    DateTime? submittedAt,
  }) = _TeacherSubmissionSummaryItem;
  factory TeacherSubmissionSummaryItem.fromJson(Map<String, dynamic> json) => _$TeacherSubmissionSummaryItemFromJson(json);
}

@freezed
abstract class TeacherQuizResultItem with _$TeacherQuizResultItem {
  const factory TeacherQuizResultItem({
    required int assignmentId,
    required String title,
    required String lessonTitle,
    required int attempts,
    int? bestPercent,
    required bool passed,
  }) = _TeacherQuizResultItem;
  factory TeacherQuizResultItem.fromJson(Map<String, dynamic> json) => _$TeacherQuizResultItemFromJson(json);
}

/// Mirrors `StudentDetail` (GET /teacher/groups/:id/students/:studentId).
@freezed
abstract class TeacherStudentDetail with _$TeacherStudentDetail {
  const factory TeacherStudentDetail({
    required TeacherStudentBrief student,
    required TeacherCourseBrief course,
    required TeacherProgressBrief progress,
    @Default([]) List<TeacherLessonProgressItem> lessons,
    @Default([]) List<TeacherSubmissionSummaryItem> submissions,
    @Default([]) List<TeacherQuizResultItem> quizResults,
  }) = _TeacherStudentDetail;
  factory TeacherStudentDetail.fromJson(Map<String, dynamic> json) => _$TeacherStudentDetailFromJson(json);
}

@freezed
abstract class TeacherLessonBrief with _$TeacherLessonBrief {
  const factory TeacherLessonBrief({required int id, required String title}) = _TeacherLessonBrief;
  factory TeacherLessonBrief.fromJson(Map<String, dynamic> json) => _$TeacherLessonBriefFromJson(json);
}

@freezed
abstract class TeacherAssignmentBrief with _$TeacherAssignmentBrief {
  const factory TeacherAssignmentBrief({required int id, required String title, required int points}) = _TeacherAssignmentBrief;
  factory TeacherAssignmentBrief.fromJson(Map<String, dynamic> json) => _$TeacherAssignmentBriefFromJson(json);
}

/// Mirrors `SubmissionListItem` (GET /teacher/submissions).
@freezed
abstract class TeacherSubmissionListItem with _$TeacherSubmissionListItem {
  const factory TeacherSubmissionListItem({
    required int id,
    required String status,
    DateTime? submittedAt,
    required TeacherStudentBrief student,
    required TeacherCourseBrief course,
    required TeacherLessonBrief lesson,
    required TeacherAssignmentBrief assignment,
  }) = _TeacherSubmissionListItem;
  factory TeacherSubmissionListItem.fromJson(Map<String, dynamic> json) => _$TeacherSubmissionListItemFromJson(json);
}

/// Mirrors the paginated envelope of GET /teacher/submissions (`meta`, not
/// `data` — this repository reads it from the response's own `meta` key).
@freezed
abstract class TeacherSubmissionListMeta with _$TeacherSubmissionListMeta {
  const factory TeacherSubmissionListMeta({required int page, required int limit, required int total}) =
      _TeacherSubmissionListMeta;
  factory TeacherSubmissionListMeta.fromJson(Map<String, dynamic> json) => _$TeacherSubmissionListMetaFromJson(json);
}

@freezed
abstract class TeacherSubmissionListResult with _$TeacherSubmissionListResult {
  const factory TeacherSubmissionListResult({
    required List<TeacherSubmissionListItem> items,
    required TeacherSubmissionListMeta meta,
  }) = _TeacherSubmissionListResult;
}

/// The three anonymous Go structs embedded in `SubmissionDetail` (group,
/// module, assignment-with-content), flattened into named classes here —
/// same fields, same JSON shape, just a name for each.
@freezed
abstract class TeacherGroupRef with _$TeacherGroupRef {
  const factory TeacherGroupRef({required int id, required String title}) = _TeacherGroupRef;
  factory TeacherGroupRef.fromJson(Map<String, dynamic> json) => _$TeacherGroupRefFromJson(json);
}

@freezed
abstract class TeacherModuleRef with _$TeacherModuleRef {
  const factory TeacherModuleRef({required int id, required String title}) = _TeacherModuleRef;
  factory TeacherModuleRef.fromJson(Map<String, dynamic> json) => _$TeacherModuleRefFromJson(json);
}

@freezed
abstract class TeacherAssignmentContent with _$TeacherAssignmentContent {
  const factory TeacherAssignmentContent({
    required int id,
    required String title,
    String? description,
    required String assignmentType,
    String? starterCode,
    String? expectedOutput,
    String? language,
    required int points,
  }) = _TeacherAssignmentContent;
  factory TeacherAssignmentContent.fromJson(Map<String, dynamic> json) => _$TeacherAssignmentContentFromJson(json);
}

/// Mirrors `SubmissionDetail` (GET /teacher/submissions/:id).
@freezed
abstract class TeacherSubmissionDetail with _$TeacherSubmissionDetail {
  const factory TeacherSubmissionDetail({
    required int id,
    required String status,
    String? code,
    String? answer,
    int? score,
    String? teacherFeedback,
    DateTime? submittedAt,
    DateTime? checkedAt,
    required TeacherStudentBrief student,
    required TeacherGroupRef group,
    required TeacherCourseBrief course,
    required TeacherModuleRef module,
    required TeacherLessonBrief lesson,
    required TeacherAssignmentContent assignment,
  }) = _TeacherSubmissionDetail;
  factory TeacherSubmissionDetail.fromJson(Map<String, dynamic> json) => _$TeacherSubmissionDetailFromJson(json);
}
