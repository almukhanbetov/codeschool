// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrollment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CourseBriefImpl _$$CourseBriefImplFromJson(Map<String, dynamic> json) =>
    _$CourseBriefImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      slug: json['slug'] as String,
      shortDescription: json['shortDescription'] as String?,
      imageUrl: json['imageUrl'] as String?,
      durationLessons: (json['durationLessons'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CourseBriefImplToJson(_$CourseBriefImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'slug': instance.slug,
      'shortDescription': instance.shortDescription,
      'imageUrl': instance.imageUrl,
      'durationLessons': instance.durationLessons,
    };

_$EnrollmentImpl _$$EnrollmentImplFromJson(Map<String, dynamic> json) =>
    _$EnrollmentImpl(
      id: (json['id'] as num).toInt(),
      studentId: (json['studentId'] as num).toInt(),
      courseId: (json['courseId'] as num).toInt(),
      status: json['status'] as String,
      enrolledAt: DateTime.parse(json['enrolledAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$EnrollmentImplToJson(_$EnrollmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'courseId': instance.courseId,
      'status': instance.status,
      'enrolledAt': instance.enrolledAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };

_$MyCourseItemImpl _$$MyCourseItemImplFromJson(Map<String, dynamic> json) =>
    _$MyCourseItemImpl(
      enrollmentId: (json['enrollmentId'] as num).toInt(),
      status: json['status'] as String,
      enrolledAt: DateTime.parse(json['enrolledAt'] as String),
      course: CourseBrief.fromJson(json['course'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$MyCourseItemImplToJson(_$MyCourseItemImpl instance) =>
    <String, dynamic>{
      'enrollmentId': instance.enrollmentId,
      'status': instance.status,
      'enrolledAt': instance.enrolledAt.toIso8601String(),
      'course': instance.course,
    };
