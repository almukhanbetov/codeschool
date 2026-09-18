// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeacherCourseBriefImpl _$$TeacherCourseBriefImplFromJson(
  Map<String, dynamic> json,
) => _$TeacherCourseBriefImpl(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  slug: json['slug'] as String,
);

Map<String, dynamic> _$$TeacherCourseBriefImplToJson(
  _$TeacherCourseBriefImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'slug': instance.slug,
};

_$TeacherStudentBriefImpl _$$TeacherStudentBriefImplFromJson(
  Map<String, dynamic> json,
) => _$TeacherStudentBriefImpl(
  id: (json['id'] as num).toInt(),
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String?,
);

Map<String, dynamic> _$$TeacherStudentBriefImplToJson(
  _$TeacherStudentBriefImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
};

_$TeacherProgressBriefImpl _$$TeacherProgressBriefImplFromJson(
  Map<String, dynamic> json,
) => _$TeacherProgressBriefImpl(
  completedLessons: (json['completedLessons'] as num).toInt(),
  totalLessons: (json['totalLessons'] as num).toInt(),
  progressPercent: (json['progressPercent'] as num).toInt(),
);

Map<String, dynamic> _$$TeacherProgressBriefImplToJson(
  _$TeacherProgressBriefImpl instance,
) => <String, dynamic>{
  'completedLessons': instance.completedLessons,
  'totalLessons': instance.totalLessons,
  'progressPercent': instance.progressPercent,
};

_$TeacherDashboardImpl _$$TeacherDashboardImplFromJson(
  Map<String, dynamic> json,
) => _$TeacherDashboardImpl(
  groupsCount: (json['groupsCount'] as num).toInt(),
  studentsCount: (json['studentsCount'] as num).toInt(),
  pendingSubmissions: (json['pendingSubmissions'] as num).toInt(),
  reviewedSubmissions: (json['reviewedSubmissions'] as num).toInt(),
);

Map<String, dynamic> _$$TeacherDashboardImplToJson(
  _$TeacherDashboardImpl instance,
) => <String, dynamic>{
  'groupsCount': instance.groupsCount,
  'studentsCount': instance.studentsCount,
  'pendingSubmissions': instance.pendingSubmissions,
  'reviewedSubmissions': instance.reviewedSubmissions,
};

