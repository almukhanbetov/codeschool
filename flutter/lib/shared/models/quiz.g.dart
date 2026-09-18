// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudentOptionImpl _$$StudentOptionImplFromJson(Map<String, dynamic> json) =>
    _$StudentOptionImpl(
      id: (json['id'] as num).toInt(),
      optionText: json['optionText'] as String,
      position: (json['position'] as num).toInt(),
    );

Map<String, dynamic> _$$StudentOptionImplToJson(_$StudentOptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'optionText': instance.optionText,
      'position': instance.position,
    };

_$StudentQuestionImpl _$$StudentQuestionImplFromJson(
  Map<String, dynamic> json,
) => _$StudentQuestionImpl(
  id: (json['id'] as num).toInt(),
  questionText: json['questionText'] as String,
  questionType: json['questionType'] as String,
  points: (json['points'] as num).toInt(),
  position: (json['position'] as num).toInt(),
  options:
      (json['options'] as List<dynamic>?)
          ?.map((e) => StudentOption.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$StudentQuestionImplToJson(
  _$StudentQuestionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'questionText': instance.questionText,
  'questionType': instance.questionType,
  'points': instance.points,
  'position': instance.position,
  'options': instance.options,
};

_$StudentQuizImpl _$$StudentQuizImplFromJson(Map<String, dynamic> json) =>
    _$StudentQuizImpl(
      assignmentId: (json['assignmentId'] as num).toInt(),
      title: json['title'] as String,
      passPercent: (json['passPercent'] as num).toInt(),
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((e) => StudentQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$StudentQuizImplToJson(_$StudentQuizImpl instance) =>
    <String, dynamic>{
      'assignmentId': instance.assignmentId,
      'title': instance.title,
      'passPercent': instance.passPercent,
      'questions': instance.questions,
    };

_$AttemptBriefImpl _$$AttemptBriefImplFromJson(Map<String, dynamic> json) =>
    _$AttemptBriefImpl(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
    );

Map<String, dynamic> _$$AttemptBriefImplToJson(_$AttemptBriefImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'startedAt': instance.startedAt.toIso8601String(),
      'submittedAt': instance.submittedAt?.toIso8601String(),
    };

_$StartAttemptResponseImpl _$$StartAttemptResponseImplFromJson(
  Map<String, dynamic> json,
) => _$StartAttemptResponseImpl(
  attempt: AttemptBrief.fromJson(json['attempt'] as Map<String, dynamic>),
  quiz: StudentQuiz.fromJson(json['quiz'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$StartAttemptResponseImplToJson(
  _$StartAttemptResponseImpl instance,
) => <String, dynamic>{'attempt': instance.attempt, 'quiz': instance.quiz};

_$ResultOptionImpl _$$ResultOptionImplFromJson(Map<String, dynamic> json) =>
    _$ResultOptionImpl(
      id: (json['id'] as num).toInt(),
      optionText: json['optionText'] as String,
      position: (json['position'] as num).toInt(),
      selected: json['selected'] as bool,
      isCorrect: json['isCorrect'] as bool?,
    );

Map<String, dynamic> _$$ResultOptionImplToJson(_$ResultOptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'optionText': instance.optionText,
      'position': instance.position,
      'selected': instance.selected,
      'isCorrect': instance.isCorrect,
    };

_$ResultQuestionImpl _$$ResultQuestionImplFromJson(Map<String, dynamic> json) =>
    _$ResultQuestionImpl(
      questionId: (json['questionId'] as num).toInt(),
      questionText: json['questionText'] as String,
      questionType: json['questionType'] as String,
      points: (json['points'] as num).toInt(),
      pointsAwarded: (json['pointsAwarded'] as num).toInt(),
      isCorrect: json['isCorrect'] as bool,
      explanation: json['explanation'] as String?,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => ResultOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ResultQuestionImplToJson(
  _$ResultQuestionImpl instance,
) => <String, dynamic>{
  'questionId': instance.questionId,
  'questionText': instance.questionText,
  'questionType': instance.questionType,
  'points': instance.points,
  'pointsAwarded': instance.pointsAwarded,
  'isCorrect': instance.isCorrect,
  'explanation': instance.explanation,
  'options': instance.options,
};

_$AttemptResultImpl _$$AttemptResultImplFromJson(Map<String, dynamic> json) =>
    _$AttemptResultImpl(
      attemptId: (json['attemptId'] as num).toInt(),
      assignmentId: (json['assignmentId'] as num).toInt(),
      status: json['status'] as String,
      score: (json['score'] as num).toInt(),
      maxScore: (json['maxScore'] as num).toInt(),
      percent: (json['percent'] as num).toInt(),
      passed: json['passed'] as bool,
      passPercent: (json['passPercent'] as num).toInt(),
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
      showCorrectAnswers: json['showCorrectAnswers'] as bool,
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((e) => ResultQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$AttemptResultImplToJson(_$AttemptResultImpl instance) =>
    <String, dynamic>{
      'attemptId': instance.attemptId,
      'assignmentId': instance.assignmentId,
      'status': instance.status,
      'score': instance.score,
      'maxScore': instance.maxScore,
      'percent': instance.percent,
      'passed': instance.passed,
      'passPercent': instance.passPercent,
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'showCorrectAnswers': instance.showCorrectAnswers,
      'questions': instance.questions,
    };

_$AttemptDetailImpl _$$AttemptDetailImplFromJson(Map<String, dynamic> json) =>
    _$AttemptDetailImpl(
      attempt: AttemptBrief.fromJson(json['attempt'] as Map<String, dynamic>),
      quiz: json['quiz'] == null
          ? null
          : StudentQuiz.fromJson(json['quiz'] as Map<String, dynamic>),
      result: json['result'] == null
          ? null
          : AttemptResult.fromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AttemptDetailImplToJson(_$AttemptDetailImpl instance) =>
    <String, dynamic>{
      'attempt': instance.attempt,
      'quiz': instance.quiz,
      'result': instance.result,
    };

_$QuizHistoryItemImpl _$$QuizHistoryItemImplFromJson(
  Map<String, dynamic> json,
) => _$QuizHistoryItemImpl(
  attemptId: (json['attemptId'] as num).toInt(),
  attemptNumber: (json['attemptNumber'] as num).toInt(),
  status: json['status'] as String,
  score: (json['score'] as num?)?.toInt(),
  maxScore: (json['maxScore'] as num?)?.toInt(),
  percent: (json['percent'] as num?)?.toInt(),
  passed: json['passed'] as bool?,
  startedAt: DateTime.parse(json['startedAt'] as String),
  submittedAt: json['submittedAt'] == null
      ? null
      : DateTime.parse(json['submittedAt'] as String),
);

Map<String, dynamic> _$$QuizHistoryItemImplToJson(
  _$QuizHistoryItemImpl instance,
) => <String, dynamic>{
  'attemptId': instance.attemptId,
  'attemptNumber': instance.attemptNumber,
  'status': instance.status,
  'score': instance.score,
  'maxScore': instance.maxScore,
  'percent': instance.percent,
  'passed': instance.passed,
  'startedAt': instance.startedAt.toIso8601String(),
  'submittedAt': instance.submittedAt?.toIso8601String(),
};

_$QuizAttemptHistoryImpl _$$QuizAttemptHistoryImplFromJson(
  Map<String, dynamic> json,
) => _$QuizAttemptHistoryImpl(
  assignmentId: (json['assignmentId'] as num).toInt(),
  title: json['title'] as String,
  passPercent: (json['passPercent'] as num).toInt(),
  maxAttempts: (json['maxAttempts'] as num?)?.toInt(),
  attemptsUsed: (json['attemptsUsed'] as num).toInt(),
  attemptsLeft: (json['attemptsLeft'] as num?)?.toInt(),
  canStart: json['canStart'] as bool,
  passed: json['passed'] as bool,
  bestScore: (json['bestScore'] as num?)?.toInt(),
  bestMaxScore: (json['bestMaxScore'] as num?)?.toInt(),
  bestPercent: (json['bestPercent'] as num?)?.toInt(),
  inProgressId: (json['inProgressId'] as num?)?.toInt(),
  attempts:
      (json['attempts'] as List<dynamic>?)
          ?.map((e) => QuizHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$QuizAttemptHistoryImplToJson(
  _$QuizAttemptHistoryImpl instance,
) => <String, dynamic>{
  'assignmentId': instance.assignmentId,
  'title': instance.title,
  'passPercent': instance.passPercent,
  'maxAttempts': instance.maxAttempts,
  'attemptsUsed': instance.attemptsUsed,
  'attemptsLeft': instance.attemptsLeft,
  'canStart': instance.canStart,
  'passed': instance.passed,
  'bestScore': instance.bestScore,
  'bestMaxScore': instance.bestMaxScore,
  'bestPercent': instance.bestPercent,
  'inProgressId': instance.inProgressId,
  'attempts': instance.attempts,
};
