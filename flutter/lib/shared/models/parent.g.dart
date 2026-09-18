// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ParentChildBriefImpl _$$ParentChildBriefImplFromJson(
  Map<String, dynamic> json,
) => _$ParentChildBriefImpl(
  id: (json['id'] as num).toInt(),
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String?,
);

Map<String, dynamic> _$$ParentChildBriefImplToJson(
  _$ParentChildBriefImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
};

_$ParentCourseBriefImpl _$$ParentCourseBriefImplFromJson(
  Map<String, dynamic> json,
) => _$ParentCourseBriefImpl(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  slug: json['slug'] as String,
);

Map<String, dynamic> _$$ParentCourseBriefImplToJson(
  _$ParentCourseBriefImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'slug': instance.slug,
};

_$ParentProgressBriefImpl _$$ParentProgressBriefImplFromJson(
  Map<String, dynamic> json,
) => _$ParentProgressBriefImpl(
  completedLessons: (json['completedLessons'] as num).toInt(),
  totalLessons: (json['totalLessons'] as num).toInt(),
  progressPercent: (json['progressPercent'] as num).toInt(),
);

Map<String, dynamic> _$$ParentProgressBriefImplToJson(
  _$ParentProgressBriefImpl instance,
) => <String, dynamic>{
  'completedLessons': instance.completedLessons,
  'totalLessons': instance.totalLessons,
  'progressPercent': instance.progressPercent,
};

_$ParentChildListItemImpl _$$ParentChildListItemImplFromJson(
  Map<String, dynamic> json,
) => _$ParentChildListItemImpl(
  child: ParentChildBrief.fromJson(json['child'] as Map<String, dynamic>),
  coursesCount: (json['coursesCount'] as num).toInt(),
  overallProgressPercent: (json['overallProgressPercent'] as num).toInt(),
  pendingReview: (json['pendingReview'] as num).toInt(),
  needsWork: (json['needsWork'] as num).toInt(),
);

Map<String, dynamic> _$$ParentChildListItemImplToJson(
  _$ParentChildListItemImpl instance,
) => <String, dynamic>{
  'child': instance.child,
  'coursesCount': instance.coursesCount,
  'overallProgressPercent': instance.overallProgressPercent,
  'pendingReview': instance.pendingReview,
  'needsWork': instance.needsWork,
};

