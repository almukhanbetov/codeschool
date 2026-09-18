import 'package:freezed_annotation/freezed_annotation.dart';

part 'academy.freezed.dart';
part 'academy.g.dart';

/// Mirrors backend/internal/academy/dto.go `CourseCard`
/// (GET /teacher-academy/courses) — a teacher-facing catalog row, distinct
/// from the student `Course` shape (has `enrolled`/`totalLessons` inline).
@freezed
abstract class AcademyCourseCard with _$AcademyCourseCard {
  const factory AcademyCourseCard({
    required int id,
    required String title,
    required String slug,
    String? shortDescription,
    String? description,
    String? imageUrl,
    String? difficulty,
    required String audience,
    required int totalLessons,
    required bool enrolled,
  }) = _AcademyCourseCard;
  factory AcademyCourseCard.fromJson(Map<String, dynamic> json) => _$AcademyCourseCardFromJson(json);
}

/// Mirrors `MyCourse` (GET /teacher-academy/me/courses and the dashboard).
@freezed
abstract class AcademyMyCourse with _$AcademyMyCourse {
  const factory AcademyMyCourse({
    required int courseId,
    required String title,
    required String slug,
    String? shortDescription,
    String? imageUrl,
    String? difficulty,
    required String enrollmentStatus,
    required DateTime enrolledAt,
    DateTime? completedAt,
    required int completedLessons,
    required int totalLessons,
    required int progressPercent,
    required bool courseCompleted,
    required bool certificateEligible,
  }) = _AcademyMyCourse;
  factory AcademyMyCourse.fromJson(Map<String, dynamic> json) => _$AcademyMyCourseFromJson(json);
}

/// Mirrors `Dashboard` (GET /teacher-academy/dashboard).
@freezed
abstract class AcademyDashboard with _$AcademyDashboard {
  const factory AcademyDashboard({
    required int coursesInProgress,
    required int coursesCompleted,
    required int totalCourses,
    required int overallPercent,
    @Default([]) List<AcademyMyCourse> courses,
  }) = _AcademyDashboard;
  factory AcademyDashboard.fromJson(Map<String, dynamic> json) => _$AcademyDashboardFromJson(json);
}
