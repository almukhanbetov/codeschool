// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssignmentImpl _$$AssignmentImplFromJson(Map<String, dynamic> json) =>
    _$AssignmentImpl(
      id: (json['id'] as num).toInt(),
      lessonId: (json['lessonId'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      assignmentType: json['assignmentType'] as String,
      starterCode: json['starterCode'] as String?,
      expectedOutput: json['expectedOutput'] as String?,
      language: json['language'] as String?,
      points: (json['points'] as num).toInt(),
      position: (json['position'] as num).toInt(),
    );

Map<String, dynamic> _$$AssignmentImplToJson(_$AssignmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lessonId': instance.lessonId,
      'title': instance.title,
      'description': instance.description,
      'assignmentType': instance.assignmentType,
      'starterCode': instance.starterCode,
      'expectedOutput': instance.expectedOutput,
      'language': instance.language,
      'points': instance.points,
      'position': instance.position,
    };

_$SubmissionImpl _$$SubmissionImplFromJson(Map<String, dynamic> json) =>
    _$SubmissionImpl(
      id: (json['id'] as num).toInt(),
      assignmentId: (json['assignmentId'] as num).toInt(),
      studentId: (json['studentId'] as num).toInt(),
      code: json['code'] as String?,
      answer: json['answer'] as String?,
      status: json['status'] as String,
      score: (json['score'] as num?)?.toInt(),
      teacherFeedback: json['teacherFeedback'] as String?,
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
      checkedAt: json['checkedAt'] == null
          ? null
          : DateTime.parse(json['checkedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$SubmissionImplToJson(_$SubmissionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'assignmentId': instance.assignmentId,
      'studentId': instance.studentId,
      'code': instance.code,
      'answer': instance.answer,
      'status': instance.status,
      'score': instance.score,
      'teacherFeedback': instance.teacherFeedback,
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'checkedAt': instance.checkedAt?.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
