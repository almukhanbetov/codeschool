import 'package:freezed_annotation/freezed_annotation.dart';

part 'assignment.freezed.dart';
part 'assignment.g.dart';

/// Mirrors backend/internal/assignments/dto.go `Response`. `assignmentType`
/// is one of the real, existing values only: text | code | quiz | project
/// (migration 00009 CHECK constraint) — no new type invented on the client.
@freezed
abstract class Assignment with _$Assignment {
  const factory Assignment({
    required int id,
    required int lessonId,
    required String title,
    String? description,
    required String assignmentType,
    String? starterCode,
    String? expectedOutput,
    String? language,
    required int points,
    required int position,
  }) = _Assignment;

  factory Assignment.fromJson(Map<String, dynamic> json) => _$AssignmentFromJson(json);
}

/// Mirrors backend/internal/submissions/dto.go `Response`.
@freezed
abstract class Submission with _$Submission {
  const factory Submission({
    required int id,
    required int assignmentId,
    required int studentId,
    String? code,
    String? answer,
    required String status,
    int? score,
    String? teacherFeedback,
    DateTime? submittedAt,
    DateTime? checkedAt,
    required DateTime updatedAt,
  }) = _Submission;

  factory Submission.fromJson(Map<String, dynamic> json) => _$SubmissionFromJson(json);
}
