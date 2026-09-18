// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AcademyCourseCardImpl _$$AcademyCourseCardImplFromJson(
  Map<String, dynamic> json,
) => _$AcademyCourseCardImpl(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  slug: json['slug'] as String,
  shortDescription: json['shortDescription'] as String?,
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  difficulty: json['difficulty'] as String?,
  audience: json['audience'] as String,
  totalLessons: (json['totalLessons'] as num).toInt(),
  enrolled: json['enrolled'] as bool,
);

Map<String, dynamic> _$$AcademyCourseCardImplToJson(
  _$AcademyCourseCardImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'slug': instance.slug,
  'shortDescription': instance.shortDescription,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'difficulty': instance.difficulty,
  'audience': instance.audience,
  'totalLessons': instance.totalLessons,
  'enrolled': instance.enrolled,
};

_$AcademyMyCourseImpl _$$AcademyMyCourseImplFromJson(
  Map<String, dynamic> json,
) => _$AcademyMyCourseImpl(
  courseId: (json['courseId'] as num).toInt(),
  title: json['title'] as String,
  slug: json['slug'] as String,
  shortDescription: json['shortDescription'] as String?,
  imageUrl: json['imageUrl'] as String?,
  difficulty: json['difficulty'] as String?,
  enrollmentStatus: json['enrollmentStatus'] as String,
  enrolledAt: DateTime.parse(json['enrolledAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  completedLessons: (json['completedLessons'] as num).toInt(),
  totalLessons: (json['totalLessons'] as num).toInt(),
  progressPercent: (json['progressPercent'] as num).toInt(),
  courseCompleted: json['courseCompleted'] as bool,
  certificateEligible: json['certificateEligible'] as bool,
);

Map<String, dynamic> _$$AcademyMyCourseImplToJson(
  _$AcademyMyCourseImpl instance,
) => <String, dynamic>{
  'courseId': instance.courseId,
  'title': instance.title,
  'slug': instance.slug,
  'shortDescription': instance.shortDescription,
  'imageUrl': instance.imageUrl,
  'difficulty': instance.difficulty,
  'enrollmentStatus': instance.enrollmentStatus,
  'enrolledAt': instance.enrolledAt.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'completedLessons': instance.completedLessons,
  'totalLessons': instance.totalLessons,
  'progressPercent': instance.progressPercent,
  'courseCompleted': instance.courseCompleted,
  'certificateEligible': instance.certificateEligible,
};

_$AcademyDashboardImpl _$$AcademyDashboardImplFromJson(
  Map<String, dynamic> json,
) => _$AcademyDashboardImpl(
  coursesInProgress: (json['coursesInProgress'] as num).toInt(),
  coursesCompleted: (json['coursesCompleted'] as num).toInt(),
  totalCourses: (json['totalCourses'] as num).toInt(),
  overallPercent: (json['overallPercent'] as num).toInt(),
  courses:
      (json['courses'] as List<dynamic>?)
          ?.map((e) => AcademyMyCourse.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$AcademyDashboardImplToJson(
  _$AcademyDashboardImpl instance,
) => <String, dynamic>{
  'coursesInProgress': instance.coursesInProgress,
  'coursesCompleted': instance.coursesCompleted,
  'totalCourses': instance.totalCourses,
  'overallPercent': instance.overallPercent,
  'courses': instance.courses,
};
