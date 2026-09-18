// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LessonImpl _$$LessonImplFromJson(Map<String, dynamic> json) => _$LessonImpl(
  id: (json['id'] as num).toInt(),
  moduleId: (json['moduleId'] as num).toInt(),
  title: json['title'] as String,
  slug: json['slug'] as String?,
  description: json['description'] as String?,
  content: json['content'] as String?,
  videoUrl: json['videoUrl'] as String?,
  lessonType: json['lessonType'] as String,
  position: (json['position'] as num).toInt(),
);

Map<String, dynamic> _$$LessonImplToJson(_$LessonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'moduleId': instance.moduleId,
      'title': instance.title,
      'slug': instance.slug,
      'description': instance.description,
      'content': instance.content,
      'videoUrl': instance.videoUrl,
      'lessonType': instance.lessonType,
      'position': instance.position,
    };

_$CourseModuleImpl _$$CourseModuleImplFromJson(Map<String, dynamic> json) =>
    _$CourseModuleImpl(
      id: (json['id'] as num).toInt(),
      courseId: (json['courseId'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      position: (json['position'] as num).toInt(),
      lessons:
          (json['lessons'] as List<dynamic>?)
              ?.map((e) => Lesson.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CourseModuleImplToJson(_$CourseModuleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'courseId': instance.courseId,
      'title': instance.title,
      'description': instance.description,
      'position': instance.position,
      'lessons': instance.lessons,
    };
