// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assignment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Assignment _$AssignmentFromJson(Map<String, dynamic> json) {
  return _Assignment.fromJson(json);
}

/// @nodoc
mixin _$Assignment {
  int get id => throw _privateConstructorUsedError;
  int get lessonId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get assignmentType => throw _privateConstructorUsedError;
  String? get starterCode => throw _privateConstructorUsedError;
  String? get expectedOutput => throw _privateConstructorUsedError;
  String? get language => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  int get position => throw _privateConstructorUsedError;

  /// Serializes this Assignment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Assignment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssignmentCopyWith<Assignment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssignmentCopyWith<$Res> {
  factory $AssignmentCopyWith(
    Assignment value,
    $Res Function(Assignment) then,
  ) = _$AssignmentCopyWithImpl<$Res, Assignment>;
  @useResult
  $Res call({
    int id,
    int lessonId,
    String title,
    String? description,
    String assignmentType,
    String? starterCode,
    String? expectedOutput,
    String? language,
    int points,
    int position,
  });
}

/// @nodoc
class _$AssignmentCopyWithImpl<$Res, $Val extends Assignment>
    implements $AssignmentCopyWith<$Res> {
  _$AssignmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Assignment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? lessonId = null,
    Object? title = null,
    Object? description = freezed,
    Object? assignmentType = null,
    Object? starterCode = freezed,
    Object? expectedOutput = freezed,
    Object? language = freezed,
    Object? points = null,
    Object? position = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            lessonId: null == lessonId
                ? _value.lessonId
                : lessonId // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignmentType: null == assignmentType
                ? _value.assignmentType
                : assignmentType // ignore: cast_nullable_to_non_nullable
                      as String,
            starterCode: freezed == starterCode
                ? _value.starterCode
                : starterCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            expectedOutput: freezed == expectedOutput
                ? _value.expectedOutput
                : expectedOutput // ignore: cast_nullable_to_non_nullable
                      as String?,
            language: freezed == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String?,
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as int,
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AssignmentImplCopyWith<$Res>
    implements $AssignmentCopyWith<$Res> {
  factory _$$AssignmentImplCopyWith(
    _$AssignmentImpl value,
    $Res Function(_$AssignmentImpl) then,
  ) = __$$AssignmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int lessonId,
    String title,
    String? description,
    String assignmentType,
    String? starterCode,
    String? expectedOutput,
    String? language,
    int points,
    int position,
  });
}

/// @nodoc
class __$$AssignmentImplCopyWithImpl<$Res>
    extends _$AssignmentCopyWithImpl<$Res, _$AssignmentImpl>
    implements _$$AssignmentImplCopyWith<$Res> {
  __$$AssignmentImplCopyWithImpl(
    _$AssignmentImpl _value,
    $Res Function(_$AssignmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Assignment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? lessonId = null,
    Object? title = null,
    Object? description = freezed,
    Object? assignmentType = null,
    Object? starterCode = freezed,
    Object? expectedOutput = freezed,
    Object? language = freezed,
    Object? points = null,
    Object? position = null,
  }) {
    return _then(
      _$AssignmentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        lessonId: null == lessonId
            ? _value.lessonId
            : lessonId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignmentType: null == assignmentType
            ? _value.assignmentType
            : assignmentType // ignore: cast_nullable_to_non_nullable
                  as String,
        starterCode: freezed == starterCode
            ? _value.starterCode
            : starterCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        expectedOutput: freezed == expectedOutput
            ? _value.expectedOutput
            : expectedOutput // ignore: cast_nullable_to_non_nullable
                  as String?,
        language: freezed == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String?,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssignmentImpl implements _Assignment {
  const _$AssignmentImpl({
    required this.id,
    required this.lessonId,
    required this.title,
    this.description,
    required this.assignmentType,
    this.starterCode,
    this.expectedOutput,
    this.language,
    required this.points,
    required this.position,
  });

  factory _$AssignmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssignmentImplFromJson(json);

  @override
  final int id;
  @override
  final int lessonId;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String assignmentType;
  @override
  final String? starterCode;
  @override
  final String? expectedOutput;
  @override
  final String? language;
  @override
  final int points;
  @override
  final int position;

  @override
  String toString() {
    return 'Assignment(id: $id, lessonId: $lessonId, title: $title, description: $description, assignmentType: $assignmentType, starterCode: $starterCode, expectedOutput: $expectedOutput, language: $language, points: $points, position: $position)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.lessonId, lessonId) ||
                other.lessonId == lessonId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.assignmentType, assignmentType) ||
                other.assignmentType == assignmentType) &&
            (identical(other.starterCode, starterCode) ||
                other.starterCode == starterCode) &&
            (identical(other.expectedOutput, expectedOutput) ||
                other.expectedOutput == expectedOutput) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.position, position) ||
                other.position == position));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    lessonId,
    title,
    description,
    assignmentType,
    starterCode,
    expectedOutput,
    language,
    points,
    position,
  );

  /// Create a copy of Assignment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignmentImplCopyWith<_$AssignmentImpl> get copyWith =>
      __$$AssignmentImplCopyWithImpl<_$AssignmentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssignmentImplToJson(this);
  }
}