_$TeacherGroupListItemImpl _$$TeacherGroupListItemImplFromJson(
  Map<String, dynamic> json,
) => _$TeacherGroupListItemImpl(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  status: json['status'] as String,
  studentCount: (json['studentCount'] as num).toInt(),
  avgProgressPercent: (json['avgProgressPercent'] as num).toInt(),
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  course: TeacherCourseBrief.fromJson(json['course'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$TeacherGroupListItemImplToJson(
  _$TeacherGroupListItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'status': instance.status,
  'studentCount': instance.studentCount,
  'avgProgressPercent': instance.avgProgressPercent,
  'startDate': instance.startDate?.toIso8601String(),
  'course': instance.course,
};

_$TeacherGroupDetailImpl _$$TeacherGroupDetailImplFromJson(
  Map<String, dynamic> json,
) => _$TeacherGroupDetailImpl(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  status: json['status'] as String,
  studentCount: (json['studentCount'] as num).toInt(),
  avgProgressPercent: (json['avgProgressPercent'] as num).toInt(),
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  course: TeacherCourseBrief.fromJson(json['course'] as Map<String, dynamic>),
  description: json['description'] as String?,
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  maxStudents: (json['maxStudents'] as num?)?.toInt(),
);

Map<String, dynamic> _$$TeacherGroupDetailImplToJson(
  _$TeacherGroupDetailImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'status': instance.status,
  'studentCount': instance.studentCount,
  'avgProgressPercent': instance.avgProgressPercent,
  'startDate': instance.startDate?.toIso8601String(),
  'course': instance.course,
  'description': instance.description,
  'endDate': instance.endDate?.toIso8601String(),
  'maxStudents': instance.maxStudents,
};

_$TeacherGroupStudentItemImpl _$$TeacherGroupStudentItemImplFromJson(
  Map<String, dynamic> json,
) => _$TeacherGroupStudentItemImpl(
  student: TeacherStudentBrief.fromJson(
    json['student'] as Map<String, dynamic>,
  ),
  progress: TeacherProgressBrief.fromJson(
    json['progress'] as Map<String, dynamic>,
  ),
  pendingSubmissions: (json['pendingSubmissions'] as num).toInt(),
  joinedAt: DateTime.parse(json['joinedAt'] as String),
);

Map<String, dynamic> _$$TeacherGroupStudentItemImplToJson(
  _$TeacherGroupStudentItemImpl instance,
) => <String, dynamic>{
  'student': instance.student,
  'progress': instance.progress,
  'pendingSubmissions': instance.pendingSubmissions,
  'joinedAt': instance.joinedAt.toIso8601String(),
};

_$TeacherLessonProgressItemImpl _$$TeacherLessonProgressItemImplFromJson(
  Map<String, dynamic> json,
) => _$TeacherLessonProgressItemImpl(
  lessonId: (json['lessonId'] as num).toInt(),
  title: json['title'] as String,
  status: json['status'] as String,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$$TeacherLessonProgressItemImplToJson(
  _$TeacherLessonProgressItemImpl instance,
) => <String, dynamic>{
  'lessonId': instance.lessonId,
  'title': instance.title,
  'status': instance.status,
  'completedAt': instance.completedAt?.toIso8601String(),
};

_$TeacherSubmissionSummaryItemImpl _$$TeacherSubmissionSummaryItemImplFromJson(
  Map<String, dynamic> json,
) => _$TeacherSubmissionSummaryItemImpl(
  submissionId: (json['submissionId'] as num?)?.toInt(),
  assignmentId: (json['assignmentId'] as num).toInt(),
  assignmentTitle: json['assignmentTitle'] as String,
  lessonTitle: json['lessonTitle'] as String,
  points: (json['points'] as num).toInt(),
  status: json['status'] as String,
  score: (json['score'] as num?)?.toInt(),
  submittedAt: json['submittedAt'] == null
      ? null
      : DateTime.parse(json['submittedAt'] as String),
);

Map<String, dynamic> _$$TeacherSubmissionSummaryItemImplToJson(
  _$TeacherSubmissionSummaryItemImpl instance,
) => <String, dynamic>{
  'submissionId': instance.submissionId,
  'assignmentId': instance.assignmentId,
  'assignmentTitle': instance.assignmentTitle,
  'lessonTitle': instance.lessonTitle,
  'points': instance.points,
  'status': instance.status,
  'score': instance.score,
  'submittedAt': instance.submittedAt?.toIso8601String(),
};

_$TeacherQuizResultItemImpl _$$TeacherQuizResultItemImplFromJson(
  Map<String, dynamic> json,
) => _$TeacherQuizResultItemImpl(
  assignmentId: (json['assignmentId'] as num).toInt(),
  title: json['title'] as String,
  lessonTitle: json['lessonTitle'] as String,
  attempts: (json['attempts'] as num).toInt(),
  bestPercent: (json['bestPercent'] as num?)?.toInt(),
  passed: json['passed'] as bool,
);

Map<String, dynamic> _$$TeacherQuizResultItemImplToJson(
  _$TeacherQuizResultItemImpl instance,
) => <String, dynamic>{
  'assignmentId': instance.assignmentId,
  'title': instance.title,
  'lessonTitle': instance.lessonTitle,
  'attempts': instance.attempts,
  'bestPercent': instance.bestPercent,
  'passed': instance.passed,
};

_$TeacherStudentDetailImpl _$$TeacherStudentDetailImplFromJson(
  Map<String, dynamic> json,
) => _$TeacherStudentDetailImpl(
  student: TeacherStudentBrief.fromJson(
    json['student'] as Map<String, dynamic>,
  ),
  course: TeacherCourseBrief.fromJson(json['course'] as Map<String, dynamic>),
  progress: TeacherProgressBrief.fromJson(
    json['progress'] as Map<String, dynamic>,
  ),
  lessons:
      (json['lessons'] as List<dynamic>?)
          ?.map(
            (e) =>
                TeacherLessonProgressItem.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  submissions:
      (json['submissions'] as List<dynamic>?)
          ?.map(
            (e) => TeacherSubmissionSummaryItem.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      const [],
  quizResults:
      (json['quizResults'] as List<dynamic>?)
          ?.map(
            (e) => TeacherQuizResultItem.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$$TeacherStudentDetailImplToJson(
  _$TeacherStudentDetailImpl instance,
) => <String, dynamic>{
  'student': instance.student,
  'course': instance.course,
  'progress': instance.progress,
  'lessons': instance.lessons,
  'submissions': instance.submissions,
  'quizResults': instance.quizResults,
};

_$TeacherLessonBriefImpl _$$TeacherLessonBriefImplFromJson(
  Map<String, dynamic> json,
) => _$TeacherLessonBriefImpl(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
);

Map<String, dynamic> _$$TeacherLessonBriefImplToJson(
  _$TeacherLessonBriefImpl instance,
) => <String, dynamic>{'id': instance.id, 'title': instance.title};

_$TeacherAssignmentBriefImpl _$$TeacherAssignmentBriefImplFromJson(
  Map<String, dynamic> json,
) => _$TeacherAssignmentBriefImpl(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  points: (json['points'] as num).toInt(),
);

Map<String, dynamic> _$$TeacherAssignmentBriefImplToJson(
  _$TeacherAssignmentBriefImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'points': instance.points,
};

_$TeacherSubmissionListItemImpl _$$TeacherSubmissionListItemImplFromJson(
  Map<String, dynamic> json,
) => _$TeacherSubmissionListItemImpl(
  id: (json['id'] as num).toInt(),
  status: json['status'] as String,
  submittedAt: json['submittedAt'] == null
      ? null
      : DateTime.parse(json['submittedAt'] as String),
  student: TeacherStudentBrief.fromJson(
    json['student'] as Map<String, dynamic>,
  ),
  course: TeacherCourseBrief.fromJson(json['course'] as Map<String, dynamic>),
  lesson: TeacherLessonBrief.fromJson(json['lesson'] as Map<String, dynamic>),
  assignment: TeacherAssignmentBrief.fromJson(
    json['assignment'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$$TeacherSubmissionListItemImplToJson(
  _$TeacherSubmissionListItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'submittedAt': instance.submittedAt?.toIso8601String(),
  'student': instance.student,
  'course': instance.course,
  'lesson': instance.lesson,
  'assignment': instance.assignment,
};

_$TeacherSubmissionListMetaImpl _$$TeacherSubmissionListMetaImplFromJson(
  Map<String, dynamic> json,
) => _$TeacherSubmissionListMetaImpl(
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$$TeacherSubmissionListMetaImplToJson(
  _$TeacherSubmissionListMetaImpl instance,
) => <String, dynamic>{
  'page': instance.page,
  'limit': instance.limit,
  'total': instance.total,
};

_$TeacherGroupRefImpl _$$TeacherGroupRefImplFromJson(
  Map<String, dynamic> json,
) => _$TeacherGroupRefImpl(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
);

Map<String, dynamic> _$$TeacherGroupRefImplToJson(
  _$TeacherGroupRefImpl instance,
) => <String, dynamic>{'id': instance.id, 'title': instance.title};

_$TeacherModuleRefImpl _$$TeacherModuleRefImplFromJson(
  Map<String, dynamic> json,
) => _$TeacherModuleRefImpl(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
);

Map<String, dynamic> _$$TeacherModuleRefImplToJson(
  _$TeacherModuleRefImpl instance,
) => <String, dynamic>{'id': instance.id, 'title': instance.title};

_$TeacherAssignmentContentImpl _$$TeacherAssignmentContentImplFromJson(
  Map<String, dynamic> json,
) => _$TeacherAssignmentContentImpl(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String?,
  assignmentType: json['assignmentType'] as String,
  starterCode: json['starterCode'] as String?,
  expectedOutput: json['expectedOutput'] as String?,
  language: json['language'] as String?,
  points: (json['points'] as num).toInt(),
);

Map<String, dynamic> _$$TeacherAssignmentContentImplToJson(
  _$TeacherAssignmentContentImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'assignmentType': instance.assignmentType,
  'starterCode': instance.starterCode,
  'expectedOutput': instance.expectedOutput,
  'language': instance.language,
  'points': instance.points,
};

_$TeacherSubmissionDetailImpl _$$TeacherSubmissionDetailImplFromJson(
  Map<String, dynamic> json,
) => _$TeacherSubmissionDetailImpl(
  id: (json['id'] as num).toInt(),
  status: json['status'] as String,
  code: json['code'] as String?,
  answer: json['answer'] as String?,
  score: (json['score'] as num?)?.toInt(),
  teacherFeedback: json['teacherFeedback'] as String?,
  submittedAt: json['submittedAt'] == null
      ? null
      : DateTime.parse(json['submittedAt'] as String),
  checkedAt: json['checkedAt'] == null
      ? null
      : DateTime.parse(json['checkedAt'] as String),
  student: TeacherStudentBrief.fromJson(
    json['student'] as Map<String, dynamic>,
  ),
  group: TeacherGroupRef.fromJson(json['group'] as Map<String, dynamic>),
  course: TeacherCourseBrief.fromJson(json['course'] as Map<String, dynamic>),
  module: TeacherModuleRef.fromJson(json['module'] as Map<String, dynamic>),
  lesson: TeacherLessonBrief.fromJson(json['lesson'] as Map<String, dynamic>),
  assignment: TeacherAssignmentContent.fromJson(
    json['assignment'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$$TeacherSubmissionDetailImplToJson(
  _$TeacherSubmissionDetailImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'code': instance.code,
  'answer': instance.answer,
  'score': instance.score,
  'teacherFeedback': instance.teacherFeedback,
  'submittedAt': instance.submittedAt?.toIso8601String(),
  'checkedAt': instance.checkedAt?.toIso8601String(),
  'student': instance.student,
  'group': instance.group,
  'course': instance.course,
  'module': instance.module,
  'lesson': instance.lesson,
  'assignment': instance.assignment,
};
