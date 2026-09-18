// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CourseImpl _$$CourseImplFromJson(Map<String, dynamic> json) => _$CourseImpl(
  id: (json['id'] as num).toInt(),
  levelId: (json['levelId'] as num).toInt(),
  title: json['title'] as String,
  slug: json['slug'] as String,
  description: json['description'] as String?,
  shortDescription: json['shortDescription'] as String?,
  imageUrl: json['imageUrl'] as String?,
  ageFrom: (json['ageFrom'] as num?)?.toInt(),
  ageTo: (json['ageTo'] as num?)?.toInt(),
  durationLessons: (json['durationLessons'] as num?)?.toInt(),
  projectsCount: (json['projectsCount'] as num?)?.toInt(),
  difficulty: json['difficulty'] as String?,
  audience: json['audience'] as String,
);

Map<String, dynamic> _$$CourseImplToJson(_$CourseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'levelId': instance.levelId,
      'title': instance.title,
      'slug': instance.slug,
      'description': instance.description,
      'shortDescription': instance.shortDescription,
      'imageUrl': instance.imageUrl,
      'ageFrom': instance.ageFrom,
      'ageTo': instance.ageTo,
      'durationLessons': instance.durationLessons,
      'projectsCount': instance.projectsCount,
      'difficulty': instance.difficulty,
      'audience': instance.audience,
    };
