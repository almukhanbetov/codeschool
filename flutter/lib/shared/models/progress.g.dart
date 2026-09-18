// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LessonProgressImpl _$$LessonProgressImplFromJson(Map<String, dynamic> json) =>
    _$LessonProgressImpl(
      lessonId: (json['lessonId'] as num).toInt(),
      status: json['status'] as String,
      progressPercent: (json['progressPercent'] as num).toInt(),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$LessonProgressImplToJson(
  _$LessonProgressImpl instance,
) => <String, dynamic>{
  'lessonId': instance.lessonId,
  'status': instance.status,
  'progressPercent': instance.progressPercent,
  'startedAt': instance.startedAt?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
};

_$CourseProgressImpl _$$CourseProgressImplFromJson(Map<String, dynamic> json) =>
    _$CourseProgressImpl(
      courseId: (json['courseId'] as num).toInt(),
      title: json['title'] as String,
      completedLessons: (json['completedLessons'] as num).toInt(),
      totalLessons: (json['totalLessons'] as num).toInt(),
      progressPercent: (json['progressPercent'] as num).toInt(),
    );

Map<String, dynamic> _$$CourseProgressImplToJson(
  _$CourseProgressImpl instance,
) => <String, dynamic>{
  'courseId': instance.courseId,
  'title': instance.title,
  'completedLessons': instance.completedLessons,
  'totalLessons': instance.totalLessons,
  'progressPercent': instance.progressPercent,
};

_$CourseProgressDetailImpl _$$CourseProgressDetailImplFromJson(
  Map<String, dynamic> json,
) => _$CourseProgressDetailImpl(
  courseId: (json['courseId'] as num).toInt(),
  title: json['title'] as String,
  completedLessons: (json['completedLessons'] as num).toInt(),
  totalLessons: (json['totalLessons'] as num).toInt(),
  progressPercent: (json['progressPercent'] as num).toInt(),
  enrollmentStatus: json['enrollmentStatus'] as String,
  lessons:
      (json['lessons'] as List<dynamic>?)
          ?.map((e) => LessonProgress.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$CourseProgressDetailImplToJson(
  _$CourseProgressDetailImpl instance,
) => <String, dynamic>{
  'courseId': instance.courseId,
  'title': instance.title,
  'completedLessons': instance.completedLessons,
  'totalLessons': instance.totalLessons,
  'progressPercent': instance.progressPercent,
  'enrollmentStatus': instance.enrollmentStatus,
  'lessons': instance.lessons,
};

_$CompleteLessonResultImpl _$$CompleteLessonResultImplFromJson(
  Map<String, dynamic> json,
) => _$CompleteLessonResultImpl(
  lesson: LessonProgress.fromJson(json['lesson'] as Map<String, dynamic>),
  course: CourseProgress.fromJson(json['course'] as Map<String, dynamic>),
  enrollmentCompleted: json['enrollmentCompleted'] as bool,
);

Map<String, dynamic> _$$CompleteLessonResultImplToJson(
  _$CompleteLessonResultImpl instance,
) => <String, dynamic>{
  'lesson': instance.lesson,
  'course': instance.course,
  'enrollmentCompleted': instance.enrollmentCompleted,
};