abstract class _Assignment implements Assignment {
  const factory _Assignment({
    required final int id,
    required final int lessonId,
    required final String title,
    final String? description,
    required final String assignmentType,
    final String? starterCode,
    final String? expectedOutput,
    final String? language,
    required final int points,
    required final int position,
  }) = _$AssignmentImpl;

  factory _Assignment.fromJson(Map<String, dynamic> json) =
      _$AssignmentImpl.fromJson;

  @override
  int get id;
  @override
  int get lessonId;
  @override
  String get title;
  @override
  String? get description;
  @override
  String get assignmentType;
  @override
  String? get starterCode;
  @override
  String? get expectedOutput;
  @override
  String? get language;
  @override
  int get points;
  @override
  int get position;

  /// Create a copy of Assignment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignmentImplCopyWith<_$AssignmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Submission _$SubmissionFromJson(Map<String, dynamic> json) {
  return _Submission.fromJson(json);
}

/// @nodoc
mixin _$Submission {
  int get id => throw _privateConstructorUsedError;
  int get assignmentId => throw _privateConstructorUsedError;
  int get studentId => throw _privateConstructorUsedError;
  String? get code => throw _privateConstructorUsedError;
  String? get answer => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int? get score => throw _privateConstructorUsedError;
  String? get teacherFeedback => throw _privateConstructorUsedError;
  DateTime? get submittedAt => throw _privateConstructorUsedError;
  DateTime? get checkedAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Submission to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubmissionCopyWith<Submission> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubmissionCopyWith<$Res> {
  factory $SubmissionCopyWith(
    Submission value,
    $Res Function(Submission) then,
  ) = _$SubmissionCopyWithImpl<$Res, Submission>;
  @useResult
  $Res call({
    int id,
    int assignmentId,
    int studentId,
    String? code,
    String? answer,
    String status,
    int? score,
    String? teacherFeedback,
    DateTime? submittedAt,
    DateTime? checkedAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$SubmissionCopyWithImpl<$Res, $Val extends Submission>
    implements $SubmissionCopyWith<$Res> {
  _$SubmissionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? assignmentId = null,
    Object? studentId = null,
    Object? code = freezed,
    Object? answer = freezed,
    Object? status = null,
    Object? score = freezed,
    Object? teacherFeedback = freezed,
    Object? submittedAt = freezed,
    Object? checkedAt = freezed,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            assignmentId: null == assignmentId
                ? _value.assignmentId
                : assignmentId // ignore: cast_nullable_to_non_nullable
                      as int,
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as int,
            code: freezed == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String?,
            answer: freezed == answer
                ? _value.answer
                : answer // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            score: freezed == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int?,
            teacherFeedback: freezed == teacherFeedback
                ? _value.teacherFeedback
                : teacherFeedback // ignore: cast_nullable_to_non_nullable
                      as String?,
            submittedAt: freezed == submittedAt
                ? _value.submittedAt
                : submittedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            checkedAt: freezed == checkedAt
                ? _value.checkedAt
                : checkedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubmissionImplCopyWith<$Res>
    implements $SubmissionCopyWith<$Res> {
  factory _$$SubmissionImplCopyWith(
    _$SubmissionImpl value,
    $Res Function(_$SubmissionImpl) then,
  ) = __$$SubmissionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int assignmentId,
    int studentId,
    String? code,
    String? answer,
    String status,
    int? score,
    String? teacherFeedback,
    DateTime? submittedAt,
    DateTime? checkedAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$SubmissionImplCopyWithImpl<$Res>
    extends _$SubmissionCopyWithImpl<$Res, _$SubmissionImpl>
    implements _$$SubmissionImplCopyWith<$Res> {
  __$$SubmissionImplCopyWithImpl(
    _$SubmissionImpl _value,
    $Res Function(_$SubmissionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? assignmentId = null,
    Object? studentId = null,
    Object? code = freezed,
    Object? answer = freezed,
    Object? status = null,
    Object? score = freezed,
    Object? teacherFeedback = freezed,
    Object? submittedAt = freezed,
    Object? checkedAt = freezed,
    Object? updatedAt = null,
  }) {
    return _then(
      _$SubmissionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        assignmentId: null == assignmentId
            ? _value.assignmentId
            : assignmentId // ignore: cast_nullable_to_non_nullable
                  as int,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as int,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
        answer: freezed == answer
            ? _value.answer
            : answer // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        score: freezed == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int?,
        teacherFeedback: freezed == teacherFeedback
            ? _value.teacherFeedback
            : teacherFeedback // ignore: cast_nullable_to_non_nullable
                  as String?,
        submittedAt: freezed == submittedAt
            ? _value.submittedAt
            : submittedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        checkedAt: freezed == checkedAt
            ? _value.checkedAt
            : checkedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubmissionImpl implements _Submission {
  const _$SubmissionImpl({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    this.code,
    this.answer,
    required this.status,
    this.score,
    this.teacherFeedback,
    this.submittedAt,
    this.checkedAt,
    required this.updatedAt,
  });

  factory _$SubmissionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubmissionImplFromJson(json);

  @override
  final int id;
  @override
  final int assignmentId;
  @override
  final int studentId;
  @override
  final String? code;
  @override
  final String? answer;
  @override
  final String status;
  @override
  final int? score;
  @override
  final String? teacherFeedback;
  @override
  final DateTime? submittedAt;
  @override
  final DateTime? checkedAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Submission(id: $id, assignmentId: $assignmentId, studentId: $studentId, code: $code, answer: $answer, status: $status, score: $score, teacherFeedback: $teacherFeedback, submittedAt: $submittedAt, checkedAt: $checkedAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubmissionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.assignmentId, assignmentId) ||
                other.assignmentId == assignmentId) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.answer, answer) || other.answer == answer) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.teacherFeedback, teacherFeedback) ||
                other.teacherFeedback == teacherFeedback) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.checkedAt, checkedAt) ||
                other.checkedAt == checkedAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    assignmentId,
    studentId,
    code,
    answer,
    status,
    score,
    teacherFeedback,
    submittedAt,
    checkedAt,
    updatedAt,
  );

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubmissionImplCopyWith<_$SubmissionImpl> get copyWith =>
      __$$SubmissionImplCopyWithImpl<_$SubmissionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubmissionImplToJson(this);
  }
}

abstract class _Submission implements Submission {
  const factory _Submission({
    required final int id,
    required final int assignmentId,
    required final int studentId,
    final String? code,
    final String? answer,
    required final String status,
    final int? score,
    final String? teacherFeedback,
    final DateTime? submittedAt,
    final DateTime? checkedAt,
    required final DateTime updatedAt,
  }) = _$SubmissionImpl;

  factory _Submission.fromJson(Map<String, dynamic> json) =
      _$SubmissionImpl.fromJson;

  @override
  int get id;
  @override
  int get assignmentId;
  @override
  int get studentId;
  @override
  String? get code;
  @override
  String? get answer;
  @override
  String get status;
  @override
  int? get score;
  @override
  String? get teacherFeedback;
  @override
  DateTime? get submittedAt;
  @override
  DateTime? get checkedAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubmissionImplCopyWith<_$SubmissionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
