import 'package:freezed_annotation/freezed_annotation.dart';

part 'enrollment.freezed.dart';
part 'enrollment.g.dart';

/// Mirrors backend/internal/enrollments `CourseBrief` (nested inside
/// `MyCourseItem`, GET /me/courses).
@freezed
abstract class CourseBrief with _$CourseBrief {
  const factory CourseBrief({
    required int id,
    required String title,
    required String slug,
    String? shortDescription,
    String? imageUrl,
    int? durationLessons,
  }) = _CourseBrief;

  factory CourseBrief.fromJson(Map<String, dynamic> json) => _$CourseBriefFromJson(json);
}

/// Mirrors `enrollments.Response` (POST /courses/:id/enroll) — status is
/// 'active' | 'completed' | 'cancelled' (migration 00008 CHECK constraint).
@freezed
abstract class Enrollment with _$Enrollment {
  const factory Enrollment({
    required int id,
    required int studentId,
    required int courseId,
    required String status,
    required DateTime enrolledAt,
    DateTime? completedAt,
  }) = _Enrollment;

  factory Enrollment.fromJson(Map<String, dynamic> json) => _$EnrollmentFromJson(json);
}

/// Mirrors `MyCourseItem` (GET /me/courses) — status is 'active' | 'completed'
/// | 'cancelled' (migration 00008 CHECK constraint).
@freezed
abstract class MyCourseItem with _$MyCourseItem {
  const factory MyCourseItem({
    required int enrollmentId,
    required String status,
    required DateTime enrolledAt,
    required CourseBrief course,
  }) = _MyCourseItem;

  factory MyCourseItem.fromJson(Map<String, dynamic> json) => _$MyCourseItemFromJson(json);
}
