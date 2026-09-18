// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CourseContentImpl _$$CourseContentImplFromJson(Map<String, dynamic> json) =>
    _$CourseContentImpl(
      course: Course.fromJson(json['course'] as Map<String, dynamic>),
      modules:
          (json['modules'] as List<dynamic>?)
              ?.map((e) => CourseModule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CourseContentImplToJson(_$CourseContentImpl instance) =>
    <String, dynamic>{'course': instance.course, 'modules': instance.modules};