_$ParentChildCourseProgressImpl _$$ParentChildCourseProgressImplFromJson(
  Map<String, dynamic> json,
) => _$ParentChildCourseProgressImpl(
  course: ParentCourseBrief.fromJson(json['course'] as Map<String, dynamic>),
  enrollmentStatus: json['enrollmentStatus'] as String,
  progress: ParentProgressBrief.fromJson(
    json['progress'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$$ParentChildCourseProgressImplToJson(
  _$ParentChildCourseProgressImpl instance,
) => <String, dynamic>{
  'course': instance.course,
  'enrollmentStatus': instance.enrollmentStatus,
  'progress': instance.progress,
};

_$ParentChildOverviewImpl _$$ParentChildOverviewImplFromJson(
  Map<String, dynamic> json,
) => _$ParentChildOverviewImpl(
  child: ParentChildBrief.fromJson(json['child'] as Map<String, dynamic>),
  courses:
      (json['courses'] as List<dynamic>?)
          ?.map(
            (e) =>
                ParentChildCourseProgress.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ParentChildOverviewImplToJson(
  _$ParentChildOverviewImpl instance,
) => <String, dynamic>{'child': instance.child, 'courses': instance.courses};

_$ParentLessonProgressItemImpl _$$ParentLessonProgressItemImplFromJson(
  Map<String, dynamic> json,
) => _$ParentLessonProgressItemImpl(
  lessonId: (json['lessonId'] as num).toInt(),
  title: json['title'] as String,
  status: json['status'] as String,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$$ParentLessonProgressItemImplToJson(
  _$ParentLessonProgressItemImpl instance,
) => <String, dynamic>{
  'lessonId': instance.lessonId,
  'title': instance.title,
  'status': instance.status,
  'completedAt': instance.completedAt?.toIso8601String(),
};

_$ParentAssignmentFeedbackItemImpl _$$ParentAssignmentFeedbackItemImplFromJson(
  Map<String, dynamic> json,
) => _$ParentAssignmentFeedbackItemImpl(
  assignmentId: (json['assignmentId'] as num).toInt(),
  title: json['title'] as String,
  lessonTitle: json['lessonTitle'] as String,
  assignmentType: json['assignmentType'] as String,
  points: (json['points'] as num).toInt(),
  status: json['status'] as String,
  score: (json['score'] as num?)?.toInt(),
  teacherFeedback: json['teacherFeedback'] as String?,
  submittedAt: json['submittedAt'] == null
      ? null
      : DateTime.parse(json['submittedAt'] as String),
  checkedAt: json['checkedAt'] == null
      ? null
      : DateTime.parse(json['checkedAt'] as String),
  quizAttempts: (json['quizAttempts'] as num?)?.toInt(),
  quizBestPercent: (json['quizBestPercent'] as num?)?.toInt(),
  quizPassed: json['quizPassed'] as bool?,
);

Map<String, dynamic> _$$ParentAssignmentFeedbackItemImplToJson(
  _$ParentAssignmentFeedbackItemImpl instance,
) => <String, dynamic>{
  'assignmentId': instance.assignmentId,
  'title': instance.title,
  'lessonTitle': instance.lessonTitle,
  'assignmentType': instance.assignmentType,
  'points': instance.points,
  'status': instance.status,
  'score': instance.score,
  'teacherFeedback': instance.teacherFeedback,
  'submittedAt': instance.submittedAt?.toIso8601String(),
  'checkedAt': instance.checkedAt?.toIso8601String(),
  'quizAttempts': instance.quizAttempts,
  'quizBestPercent': instance.quizBestPercent,
  'quizPassed': instance.quizPassed,
};

_$ParentChildCourseDetailImpl _$$ParentChildCourseDetailImplFromJson(
  Map<String, dynamic> json,
) => _$ParentChildCourseDetailImpl(
  child: ParentChildBrief.fromJson(json['child'] as Map<String, dynamic>),
  course: ParentCourseBrief.fromJson(json['course'] as Map<String, dynamic>),
  progress: ParentProgressBrief.fromJson(
    json['progress'] as Map<String, dynamic>,
  ),
  lessons:
      (json['lessons'] as List<dynamic>?)
          ?.map(
            (e) => ParentLessonProgressItem.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  assignments:
      (json['assignments'] as List<dynamic>?)
          ?.map(
            (e) => ParentAssignmentFeedbackItem.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ParentChildCourseDetailImplToJson(
  _$ParentChildCourseDetailImpl instance,
) => <String, dynamic>{
  'child': instance.child,
  'course': instance.course,
  'progress': instance.progress,
  'lessons': instance.lessons,
  'assignments': instance.assignments,
};

_$ParentActivityItemImpl _$$ParentActivityItemImplFromJson(
  Map<String, dynamic> json,
) => _$ParentActivityItemImpl(
  type: json['type'] as String,
  at: DateTime.parse(json['at'] as String),
  courseTitle: json['courseTitle'] as String,
  lessonTitle: json['lessonTitle'] as String,
  assignmentTitle: json['assignmentTitle'] as String?,
  score: (json['score'] as num?)?.toInt(),
  points: (json['points'] as num?)?.toInt(),
);

Map<String, dynamic> _$$ParentActivityItemImplToJson(
  _$ParentActivityItemImpl instance,
) => <String, dynamic>{
  'type': instance.type,
  'at': instance.at.toIso8601String(),
  'courseTitle': instance.courseTitle,
  'lessonTitle': instance.lessonTitle,
  'assignmentTitle': instance.assignmentTitle,
  'score': instance.score,
  'points': instance.points,
};

_$ParentActivitySummaryImpl _$$ParentActivitySummaryImplFromJson(
  Map<String, dynamic> json,
) => _$ParentActivitySummaryImpl(
  child: ParentChildBrief.fromJson(json['child'] as Map<String, dynamic>),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => ParentActivityItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ParentActivitySummaryImplToJson(
  _$ParentActivitySummaryImpl instance,
) => <String, dynamic>{'child': instance.child, 'items': instance.items};
