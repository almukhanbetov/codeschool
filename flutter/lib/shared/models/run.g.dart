// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RunResultImpl _$$RunResultImplFromJson(Map<String, dynamic> json) =>
    _$RunResultImpl(
      runId: (json['runId'] as num).toInt(),
      language: json['language'] as String,
      status: json['status'] as String,
      stdout: json['stdout'] as String,
      stderr: json['stderr'] as String,
      exitCode: (json['exitCode'] as num?)?.toInt(),
      timedOut: json['timedOut'] as bool,
      truncated: json['truncated'] as bool,
      durationMs: (json['durationMs'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$RunResultImplToJson(_$RunResultImpl instance) =>
    <String, dynamic>{
      'runId': instance.runId,
      'language': instance.language,
      'status': instance.status,
      'stdout': instance.stdout,
      'stderr': instance.stderr,
      'exitCode': instance.exitCode,
      'timedOut': instance.timedOut,
      'truncated': instance.truncated,
      'durationMs': instance.durationMs,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$RunHistoryItemImpl _$$RunHistoryItemImplFromJson(Map<String, dynamic> json) =>
    _$RunHistoryItemImpl(
      runId: (json['runId'] as num).toInt(),
      kind: json['kind'] as String,
      status: json['status'] as String,
      exitCode: (json['exitCode'] as num?)?.toInt(),
      durationMs: (json['durationMs'] as num?)?.toInt(),
      stdout: json['stdout'] as String,
      stderr: json['stderr'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$RunHistoryItemImplToJson(
  _$RunHistoryItemImpl instance,
) => <String, dynamic>{
  'runId': instance.runId,
  'kind': instance.kind,
  'status': instance.status,
  'exitCode': instance.exitCode,
  'durationMs': instance.durationMs,
  'stdout': instance.stdout,
  'stderr': instance.stderr,
  'createdAt': instance.createdAt.toIso8601String(),
};

_$VisibleTestImpl _$$VisibleTestImplFromJson(Map<String, dynamic> json) =>
    _$VisibleTestImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      stdin: json['stdin'] as String,
      expectedStdout: json['expectedStdout'] as String,
    );

Map<String, dynamic> _$$VisibleTestImplToJson(_$VisibleTestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'stdin': instance.stdin,
      'expectedStdout': instance.expectedStdout,
    };

_$TestsResponseImpl _$$TestsResponseImplFromJson(Map<String, dynamic> json) =>
    _$TestsResponseImpl(
      hasTests: json['hasTests'] as bool,
      total: (json['total'] as num).toInt(),
      visible:
          (json['visible'] as List<dynamic>?)
              ?.map((e) => VisibleTest.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$TestsResponseImplToJson(_$TestsResponseImpl instance) =>
    <String, dynamic>{
      'hasTests': instance.hasTests,
      'total': instance.total,
      'visible': instance.visible,
    };

_$TestOutcomeImpl _$$TestOutcomeImplFromJson(Map<String, dynamic> json) =>
    _$TestOutcomeImpl(
      testId: (json['testId'] as num).toInt(),
      name: json['name'] as String,
      hidden: json['hidden'] as bool,
      passed: json['passed'] as bool,
      timedOut: json['timedOut'] as bool,
      stdin: json['stdin'] as String?,
      expected: json['expected'] as String?,
      got: json['got'] as String?,
      stderr: json['stderr'] as String?,
    );

Map<String, dynamic> _$$TestOutcomeImplToJson(_$TestOutcomeImpl instance) =>
    <String, dynamic>{
      'testId': instance.testId,
      'name': instance.name,
      'hidden': instance.hidden,
      'passed': instance.passed,
      'timedOut': instance.timedOut,
      'stdin': instance.stdin,
      'expected': instance.expected,
      'got': instance.got,
      'stderr': instance.stderr,
    };

_$GradeResultImpl _$$GradeResultImplFromJson(Map<String, dynamic> json) =>
    _$GradeResultImpl(
      submissionId: (json['submissionId'] as num).toInt(),
      status: json['status'] as String,
      passed: json['passed'] as bool,
      score: (json['score'] as num?)?.toInt(),
      points: (json['points'] as num).toInt(),
      percent: (json['percent'] as num).toInt(),
      testsPassed: (json['testsPassed'] as num).toInt(),
      testsTotal: (json['testsTotal'] as num).toInt(),
      feedback: json['feedback'] as String,
      outcomes:
          (json['outcomes'] as List<dynamic>?)
              ?.map((e) => TestOutcome.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$GradeResultImplToJson(_$GradeResultImpl instance) =>
    <String, dynamic>{
      'submissionId': instance.submissionId,
      'status': instance.status,
      'passed': instance.passed,
      'score': instance.score,
      'points': instance.points,
      'percent': instance.percent,
      'testsPassed': instance.testsPassed,
      'testsTotal': instance.testsTotal,
      'feedback': instance.feedback,
      'outcomes': instance.outcomes,
    };
