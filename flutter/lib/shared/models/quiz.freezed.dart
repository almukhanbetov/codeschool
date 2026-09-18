// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiz.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StudentOption _$StudentOptionFromJson(Map<String, dynamic> json) {
  return _StudentOption.fromJson(json);
}

/// @nodoc
mixin _$StudentOption {
  int get id => throw _privateConstructorUsedError;
  String get optionText => throw _privateConstructorUsedError;
  int get position => throw _privateConstructorUsedError;

  /// Serializes this StudentOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudentOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentOptionCopyWith<StudentOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentOptionCopyWith<$Res> {
  factory $StudentOptionCopyWith(
    StudentOption value,
    $Res Function(StudentOption) then,
  ) = _$StudentOptionCopyWithImpl<$Res, StudentOption>;
  @useResult
  $Res call({int id, String optionText, int position});
}

/// @nodoc
class _$StudentOptionCopyWithImpl<$Res, $Val extends StudentOption>
    implements $StudentOptionCopyWith<$Res> {
  _$StudentOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? optionText = null,
    Object? position = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            optionText: null == optionText
                ? _value.optionText
                : optionText // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$StudentOptionImplCopyWith<$Res>
    implements $StudentOptionCopyWith<$Res> {
  factory _$$StudentOptionImplCopyWith(
    _$StudentOptionImpl value,
    $Res Function(_$StudentOptionImpl) then,
  ) = __$$StudentOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String optionText, int position});
}

/// @nodoc
class __$$StudentOptionImplCopyWithImpl<$Res>
    extends _$StudentOptionCopyWithImpl<$Res, _$StudentOptionImpl>
    implements _$$StudentOptionImplCopyWith<$Res> {
  __$$StudentOptionImplCopyWithImpl(
    _$StudentOptionImpl _value,
    $Res Function(_$StudentOptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? optionText = null,
    Object? position = null,
  }) {
    return _then(
      _$StudentOptionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        optionText: null == optionText
            ? _value.optionText
            : optionText // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$StudentOptionImpl implements _StudentOption {
  const _$StudentOptionImpl({
    required this.id,
    required this.optionText,
    required this.position,
  });

  factory _$StudentOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentOptionImplFromJson(json);

  @override
  final int id;
  @override
  final String optionText;
  @override
  final int position;

  @override
  String toString() {
    return 'StudentOption(id: $id, optionText: $optionText, position: $position)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentOptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.optionText, optionText) ||
                other.optionText == optionText) &&
            (identical(other.position, position) ||
                other.position == position));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, optionText, position);

  /// Create a copy of StudentOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentOptionImplCopyWith<_$StudentOptionImpl> get copyWith =>
      __$$StudentOptionImplCopyWithImpl<_$StudentOptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentOptionImplToJson(this);
  }
}

abstract class _StudentOption implements StudentOption {
  const factory _StudentOption({
    required final int id,
    required final String optionText,
    required final int position,
  }) = _$StudentOptionImpl;

  factory _StudentOption.fromJson(Map<String, dynamic> json) =
      _$StudentOptionImpl.fromJson;

  @override
  int get id;
  @override
  String get optionText;
  @override
  int get position;

  /// Create a copy of StudentOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentOptionImplCopyWith<_$StudentOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudentQuestion _$StudentQuestionFromJson(Map<String, dynamic> json) {
  return _StudentQuestion.fromJson(json);
}

/// @nodoc
mixin _$StudentQuestion {
  int get id => throw _privateConstructorUsedError;
  String get questionText => throw _privateConstructorUsedError;
  String get questionType => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  int get position => throw _privateConstructorUsedError;
  List<StudentOption> get options => throw _privateConstructorUsedError;

  /// Serializes this StudentQuestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudentQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentQuestionCopyWith<StudentQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentQuestionCopyWith<$Res> {
  factory $StudentQuestionCopyWith(
    StudentQuestion value,
    $Res Function(StudentQuestion) then,
  ) = _$StudentQuestionCopyWithImpl<$Res, StudentQuestion>;
  @useResult
  $Res call({
    int id,
    String questionText,
    String questionType,
    int points,
    int position,
    List<StudentOption> options,
  });
}

/// @nodoc
class _$StudentQuestionCopyWithImpl<$Res, $Val extends StudentQuestion>
    implements $StudentQuestionCopyWith<$Res> {
  _$StudentQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? questionText = null,
    Object? questionType = null,
    Object? points = null,
    Object? position = null,
    Object? options = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            questionText: null == questionText
                ? _value.questionText
                : questionText // ignore: cast_nullable_to_non_nullable
                      as String,
            questionType: null == questionType
                ? _value.questionType
                : questionType // ignore: cast_nullable_to_non_nullable
                      as String,
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as int,
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as int,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<StudentOption>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudentQuestionImplCopyWith<$Res>
    implements $StudentQuestionCopyWith<$Res> {
  factory _$$StudentQuestionImplCopyWith(
    _$StudentQuestionImpl value,
    $Res Function(_$StudentQuestionImpl) then,
  ) = __$$StudentQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String questionText,
    String questionType,
    int points,
    int position,
    List<StudentOption> options,
  });
}

/// @nodoc
class __$$StudentQuestionImplCopyWithImpl<$Res>
    extends _$StudentQuestionCopyWithImpl<$Res, _$StudentQuestionImpl>
    implements _$$StudentQuestionImplCopyWith<$Res> {
  __$$StudentQuestionImplCopyWithImpl(
    _$StudentQuestionImpl _value,
    $Res Function(_$StudentQuestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? questionText = null,
    Object? questionType = null,
    Object? points = null,
    Object? position = null,
    Object? options = null,
  }) {
    return _then(
      _$StudentQuestionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        questionText: null == questionText
            ? _value.questionText
            : questionText // ignore: cast_nullable_to_non_nullable
                  as String,
        questionType: null == questionType
            ? _value.questionType
            : questionType // ignore: cast_nullable_to_non_nullable
                  as String,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as int,
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<StudentOption>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentQuestionImpl implements _StudentQuestion {
  const _$StudentQuestionImpl({
    required this.id,
    required this.questionText,
    required this.questionType,
    required this.points,
    required this.position,
    final List<StudentOption> options = const [],
  }) : _options = options;

  factory _$StudentQuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentQuestionImplFromJson(json);

  @override
  final int id;
  @override
  final String questionText;
  @override
  final String questionType;
  @override
  final int points;
  @override
  final int position;
  final List<StudentOption> _options;
  @override
  @JsonKey()
  List<StudentOption> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  String toString() {
    return 'StudentQuestion(id: $id, questionText: $questionText, questionType: $questionType, points: $points, position: $position, options: $options)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentQuestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.questionText, questionText) ||
                other.questionText == questionText) &&
            (identical(other.questionType, questionType) ||
                other.questionType == questionType) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.position, position) ||
                other.position == position) &&
            const DeepCollectionEquality().equals(other._options, _options));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    questionText,
    questionType,
    points,
    position,
    const DeepCollectionEquality().hash(_options),
  );

  /// Create a copy of StudentQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentQuestionImplCopyWith<_$StudentQuestionImpl> get copyWith =>
      __$$StudentQuestionImplCopyWithImpl<_$StudentQuestionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentQuestionImplToJson(this);
  }
}

abstract class _StudentQuestion implements StudentQuestion {
  const factory _StudentQuestion({
    required final int id,
    required final String questionText,
    required final String questionType,
    required final int points,
    required final int position,
    final List<StudentOption> options,
  }) = _$StudentQuestionImpl;

  factory _StudentQuestion.fromJson(Map<String, dynamic> json) =
      _$StudentQuestionImpl.fromJson;

  @override
  int get id;
  @override
  String get questionText;
  @override
  String get questionType;
  @override
  int get points;
  @override
  int get position;
  @override
  List<StudentOption> get options;

  /// Create a copy of StudentQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentQuestionImplCopyWith<_$StudentQuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudentQuiz _$StudentQuizFromJson(Map<String, dynamic> json) {
  return _StudentQuiz.fromJson(json);
}

/// @nodoc
mixin _$StudentQuiz {
  int get assignmentId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  int get passPercent => throw _privateConstructorUsedError;
  List<StudentQuestion> get questions => throw _privateConstructorUsedError;

  /// Serializes this StudentQuiz to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudentQuiz
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentQuizCopyWith<StudentQuiz> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentQuizCopyWith<$Res> {
  factory $StudentQuizCopyWith(
    StudentQuiz value,
    $Res Function(StudentQuiz) then,
  ) = _$StudentQuizCopyWithImpl<$Res, StudentQuiz>;
  @useResult
  $Res call({
    int assignmentId,
    String title,
    int passPercent,
    List<StudentQuestion> questions,
  });
}

/// @nodoc
class _$StudentQuizCopyWithImpl<$Res, $Val extends StudentQuiz>
    implements $StudentQuizCopyWith<$Res> {
  _$StudentQuizCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentQuiz
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assignmentId = null,
    Object? title = null,
    Object? passPercent = null,
    Object? questions = null,
  }) {
    return _then(
      _value.copyWith(
            assignmentId: null == assignmentId
                ? _value.assignmentId
                : assignmentId // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            passPercent: null == passPercent
                ? _value.passPercent
                : passPercent // ignore: cast_nullable_to_non_nullable
                      as int,
            questions: null == questions
                ? _value.questions
                : questions // ignore: cast_nullable_to_non_nullable
                      as List<StudentQuestion>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudentQuizImplCopyWith<$Res>
    implements $StudentQuizCopyWith<$Res> {
  factory _$$StudentQuizImplCopyWith(
    _$StudentQuizImpl value,
    $Res Function(_$StudentQuizImpl) then,
  ) = __$$StudentQuizImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int assignmentId,
    String title,
    int passPercent,
    List<StudentQuestion> questions,
  });
}

/// @nodoc
class __$$StudentQuizImplCopyWithImpl<$Res>
    extends _$StudentQuizCopyWithImpl<$Res, _$StudentQuizImpl>
    implements _$$StudentQuizImplCopyWith<$Res> {
  __$$StudentQuizImplCopyWithImpl(
    _$StudentQuizImpl _value,
    $Res Function(_$StudentQuizImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentQuiz
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assignmentId = null,
    Object? title = null,
    Object? passPercent = null,
    Object? questions = null,
  }) {
    return _then(
      _$StudentQuizImpl(
        assignmentId: null == assignmentId
            ? _value.assignmentId
            : assignmentId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        passPercent: null == passPercent
            ? _value.passPercent
            : passPercent // ignore: cast_nullable_to_non_nullable
                  as int,
        questions: null == questions
            ? _value._questions
            : questions // ignore: cast_nullable_to_non_nullable
                  as List<StudentQuestion>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentQuizImpl implements _StudentQuiz {
  const _$StudentQuizImpl({
    required this.assignmentId,
    required this.title,
    required this.passPercent,
    final List<StudentQuestion> questions = const [],
  }) : _questions = questions;

  factory _$StudentQuizImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentQuizImplFromJson(json);

  @override
  final int assignmentId;
  @override
  final String title;
  @override
  final int passPercent;
  final List<StudentQuestion> _questions;
  @override
  @JsonKey()
  List<StudentQuestion> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  @override
  String toString() {
    return 'StudentQuiz(assignmentId: $assignmentId, title: $title, passPercent: $passPercent, questions: $questions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentQuizImpl &&
            (identical(other.assignmentId, assignmentId) ||
                other.assignmentId == assignmentId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.passPercent, passPercent) ||
                other.passPercent == passPercent) &&
            const DeepCollectionEquality().equals(
              other._questions,
              _questions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    assignmentId,
    title,
    passPercent,
    const DeepCollectionEquality().hash(_questions),
  );

  /// Create a copy of StudentQuiz
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentQuizImplCopyWith<_$StudentQuizImpl> get copyWith =>
      __$$StudentQuizImplCopyWithImpl<_$StudentQuizImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentQuizImplToJson(this);
  }
}

abstract class _StudentQuiz implements StudentQuiz {
  const factory _StudentQuiz({
    required final int assignmentId,
    required final String title,
    required final int passPercent,
    final List<StudentQuestion> questions,
  }) = _$StudentQuizImpl;

  factory _StudentQuiz.fromJson(Map<String, dynamic> json) =
      _$StudentQuizImpl.fromJson;

  @override
  int get assignmentId;
  @override
  String get title;
  @override
  int get passPercent;
  @override
  List<StudentQuestion> get questions;

  /// Create a copy of StudentQuiz
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentQuizImplCopyWith<_$StudentQuizImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AttemptBrief _$AttemptBriefFromJson(Map<String, dynamic> json) {
  return _AttemptBrief.fromJson(json);
}

/// @nodoc
mixin _$AttemptBrief {
  int get id => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get submittedAt => throw _privateConstructorUsedError;

  /// Serializes this AttemptBrief to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AttemptBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttemptBriefCopyWith<AttemptBrief> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttemptBriefCopyWith<$Res> {
  factory $AttemptBriefCopyWith(
    AttemptBrief value,
    $Res Function(AttemptBrief) then,
  ) = _$AttemptBriefCopyWithImpl<$Res, AttemptBrief>;
  @useResult
  $Res call({int id, String status, DateTime startedAt, DateTime? submittedAt});
}

/// @nodoc
class _$AttemptBriefCopyWithImpl<$Res, $Val extends AttemptBrief>
    implements $AttemptBriefCopyWith<$Res> {
  _$AttemptBriefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttemptBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? startedAt = null,
    Object? submittedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            submittedAt: freezed == submittedAt
                ? _value.submittedAt
                : submittedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AttemptBriefImplCopyWith<$Res>
    implements $AttemptBriefCopyWith<$Res> {
  factory _$$AttemptBriefImplCopyWith(
    _$AttemptBriefImpl value,
    $Res Function(_$AttemptBriefImpl) then,
  ) = __$$AttemptBriefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String status, DateTime startedAt, DateTime? submittedAt});
}

/// @nodoc
class __$$AttemptBriefImplCopyWithImpl<$Res>
    extends _$AttemptBriefCopyWithImpl<$Res, _$AttemptBriefImpl>
    implements _$$AttemptBriefImplCopyWith<$Res> {
  __$$AttemptBriefImplCopyWithImpl(
    _$AttemptBriefImpl _value,
    $Res Function(_$AttemptBriefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttemptBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? startedAt = null,
    Object? submittedAt = freezed,
  }) {
    return _then(
      _$AttemptBriefImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        submittedAt: freezed == submittedAt
            ? _value.submittedAt
            : submittedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AttemptBriefImpl implements _AttemptBrief {
  const _$AttemptBriefImpl({
    required this.id,
    required this.status,
    required this.startedAt,
    this.submittedAt,
  });

  factory _$AttemptBriefImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttemptBriefImplFromJson(json);

  @override
  final int id;
  @override
  final String status;
  @override
  final DateTime startedAt;
  @override
  final DateTime? submittedAt;

  @override
  String toString() {
    return 'AttemptBrief(id: $id, status: $status, startedAt: $startedAt, submittedAt: $submittedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttemptBriefImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, status, startedAt, submittedAt);

  /// Create a copy of AttemptBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttemptBriefImplCopyWith<_$AttemptBriefImpl> get copyWith =>
      __$$AttemptBriefImplCopyWithImpl<_$AttemptBriefImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AttemptBriefImplToJson(this);
  }
}

abstract class _AttemptBrief implements AttemptBrief {
  const factory _AttemptBrief({
    required final int id,
    required final String status,
    required final DateTime startedAt,
    final DateTime? submittedAt,
  }) = _$AttemptBriefImpl;

  factory _AttemptBrief.fromJson(Map<String, dynamic> json) =
      _$AttemptBriefImpl.fromJson;

  @override
  int get id;
  @override
  String get status;
  @override
  DateTime get startedAt;
  @override
  DateTime? get submittedAt;

  /// Create a copy of AttemptBrief
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttemptBriefImplCopyWith<_$AttemptBriefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StartAttemptResponse _$StartAttemptResponseFromJson(Map<String, dynamic> json) {
  return _StartAttemptResponse.fromJson(json);
}

/// @nodoc
mixin _$StartAttemptResponse {
  AttemptBrief get attempt => throw _privateConstructorUsedError;
  StudentQuiz get quiz => throw _privateConstructorUsedError;

  /// Serializes this StartAttemptResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StartAttemptResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StartAttemptResponseCopyWith<StartAttemptResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StartAttemptResponseCopyWith<$Res> {
  factory $StartAttemptResponseCopyWith(
    StartAttemptResponse value,
    $Res Function(StartAttemptResponse) then,
  ) = _$StartAttemptResponseCopyWithImpl<$Res, StartAttemptResponse>;
  @useResult
  $Res call({AttemptBrief attempt, StudentQuiz quiz});

  $AttemptBriefCopyWith<$Res> get attempt;
  $StudentQuizCopyWith<$Res> get quiz;
}

/// @nodoc
class _$StartAttemptResponseCopyWithImpl<
  $Res,
  $Val extends StartAttemptResponse
>
    implements $StartAttemptResponseCopyWith<$Res> {
  _$StartAttemptResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StartAttemptResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? attempt = null, Object? quiz = null}) {
    return _then(
      _value.copyWith(
            attempt: null == attempt
                ? _value.attempt
                : attempt // ignore: cast_nullable_to_non_nullable
                      as AttemptBrief,
            quiz: null == quiz
                ? _value.quiz
                : quiz // ignore: cast_nullable_to_non_nullable
                      as StudentQuiz,
          )
          as $Val,
    );
  }

  /// Create a copy of StartAttemptResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AttemptBriefCopyWith<$Res> get attempt {
    return $AttemptBriefCopyWith<$Res>(_value.attempt, (value) {
      return _then(_value.copyWith(attempt: value) as $Val);
    });
  }

  /// Create a copy of StartAttemptResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StudentQuizCopyWith<$Res> get quiz {
    return $StudentQuizCopyWith<$Res>(_value.quiz, (value) {
      return _then(_value.copyWith(quiz: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StartAttemptResponseImplCopyWith<$Res>
    implements $StartAttemptResponseCopyWith<$Res> {
  factory _$$StartAttemptResponseImplCopyWith(
    _$StartAttemptResponseImpl value,
    $Res Function(_$StartAttemptResponseImpl) then,
  ) = __$$StartAttemptResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({AttemptBrief attempt, StudentQuiz quiz});

  @override
  $AttemptBriefCopyWith<$Res> get attempt;
  @override
  $StudentQuizCopyWith<$Res> get quiz;
}

/// @nodoc
class __$$StartAttemptResponseImplCopyWithImpl<$Res>
    extends _$StartAttemptResponseCopyWithImpl<$Res, _$StartAttemptResponseImpl>
    implements _$$StartAttemptResponseImplCopyWith<$Res> {
  __$$StartAttemptResponseImplCopyWithImpl(
    _$StartAttemptResponseImpl _value,
    $Res Function(_$StartAttemptResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StartAttemptResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? attempt = null, Object? quiz = null}) {
    return _then(
      _$StartAttemptResponseImpl(
        attempt: null == attempt
            ? _value.attempt
            : attempt // ignore: cast_nullable_to_non_nullable
                  as AttemptBrief,
        quiz: null == quiz
            ? _value.quiz
            : quiz // ignore: cast_nullable_to_non_nullable
                  as StudentQuiz,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StartAttemptResponseImpl implements _StartAttemptResponse {
  const _$StartAttemptResponseImpl({required this.attempt, required this.quiz});

  factory _$StartAttemptResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$StartAttemptResponseImplFromJson(json);

  @override
  final AttemptBrief attempt;
  @override
  final StudentQuiz quiz;

  @override
  String toString() {
    return 'StartAttemptResponse(attempt: $attempt, quiz: $quiz)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StartAttemptResponseImpl &&
            (identical(other.attempt, attempt) || other.attempt == attempt) &&
            (identical(other.quiz, quiz) || other.quiz == quiz));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, attempt, quiz);

  /// Create a copy of StartAttemptResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StartAttemptResponseImplCopyWith<_$StartAttemptResponseImpl>
  get copyWith =>
      __$$StartAttemptResponseImplCopyWithImpl<_$StartAttemptResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StartAttemptResponseImplToJson(this);
  }
}

abstract class _StartAttemptResponse implements StartAttemptResponse {
  const factory _StartAttemptResponse({
    required final AttemptBrief attempt,
    required final StudentQuiz quiz,
  }) = _$StartAttemptResponseImpl;

  factory _StartAttemptResponse.fromJson(Map<String, dynamic> json) =
      _$StartAttemptResponseImpl.fromJson;

  @override
  AttemptBrief get attempt;
  @override
  StudentQuiz get quiz;

  /// Create a copy of StartAttemptResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StartAttemptResponseImplCopyWith<_$StartAttemptResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ResultOption _$ResultOptionFromJson(Map<String, dynamic> json) {
  return _ResultOption.fromJson(json);
}

/// @nodoc
mixin _$ResultOption {
  int get id => throw _privateConstructorUsedError;
  String get optionText => throw _privateConstructorUsedError;
  int get position => throw _privateConstructorUsedError;
  bool get selected => throw _privateConstructorUsedError;
  bool? get isCorrect => throw _privateConstructorUsedError;

  /// Serializes this ResultOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResultOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResultOptionCopyWith<ResultOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultOptionCopyWith<$Res> {
  factory $ResultOptionCopyWith(
    ResultOption value,
    $Res Function(ResultOption) then,
  ) = _$ResultOptionCopyWithImpl<$Res, ResultOption>;
  @useResult
  $Res call({
    int id,
    String optionText,
    int position,
    bool selected,
    bool? isCorrect,
  });
}

/// @nodoc
class _$ResultOptionCopyWithImpl<$Res, $Val extends ResultOption>
    implements $ResultOptionCopyWith<$Res> {
  _$ResultOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResultOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? optionText = null,
    Object? position = null,
    Object? selected = null,
    Object? isCorrect = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            optionText: null == optionText
                ? _value.optionText
                : optionText // ignore: cast_nullable_to_non_nullable
                      as String,
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as int,
            selected: null == selected
                ? _value.selected
                : selected // ignore: cast_nullable_to_non_nullable
                      as bool,
            isCorrect: freezed == isCorrect
                ? _value.isCorrect
                : isCorrect // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ResultOptionImplCopyWith<$Res>
    implements $ResultOptionCopyWith<$Res> {
  factory _$$ResultOptionImplCopyWith(
    _$ResultOptionImpl value,
    $Res Function(_$ResultOptionImpl) then,
  ) = __$$ResultOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String optionText,
    int position,
    bool selected,
    bool? isCorrect,
  });
}

/// @nodoc
class __$$ResultOptionImplCopyWithImpl<$Res>
    extends _$ResultOptionCopyWithImpl<$Res, _$ResultOptionImpl>
    implements _$$ResultOptionImplCopyWith<$Res> {
  __$$ResultOptionImplCopyWithImpl(
    _$ResultOptionImpl _value,
    $Res Function(_$ResultOptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ResultOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? optionText = null,
    Object? position = null,
    Object? selected = null,
    Object? isCorrect = freezed,
  }) {
    return _then(
      _$ResultOptionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        optionText: null == optionText
            ? _value.optionText
            : optionText // ignore: cast_nullable_to_non_nullable
                  as String,
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as int,
        selected: null == selected
            ? _value.selected
            : selected // ignore: cast_nullable_to_non_nullable
                  as bool,
        isCorrect: freezed == isCorrect
            ? _value.isCorrect
            : isCorrect // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ResultOptionImpl implements _ResultOption {
  const _$ResultOptionImpl({
    required this.id,
    required this.optionText,
    required this.position,
    required this.selected,
    this.isCorrect,
  });

  factory _$ResultOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResultOptionImplFromJson(json);

  @override
  final int id;
  @override
  final String optionText;
  @override
  final int position;
  @override
  final bool selected;
  @override
  final bool? isCorrect;

  @override
  String toString() {
    return 'ResultOption(id: $id, optionText: $optionText, position: $position, selected: $selected, isCorrect: $isCorrect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResultOptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.optionText, optionText) ||
                other.optionText == optionText) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.selected, selected) ||
                other.selected == selected) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, optionText, position, selected, isCorrect);

  /// Create a copy of ResultOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResultOptionImplCopyWith<_$ResultOptionImpl> get copyWith =>
      __$$ResultOptionImplCopyWithImpl<_$ResultOptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResultOptionImplToJson(this);
  }
}

abstract class _ResultOption implements ResultOption {
  const factory _ResultOption({
    required final int id,
    required final String optionText,
    required final int position,
    required final bool selected,
    final bool? isCorrect,
  }) = _$ResultOptionImpl;

  factory _ResultOption.fromJson(Map<String, dynamic> json) =
      _$ResultOptionImpl.fromJson;

  @override
  int get id;
  @override
  String get optionText;
  @override
  int get position;
  @override
  bool get selected;
  @override
  bool? get isCorrect;

  /// Create a copy of ResultOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResultOptionImplCopyWith<_$ResultOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ResultQuestion _$ResultQuestionFromJson(Map<String, dynamic> json) {
  return _ResultQuestion.fromJson(json);
}

/// @nodoc
mixin _$ResultQuestion {
  int get questionId => throw _privateConstructorUsedError;
  String get questionText => throw _privateConstructorUsedError;
  String get questionType => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  int get pointsAwarded => throw _privateConstructorUsedError;
  bool get isCorrect => throw _privateConstructorUsedError;
  String? get explanation => throw _privateConstructorUsedError;
  List<ResultOption> get options => throw _privateConstructorUsedError;

  /// Serializes this ResultQuestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResultQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResultQuestionCopyWith<ResultQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultQuestionCopyWith<$Res> {
  factory $ResultQuestionCopyWith(
    ResultQuestion value,
    $Res Function(ResultQuestion) then,
  ) = _$ResultQuestionCopyWithImpl<$Res, ResultQuestion>;
  @useResult
  $Res call({
    int questionId,
    String questionText,
    String questionType,
    int points,
    int pointsAwarded,
    bool isCorrect,
    String? explanation,
    List<ResultOption> options,
  });
}

/// @nodoc
class _$ResultQuestionCopyWithImpl<$Res, $Val extends ResultQuestion>
    implements $ResultQuestionCopyWith<$Res> {
  _$ResultQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResultQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? questionText = null,
    Object? questionType = null,
    Object? points = null,
    Object? pointsAwarded = null,
    Object? isCorrect = null,
    Object? explanation = freezed,
    Object? options = null,
  }) {
    return _then(
      _value.copyWith(
            questionId: null == questionId
                ? _value.questionId
                : questionId // ignore: cast_nullable_to_non_nullable
                      as int,
            questionText: null == questionText
                ? _value.questionText
                : questionText // ignore: cast_nullable_to_non_nullable
                      as String,
            questionType: null == questionType
                ? _value.questionType
                : questionType // ignore: cast_nullable_to_non_nullable
                      as String,
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as int,
            pointsAwarded: null == pointsAwarded
                ? _value.pointsAwarded
                : pointsAwarded // ignore: cast_nullable_to_non_nullable
                      as int,
            isCorrect: null == isCorrect
                ? _value.isCorrect
                : isCorrect // ignore: cast_nullable_to_non_nullable
                      as bool,
            explanation: freezed == explanation
                ? _value.explanation
                : explanation // ignore: cast_nullable_to_non_nullable
                      as String?,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<ResultOption>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ResultQuestionImplCopyWith<$Res>
    implements $ResultQuestionCopyWith<$Res> {
  factory _$$ResultQuestionImplCopyWith(
    _$ResultQuestionImpl value,
    $Res Function(_$ResultQuestionImpl) then,
  ) = __$$ResultQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int questionId,
    String questionText,
    String questionType,
    int points,
    int pointsAwarded,
    bool isCorrect,
    String? explanation,
    List<ResultOption> options,
  });
}

/// @nodoc
class __$$ResultQuestionImplCopyWithImpl<$Res>
    extends _$ResultQuestionCopyWithImpl<$Res, _$ResultQuestionImpl>
    implements _$$ResultQuestionImplCopyWith<$Res> {
  __$$ResultQuestionImplCopyWithImpl(
    _$ResultQuestionImpl _value,
    $Res Function(_$ResultQuestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ResultQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? questionText = null,
    Object? questionType = null,
    Object? points = null,
    Object? pointsAwarded = null,
    Object? isCorrect = null,
    Object? explanation = freezed,
    Object? options = null,
  }) {
    return _then(
      _$ResultQuestionImpl(
        questionId: null == questionId
            ? _value.questionId
            : questionId // ignore: cast_nullable_to_non_nullable
                  as int,
        questionText: null == questionText
            ? _value.questionText
            : questionText // ignore: cast_nullable_to_non_nullable
                  as String,
        questionType: null == questionType
            ? _value.questionType
            : questionType // ignore: cast_nullable_to_non_nullable
                  as String,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
        pointsAwarded: null == pointsAwarded
            ? _value.pointsAwarded
            : pointsAwarded // ignore: cast_nullable_to_non_nullable
                  as int,
        isCorrect: null == isCorrect
            ? _value.isCorrect
            : isCorrect // ignore: cast_nullable_to_non_nullable
                  as bool,
        explanation: freezed == explanation
            ? _value.explanation
            : explanation // ignore: cast_nullable_to_non_nullable
                  as String?,
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<ResultOption>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ResultQuestionImpl implements _ResultQuestion {
  const _$ResultQuestionImpl({
    required this.questionId,
    required this.questionText,
    required this.questionType,
    required this.points,
    required this.pointsAwarded,
    required this.isCorrect,
    this.explanation,
    final List<ResultOption> options = const [],
  }) : _options = options;

  factory _$ResultQuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResultQuestionImplFromJson(json);

  @override
  final int questionId;
  @override
  final String questionText;
  @override
  final String questionType;
  @override
  final int points;
  @override
  final int pointsAwarded;
  @override
  final bool isCorrect;
  @override
  final String? explanation;
  final List<ResultOption> _options;
  @override
  @JsonKey()
  List<ResultOption> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  String toString() {
    return 'ResultQuestion(questionId: $questionId, questionText: $questionText, questionType: $questionType, points: $points, pointsAwarded: $pointsAwarded, isCorrect: $isCorrect, explanation: $explanation, options: $options)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResultQuestionImpl &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.questionText, questionText) ||
                other.questionText == questionText) &&
            (identical(other.questionType, questionType) ||
                other.questionType == questionType) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.pointsAwarded, pointsAwarded) ||
                other.pointsAwarded == pointsAwarded) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation) &&
            const DeepCollectionEquality().equals(other._options, _options));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    questionId,
    questionText,
    questionType,
    points,
    pointsAwarded,
    isCorrect,
    explanation,
    const DeepCollectionEquality().hash(_options),
  );

  /// Create a copy of ResultQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResultQuestionImplCopyWith<_$ResultQuestionImpl> get copyWith =>
      __$$ResultQuestionImplCopyWithImpl<_$ResultQuestionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ResultQuestionImplToJson(this);
  }
}

abstract class _ResultQuestion implements ResultQuestion {
  const factory _ResultQuestion({
    required final int questionId,
    required final String questionText,
    required final String questionType,
    required final int points,
    required final int pointsAwarded,
    required final bool isCorrect,
    final String? explanation,
    final List<ResultOption> options,
  }) = _$ResultQuestionImpl;

  factory _ResultQuestion.fromJson(Map<String, dynamic> json) =
      _$ResultQuestionImpl.fromJson;

  @override
  int get questionId;
  @override
  String get questionText;
  @override
  String get questionType;
  @override
  int get points;
  @override
  int get pointsAwarded;
  @override
  bool get isCorrect;
  @override
  String? get explanation;
  @override
  List<ResultOption> get options;

  /// Create a copy of ResultQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResultQuestionImplCopyWith<_$ResultQuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AttemptResult _$AttemptResultFromJson(Map<String, dynamic> json) {
  return _AttemptResult.fromJson(json);
}

/// @nodoc
mixin _$AttemptResult {
  int get attemptId => throw _privateConstructorUsedError;
  int get assignmentId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  int get maxScore => throw _privateConstructorUsedError;
  int get percent => throw _privateConstructorUsedError;
  bool get passed => throw _privateConstructorUsedError;
  int get passPercent => throw _privateConstructorUsedError;
  DateTime? get submittedAt => throw _privateConstructorUsedError;
  bool get showCorrectAnswers => throw _privateConstructorUsedError;
  List<ResultQuestion> get questions => throw _privateConstructorUsedError;

  /// Serializes this AttemptResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AttemptResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttemptResultCopyWith<AttemptResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttemptResultCopyWith<$Res> {
  factory $AttemptResultCopyWith(
    AttemptResult value,
    $Res Function(AttemptResult) then,
  ) = _$AttemptResultCopyWithImpl<$Res, AttemptResult>;
  @useResult
  $Res call({
    int attemptId,
    int assignmentId,
    String status,
    int score,
    int maxScore,
    int percent,
    bool passed,
    int passPercent,
    DateTime? submittedAt,
    bool showCorrectAnswers,
    List<ResultQuestion> questions,
  });
}

/// @nodoc
class _$AttemptResultCopyWithImpl<$Res, $Val extends AttemptResult>
    implements $AttemptResultCopyWith<$Res> {
  _$AttemptResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttemptResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attemptId = null,
    Object? assignmentId = null,
    Object? status = null,
    Object? score = null,
    Object? maxScore = null,
    Object? percent = null,
    Object? passed = null,
    Object? passPercent = null,
    Object? submittedAt = freezed,
    Object? showCorrectAnswers = null,
    Object? questions = null,
  }) {
    return _then(
      _value.copyWith(
            attemptId: null == attemptId
                ? _value.attemptId
                : attemptId // ignore: cast_nullable_to_non_nullable
                      as int,
            assignmentId: null == assignmentId
                ? _value.assignmentId
                : assignmentId // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
            maxScore: null == maxScore
                ? _value.maxScore
                : maxScore // ignore: cast_nullable_to_non_nullable
                      as int,
            percent: null == percent
                ? _value.percent
                : percent // ignore: cast_nullable_to_non_nullable
                      as int,
            passed: null == passed
                ? _value.passed
                : passed // ignore: cast_nullable_to_non_nullable
                      as bool,
            passPercent: null == passPercent
                ? _value.passPercent
                : passPercent // ignore: cast_nullable_to_non_nullable
                      as int,
            submittedAt: freezed == submittedAt
                ? _value.submittedAt
                : submittedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            showCorrectAnswers: null == showCorrectAnswers
                ? _value.showCorrectAnswers
                : showCorrectAnswers // ignore: cast_nullable_to_non_nullable
                      as bool,
            questions: null == questions
                ? _value.questions
                : questions // ignore: cast_nullable_to_non_nullable
                      as List<ResultQuestion>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AttemptResultImplCopyWith<$Res>
    implements $AttemptResultCopyWith<$Res> {
  factory _$$AttemptResultImplCopyWith(
    _$AttemptResultImpl value,
    $Res Function(_$AttemptResultImpl) then,
  ) = __$$AttemptResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int attemptId,
    int assignmentId,
    String status,
    int score,
    int maxScore,
    int percent,
    bool passed,
    int passPercent,
    DateTime? submittedAt,
    bool showCorrectAnswers,
    List<ResultQuestion> questions,
  });
}

/// @nodoc
class __$$AttemptResultImplCopyWithImpl<$Res>
    extends _$AttemptResultCopyWithImpl<$Res, _$AttemptResultImpl>
    implements _$$AttemptResultImplCopyWith<$Res> {
  __$$AttemptResultImplCopyWithImpl(
    _$AttemptResultImpl _value,
    $Res Function(_$AttemptResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttemptResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attemptId = null,
    Object? assignmentId = null,
    Object? status = null,
    Object? score = null,
    Object? maxScore = null,
    Object? percent = null,
    Object? passed = null,
    Object? passPercent = null,
    Object? submittedAt = freezed,
    Object? showCorrectAnswers = null,
    Object? questions = null,
  }) {
    return _then(
      _$AttemptResultImpl(
        attemptId: null == attemptId
            ? _value.attemptId
            : attemptId // ignore: cast_nullable_to_non_nullable
                  as int,
        assignmentId: null == assignmentId
            ? _value.assignmentId
            : assignmentId // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        maxScore: null == maxScore
            ? _value.maxScore
            : maxScore // ignore: cast_nullable_to_non_nullable
                  as int,
        percent: null == percent
            ? _value.percent
            : percent // ignore: cast_nullable_to_non_nullable
                  as int,
        passed: null == passed
            ? _value.passed
            : passed // ignore: cast_nullable_to_non_nullable
                  as bool,
        passPercent: null == passPercent
            ? _value.passPercent
            : passPercent // ignore: cast_nullable_to_non_nullable
                  as int,
        submittedAt: freezed == submittedAt
            ? _value.submittedAt
            : submittedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        showCorrectAnswers: null == showCorrectAnswers
            ? _value.showCorrectAnswers
            : showCorrectAnswers // ignore: cast_nullable_to_non_nullable
                  as bool,
        questions: null == questions
            ? _value._questions
            : questions // ignore: cast_nullable_to_non_nullable
                  as List<ResultQuestion>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AttemptResultImpl implements _AttemptResult {
  const _$AttemptResultImpl({
    required this.attemptId,
    required this.assignmentId,
    required this.status,
    required this.score,
    required this.maxScore,
    required this.percent,
    required this.passed,
    required this.passPercent,
    this.submittedAt,
    required this.showCorrectAnswers,
    final List<ResultQuestion> questions = const [],
  }) : _questions = questions;

  factory _$AttemptResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttemptResultImplFromJson(json);

  @override
  final int attemptId;
  @override
  final int assignmentId;
  @override
  final String status;
  @override
  final int score;
  @override
  final int maxScore;
  @override
  final int percent;
  @override
  final bool passed;
  @override
  final int passPercent;
  @override
  final DateTime? submittedAt;
  @override
  final bool showCorrectAnswers;
  final List<ResultQuestion> _questions;
  @override
  @JsonKey()
  List<ResultQuestion> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  @override
  String toString() {
    return 'AttemptResult(attemptId: $attemptId, assignmentId: $assignmentId, status: $status, score: $score, maxScore: $maxScore, percent: $percent, passed: $passed, passPercent: $passPercent, submittedAt: $submittedAt, showCorrectAnswers: $showCorrectAnswers, questions: $questions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttemptResultImpl &&
            (identical(other.attemptId, attemptId) ||
                other.attemptId == attemptId) &&
            (identical(other.assignmentId, assignmentId) ||
                other.assignmentId == assignmentId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.maxScore, maxScore) ||
                other.maxScore == maxScore) &&
            (identical(other.percent, percent) || other.percent == percent) &&
            (identical(other.passed, passed) || other.passed == passed) &&
            (identical(other.passPercent, passPercent) ||
                other.passPercent == passPercent) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.showCorrectAnswers, showCorrectAnswers) ||
                other.showCorrectAnswers == showCorrectAnswers) &&
            const DeepCollectionEquality().equals(
              other._questions,
              _questions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    attemptId,
    assignmentId,
    status,
    score,
    maxScore,
    percent,
    passed,
    passPercent,
    submittedAt,
    showCorrectAnswers,
    const DeepCollectionEquality().hash(_questions),
  );

  /// Create a copy of AttemptResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttemptResultImplCopyWith<_$AttemptResultImpl> get copyWith =>
      __$$AttemptResultImplCopyWithImpl<_$AttemptResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AttemptResultImplToJson(this);
  }
}

abstract class _AttemptResult implements AttemptResult {
  const factory _AttemptResult({
    required final int attemptId,
    required final int assignmentId,
    required final String status,
    required final int score,
    required final int maxScore,
    required final int percent,
    required final bool passed,
    required final int passPercent,
    final DateTime? submittedAt,
    required final bool showCorrectAnswers,
    final List<ResultQuestion> questions,
  }) = _$AttemptResultImpl;

  factory _AttemptResult.fromJson(Map<String, dynamic> json) =
      _$AttemptResultImpl.fromJson;

  @override
  int get attemptId;
  @override
  int get assignmentId;
  @override
  String get status;
  @override
  int get score;
  @override
  int get maxScore;
  @override
  int get percent;
  @override
  bool get passed;
  @override
  int get passPercent;
  @override
  DateTime? get submittedAt;
  @override
  bool get showCorrectAnswers;
  @override
  List<ResultQuestion> get questions;

  /// Create a copy of AttemptResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttemptResultImplCopyWith<_$AttemptResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AttemptDetail _$AttemptDetailFromJson(Map<String, dynamic> json) {
  return _AttemptDetail.fromJson(json);
}

/// @nodoc
mixin _$AttemptDetail {
  AttemptBrief get attempt => throw _privateConstructorUsedError;
  StudentQuiz? get quiz => throw _privateConstructorUsedError;
  AttemptResult? get result => throw _privateConstructorUsedError;

  /// Serializes this AttemptDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AttemptDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttemptDetailCopyWith<AttemptDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttemptDetailCopyWith<$Res> {
  factory $AttemptDetailCopyWith(
    AttemptDetail value,
    $Res Function(AttemptDetail) then,
  ) = _$AttemptDetailCopyWithImpl<$Res, AttemptDetail>;
  @useResult
  $Res call({AttemptBrief attempt, StudentQuiz? quiz, AttemptResult? result});

  $AttemptBriefCopyWith<$Res> get attempt;
  $StudentQuizCopyWith<$Res>? get quiz;
  $AttemptResultCopyWith<$Res>? get result;
}

/// @nodoc
class _$AttemptDetailCopyWithImpl<$Res, $Val extends AttemptDetail>
    implements $AttemptDetailCopyWith<$Res> {
  _$AttemptDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttemptDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attempt = null,
    Object? quiz = freezed,
    Object? result = freezed,
  }) {
    return _then(
      _value.copyWith(
            attempt: null == attempt
                ? _value.attempt
                : attempt // ignore: cast_nullable_to_non_nullable
                      as AttemptBrief,
            quiz: freezed == quiz
                ? _value.quiz
                : quiz // ignore: cast_nullable_to_non_nullable
                      as StudentQuiz?,
            result: freezed == result
                ? _value.result
                : result // ignore: cast_nullable_to_non_nullable
                      as AttemptResult?,
          )
          as $Val,
    );
  }

  /// Create a copy of AttemptDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AttemptBriefCopyWith<$Res> get attempt {
    return $AttemptBriefCopyWith<$Res>(_value.attempt, (value) {
      return _then(_value.copyWith(attempt: value) as $Val);
    });
  }

  /// Create a copy of AttemptDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StudentQuizCopyWith<$Res>? get quiz {
    if (_value.quiz == null) {
      return null;
    }

    return $StudentQuizCopyWith<$Res>(_value.quiz!, (value) {
      return _then(_value.copyWith(quiz: value) as $Val);
    });
  }

  /// Create a copy of AttemptDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AttemptResultCopyWith<$Res>? get result {
    if (_value.result == null) {
      return null;
    }

    return $AttemptResultCopyWith<$Res>(_value.result!, (value) {
      return _then(_value.copyWith(result: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AttemptDetailImplCopyWith<$Res>
    implements $AttemptDetailCopyWith<$Res> {
  factory _$$AttemptDetailImplCopyWith(
    _$AttemptDetailImpl value,
    $Res Function(_$AttemptDetailImpl) then,
  ) = __$$AttemptDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({AttemptBrief attempt, StudentQuiz? quiz, AttemptResult? result});

  @override
  $AttemptBriefCopyWith<$Res> get attempt;
  @override
  $StudentQuizCopyWith<$Res>? get quiz;
  @override
  $AttemptResultCopyWith<$Res>? get result;
}

/// @nodoc
class __$$AttemptDetailImplCopyWithImpl<$Res>
    extends _$AttemptDetailCopyWithImpl<$Res, _$AttemptDetailImpl>
    implements _$$AttemptDetailImplCopyWith<$Res> {
  __$$AttemptDetailImplCopyWithImpl(
    _$AttemptDetailImpl _value,
    $Res Function(_$AttemptDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttemptDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attempt = null,
    Object? quiz = freezed,
    Object? result = freezed,
  }) {
    return _then(
      _$AttemptDetailImpl(
        attempt: null == attempt
            ? _value.attempt
            : attempt // ignore: cast_nullable_to_non_nullable
                  as AttemptBrief,
        quiz: freezed == quiz
            ? _value.quiz
            : quiz // ignore: cast_nullable_to_non_nullable
                  as StudentQuiz?,
        result: freezed == result
            ? _value.result
            : result // ignore: cast_nullable_to_non_nullable
                  as AttemptResult?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AttemptDetailImpl implements _AttemptDetail {
  const _$AttemptDetailImpl({required this.attempt, this.quiz, this.result});

  factory _$AttemptDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttemptDetailImplFromJson(json);

  @override
  final AttemptBrief attempt;
  @override
  final StudentQuiz? quiz;
  @override
  final AttemptResult? result;

  @override
  String toString() {
    return 'AttemptDetail(attempt: $attempt, quiz: $quiz, result: $result)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttemptDetailImpl &&
            (identical(other.attempt, attempt) || other.attempt == attempt) &&
            (identical(other.quiz, quiz) || other.quiz == quiz) &&
            (identical(other.result, result) || other.result == result));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, attempt, quiz, result);

  /// Create a copy of AttemptDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttemptDetailImplCopyWith<_$AttemptDetailImpl> get copyWith =>
      __$$AttemptDetailImplCopyWithImpl<_$AttemptDetailImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AttemptDetailImplToJson(this);
  }
}

abstract class _AttemptDetail implements AttemptDetail {
  const factory _AttemptDetail({
    required final AttemptBrief attempt,
    final StudentQuiz? quiz,
    final AttemptResult? result,
  }) = _$AttemptDetailImpl;

  factory _AttemptDetail.fromJson(Map<String, dynamic> json) =
      _$AttemptDetailImpl.fromJson;

  @override
  AttemptBrief get attempt;
  @override
  StudentQuiz? get quiz;
  @override
  AttemptResult? get result;

  /// Create a copy of AttemptDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttemptDetailImplCopyWith<_$AttemptDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuizHistoryItem _$QuizHistoryItemFromJson(Map<String, dynamic> json) {
  return _QuizHistoryItem.fromJson(json);
}

/// @nodoc
mixin _$QuizHistoryItem {
  int get attemptId => throw _privateConstructorUsedError;
  int get attemptNumber => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int? get score => throw _privateConstructorUsedError;
  int? get maxScore => throw _privateConstructorUsedError;
  int? get percent => throw _privateConstructorUsedError;
  bool? get passed => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get submittedAt => throw _privateConstructorUsedError;

  /// Serializes this QuizHistoryItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuizHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuizHistoryItemCopyWith<QuizHistoryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizHistoryItemCopyWith<$Res> {
  factory $QuizHistoryItemCopyWith(
    QuizHistoryItem value,
    $Res Function(QuizHistoryItem) then,
  ) = _$QuizHistoryItemCopyWithImpl<$Res, QuizHistoryItem>;
  @useResult
  $Res call({
    int attemptId,
    int attemptNumber,
    String status,
    int? score,
    int? maxScore,
    int? percent,
    bool? passed,
    DateTime startedAt,
    DateTime? submittedAt,
  });
}

/// @nodoc
class _$QuizHistoryItemCopyWithImpl<$Res, $Val extends QuizHistoryItem>
    implements $QuizHistoryItemCopyWith<$Res> {
  _$QuizHistoryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuizHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attemptId = null,
    Object? attemptNumber = null,
    Object? status = null,
    Object? score = freezed,
    Object? maxScore = freezed,
    Object? percent = freezed,
    Object? passed = freezed,
    Object? startedAt = null,
    Object? submittedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            attemptId: null == attemptId
                ? _value.attemptId
                : attemptId // ignore: cast_nullable_to_non_nullable
                      as int,
            attemptNumber: null == attemptNumber
                ? _value.attemptNumber
                : attemptNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            score: freezed == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int?,
            maxScore: freezed == maxScore
                ? _value.maxScore
                : maxScore // ignore: cast_nullable_to_non_nullable
                      as int?,
            percent: freezed == percent
                ? _value.percent
                : percent // ignore: cast_nullable_to_non_nullable
                      as int?,
            passed: freezed == passed
                ? _value.passed
                : passed // ignore: cast_nullable_to_non_nullable
                      as bool?,
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            submittedAt: freezed == submittedAt
                ? _value.submittedAt
                : submittedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuizHistoryItemImplCopyWith<$Res>
    implements $QuizHistoryItemCopyWith<$Res> {
  factory _$$QuizHistoryItemImplCopyWith(
    _$QuizHistoryItemImpl value,
    $Res Function(_$QuizHistoryItemImpl) then,
  ) = __$$QuizHistoryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int attemptId,
    int attemptNumber,
    String status,
    int? score,
    int? maxScore,
    int? percent,
    bool? passed,
    DateTime startedAt,
    DateTime? submittedAt,
  });
}

/// @nodoc
class __$$QuizHistoryItemImplCopyWithImpl<$Res>
    extends _$QuizHistoryItemCopyWithImpl<$Res, _$QuizHistoryItemImpl>
    implements _$$QuizHistoryItemImplCopyWith<$Res> {
  __$$QuizHistoryItemImplCopyWithImpl(
    _$QuizHistoryItemImpl _value,
    $Res Function(_$QuizHistoryItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuizHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attemptId = null,
    Object? attemptNumber = null,
    Object? status = null,
    Object? score = freezed,
    Object? maxScore = freezed,
    Object? percent = freezed,
    Object? passed = freezed,
    Object? startedAt = null,
    Object? submittedAt = freezed,
  }) {
    return _then(
      _$QuizHistoryItemImpl(
        attemptId: null == attemptId
            ? _value.attemptId
            : attemptId // ignore: cast_nullable_to_non_nullable
                  as int,
        attemptNumber: null == attemptNumber
            ? _value.attemptNumber
            : attemptNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        score: freezed == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int?,
        maxScore: freezed == maxScore
            ? _value.maxScore
            : maxScore // ignore: cast_nullable_to_non_nullable
                  as int?,
        percent: freezed == percent
            ? _value.percent
            : percent // ignore: cast_nullable_to_non_nullable
                  as int?,
        passed: freezed == passed
            ? _value.passed
            : passed // ignore: cast_nullable_to_non_nullable
                  as bool?,
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        submittedAt: freezed == submittedAt
            ? _value.submittedAt
            : submittedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuizHistoryItemImpl implements _QuizHistoryItem {
  const _$QuizHistoryItemImpl({
    required this.attemptId,
    required this.attemptNumber,
    required this.status,
    this.score,
    this.maxScore,
    this.percent,
    this.passed,
    required this.startedAt,
    this.submittedAt,
  });

  factory _$QuizHistoryItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuizHistoryItemImplFromJson(json);

  @override
  final int attemptId;
  @override
  final int attemptNumber;
  @override
  final String status;
  @override
  final int? score;
  @override
  final int? maxScore;
  @override
  final int? percent;
  @override
  final bool? passed;
  @override
  final DateTime startedAt;
  @override
  final DateTime? submittedAt;

  @override
  String toString() {
    return 'QuizHistoryItem(attemptId: $attemptId, attemptNumber: $attemptNumber, status: $status, score: $score, maxScore: $maxScore, percent: $percent, passed: $passed, startedAt: $startedAt, submittedAt: $submittedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizHistoryItemImpl &&
            (identical(other.attemptId, attemptId) ||
                other.attemptId == attemptId) &&
            (identical(other.attemptNumber, attemptNumber) ||
                other.attemptNumber == attemptNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.maxScore, maxScore) ||
                other.maxScore == maxScore) &&
            (identical(other.percent, percent) || other.percent == percent) &&
            (identical(other.passed, passed) || other.passed == passed) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    attemptId,
    attemptNumber,
    status,
    score,
    maxScore,
    percent,
    passed,
    startedAt,
    submittedAt,
  );

  /// Create a copy of QuizHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizHistoryItemImplCopyWith<_$QuizHistoryItemImpl> get copyWith =>
      __$$QuizHistoryItemImplCopyWithImpl<_$QuizHistoryItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$QuizHistoryItemImplToJson(this);
  }
}

abstract class _QuizHistoryItem implements QuizHistoryItem {
  const factory _QuizHistoryItem({
    required final int attemptId,
    required final int attemptNumber,
    required final String status,
    final int? score,
    final int? maxScore,
    final int? percent,
    final bool? passed,
    required final DateTime startedAt,
    final DateTime? submittedAt,
  }) = _$QuizHistoryItemImpl;

  factory _QuizHistoryItem.fromJson(Map<String, dynamic> json) =
      _$QuizHistoryItemImpl.fromJson;

  @override
  int get attemptId;
  @override
  int get attemptNumber;
  @override
  String get status;
  @override
  int? get score;
  @override
  int? get maxScore;
  @override
  int? get percent;
  @override
  bool? get passed;
  @override
  DateTime get startedAt;
  @override
  DateTime? get submittedAt;

  /// Create a copy of QuizHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuizHistoryItemImplCopyWith<_$QuizHistoryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuizAttemptHistory _$QuizAttemptHistoryFromJson(Map<String, dynamic> json) {
  return _QuizAttemptHistory.fromJson(json);
}

/// @nodoc
mixin _$QuizAttemptHistory {
  int get assignmentId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  int get passPercent => throw _privateConstructorUsedError;
  int? get maxAttempts => throw _privateConstructorUsedError;
  int get attemptsUsed => throw _privateConstructorUsedError;
  int? get attemptsLeft => throw _privateConstructorUsedError;
  bool get canStart => throw _privateConstructorUsedError;
  bool get passed => throw _privateConstructorUsedError;
  int? get bestScore => throw _privateConstructorUsedError;
  int? get bestMaxScore => throw _privateConstructorUsedError;
  int? get bestPercent => throw _privateConstructorUsedError;
  int? get inProgressId => throw _privateConstructorUsedError;
  List<QuizHistoryItem> get attempts => throw _privateConstructorUsedError;

  /// Serializes this QuizAttemptHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuizAttemptHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuizAttemptHistoryCopyWith<QuizAttemptHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizAttemptHistoryCopyWith<$Res> {
  factory $QuizAttemptHistoryCopyWith(
    QuizAttemptHistory value,
    $Res Function(QuizAttemptHistory) then,
  ) = _$QuizAttemptHistoryCopyWithImpl<$Res, QuizAttemptHistory>;
  @useResult
  $Res call({
    int assignmentId,
    String title,
    int passPercent,
    int? maxAttempts,
    int attemptsUsed,
    int? attemptsLeft,
    bool canStart,
    bool passed,
    int? bestScore,
    int? bestMaxScore,
    int? bestPercent,
    int? inProgressId,
    List<QuizHistoryItem> attempts,
  });
}

/// @nodoc
class _$QuizAttemptHistoryCopyWithImpl<$Res, $Val extends QuizAttemptHistory>
    implements $QuizAttemptHistoryCopyWith<$Res> {
  _$QuizAttemptHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuizAttemptHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assignmentId = null,
    Object? title = null,
    Object? passPercent = null,
    Object? maxAttempts = freezed,
    Object? attemptsUsed = null,
    Object? attemptsLeft = freezed,
    Object? canStart = null,
    Object? passed = null,
    Object? bestScore = freezed,
    Object? bestMaxScore = freezed,
    Object? bestPercent = freezed,
    Object? inProgressId = freezed,
    Object? attempts = null,
  }) {
    return _then(
      _value.copyWith(
            assignmentId: null == assignmentId
                ? _value.assignmentId
                : assignmentId // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            passPercent: null == passPercent
                ? _value.passPercent
                : passPercent // ignore: cast_nullable_to_non_nullable
                      as int,
            maxAttempts: freezed == maxAttempts
                ? _value.maxAttempts
                : maxAttempts // ignore: cast_nullable_to_non_nullable
                      as int?,
            attemptsUsed: null == attemptsUsed
                ? _value.attemptsUsed
                : attemptsUsed // ignore: cast_nullable_to_non_nullable
                      as int,
            attemptsLeft: freezed == attemptsLeft
                ? _value.attemptsLeft
                : attemptsLeft // ignore: cast_nullable_to_non_nullable
                      as int?,
            canStart: null == canStart
                ? _value.canStart
                : canStart // ignore: cast_nullable_to_non_nullable
                      as bool,
            passed: null == passed
                ? _value.passed
                : passed // ignore: cast_nullable_to_non_nullable
                      as bool,
            bestScore: freezed == bestScore
                ? _value.bestScore
                : bestScore // ignore: cast_nullable_to_non_nullable
                      as int?,
            bestMaxScore: freezed == bestMaxScore
                ? _value.bestMaxScore
                : bestMaxScore // ignore: cast_nullable_to_non_nullable
                      as int?,
            bestPercent: freezed == bestPercent
                ? _value.bestPercent
                : bestPercent // ignore: cast_nullable_to_non_nullable
                      as int?,
            inProgressId: freezed == inProgressId
                ? _value.inProgressId
                : inProgressId // ignore: cast_nullable_to_non_nullable
                      as int?,
            attempts: null == attempts
                ? _value.attempts
                : attempts // ignore: cast_nullable_to_non_nullable
                      as List<QuizHistoryItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuizAttemptHistoryImplCopyWith<$Res>
    implements $QuizAttemptHistoryCopyWith<$Res> {
  factory _$$QuizAttemptHistoryImplCopyWith(
    _$QuizAttemptHistoryImpl value,
    $Res Function(_$QuizAttemptHistoryImpl) then,
  ) = __$$QuizAttemptHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int assignmentId,
    String title,
    int passPercent,
    int? maxAttempts,
    int attemptsUsed,
    int? attemptsLeft,
    bool canStart,
    bool passed,
    int? bestScore,
    int? bestMaxScore,
    int? bestPercent,
    int? inProgressId,
    List<QuizHistoryItem> attempts,
  });
}

/// @nodoc
class __$$QuizAttemptHistoryImplCopyWithImpl<$Res>
    extends _$QuizAttemptHistoryCopyWithImpl<$Res, _$QuizAttemptHistoryImpl>
    implements _$$QuizAttemptHistoryImplCopyWith<$Res> {
  __$$QuizAttemptHistoryImplCopyWithImpl(
    _$QuizAttemptHistoryImpl _value,
    $Res Function(_$QuizAttemptHistoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuizAttemptHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assignmentId = null,
    Object? title = null,
    Object? passPercent = null,
    Object? maxAttempts = freezed,
    Object? attemptsUsed = null,
    Object? attemptsLeft = freezed,
    Object? canStart = null,
    Object? passed = null,
    Object? bestScore = freezed,
    Object? bestMaxScore = freezed,
    Object? bestPercent = freezed,
    Object? inProgressId = freezed,
    Object? attempts = null,
  }) {
    return _then(
      _$QuizAttemptHistoryImpl(
        assignmentId: null == assignmentId
            ? _value.assignmentId
            : assignmentId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        passPercent: null == passPercent
            ? _value.passPercent
            : passPercent // ignore: cast_nullable_to_non_nullable
                  as int,
        maxAttempts: freezed == maxAttempts
            ? _value.maxAttempts
            : maxAttempts // ignore: cast_nullable_to_non_nullable
                  as int?,
        attemptsUsed: null == attemptsUsed
            ? _value.attemptsUsed
            : attemptsUsed // ignore: cast_nullable_to_non_nullable
                  as int,
        attemptsLeft: freezed == attemptsLeft
            ? _value.attemptsLeft
            : attemptsLeft // ignore: cast_nullable_to_non_nullable
                  as int?,
        canStart: null == canStart
            ? _value.canStart
            : canStart // ignore: cast_nullable_to_non_nullable
                  as bool,
        passed: null == passed
            ? _value.passed
            : passed // ignore: cast_nullable_to_non_nullable
                  as bool,
        bestScore: freezed == bestScore
            ? _value.bestScore
            : bestScore // ignore: cast_nullable_to_non_nullable
                  as int?,
        bestMaxScore: freezed == bestMaxScore
            ? _value.bestMaxScore
            : bestMaxScore // ignore: cast_nullable_to_non_nullable
                  as int?,
        bestPercent: freezed == bestPercent
            ? _value.bestPercent
            : bestPercent // ignore: cast_nullable_to_non_nullable
                  as int?,
        inProgressId: freezed == inProgressId
            ? _value.inProgressId
            : inProgressId // ignore: cast_nullable_to_non_nullable
                  as int?,
        attempts: null == attempts
            ? _value._attempts
            : attempts // ignore: cast_nullable_to_non_nullable
                  as List<QuizHistoryItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuizAttemptHistoryImpl implements _QuizAttemptHistory {
  const _$QuizAttemptHistoryImpl({
    required this.assignmentId,
    required this.title,
    required this.passPercent,
    this.maxAttempts,
    required this.attemptsUsed,
    this.attemptsLeft,
    required this.canStart,
    required this.passed,
    this.bestScore,
    this.bestMaxScore,
    this.bestPercent,
    this.inProgressId,
    final List<QuizHistoryItem> attempts = const [],
  }) : _attempts = attempts;

  factory _$QuizAttemptHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuizAttemptHistoryImplFromJson(json);

  @override
  final int assignmentId;
  @override
  final String title;
  @override
  final int passPercent;
  @override
  final int? maxAttempts;
  @override
  final int attemptsUsed;
  @override
  final int? attemptsLeft;
  @override
  final bool canStart;
  @override
  final bool passed;
  @override
  final int? bestScore;
  @override
  final int? bestMaxScore;
  @override
  final int? bestPercent;
  @override
  final int? inProgressId;
  final List<QuizHistoryItem> _attempts;
  @override
  @JsonKey()
  List<QuizHistoryItem> get attempts {
    if (_attempts is EqualUnmodifiableListView) return _attempts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attempts);
  }

  @override
  String toString() {
    return 'QuizAttemptHistory(assignmentId: $assignmentId, title: $title, passPercent: $passPercent, maxAttempts: $maxAttempts, attemptsUsed: $attemptsUsed, attemptsLeft: $attemptsLeft, canStart: $canStart, passed: $passed, bestScore: $bestScore, bestMaxScore: $bestMaxScore, bestPercent: $bestPercent, inProgressId: $inProgressId, attempts: $attempts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizAttemptHistoryImpl &&
            (identical(other.assignmentId, assignmentId) ||
                other.assignmentId == assignmentId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.passPercent, passPercent) ||
                other.passPercent == passPercent) &&
            (identical(other.maxAttempts, maxAttempts) ||
                other.maxAttempts == maxAttempts) &&
            (identical(other.attemptsUsed, attemptsUsed) ||
                other.attemptsUsed == attemptsUsed) &&
            (identical(other.attemptsLeft, attemptsLeft) ||
                other.attemptsLeft == attemptsLeft) &&
            (identical(other.canStart, canStart) ||
                other.canStart == canStart) &&
            (identical(other.passed, passed) || other.passed == passed) &&
            (identical(other.bestScore, bestScore) ||
                other.bestScore == bestScore) &&
            (identical(other.bestMaxScore, bestMaxScore) ||
                other.bestMaxScore == bestMaxScore) &&
            (identical(other.bestPercent, bestPercent) ||
                other.bestPercent == bestPercent) &&
            (identical(other.inProgressId, inProgressId) ||
                other.inProgressId == inProgressId) &&
            const DeepCollectionEquality().equals(other._attempts, _attempts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    assignmentId,
    title,
    passPercent,
    maxAttempts,
    attemptsUsed,
    attemptsLeft,
    canStart,
    passed,
    bestScore,
    bestMaxScore,
    bestPercent,
    inProgressId,
    const DeepCollectionEquality().hash(_attempts),
  );

  /// Create a copy of QuizAttemptHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizAttemptHistoryImplCopyWith<_$QuizAttemptHistoryImpl> get copyWith =>
      __$$QuizAttemptHistoryImplCopyWithImpl<_$QuizAttemptHistoryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$QuizAttemptHistoryImplToJson(this);
  }
}

abstract class _QuizAttemptHistory implements QuizAttemptHistory {
  const factory _QuizAttemptHistory({
    required final int assignmentId,
    required final String title,
    required final int passPercent,
    final int? maxAttempts,
    required final int attemptsUsed,
    final int? attemptsLeft,
    required final bool canStart,
    required final bool passed,
    final int? bestScore,
    final int? bestMaxScore,
    final int? bestPercent,
    final int? inProgressId,
    final List<QuizHistoryItem> attempts,
  }) = _$QuizAttemptHistoryImpl;

  factory _QuizAttemptHistory.fromJson(Map<String, dynamic> json) =
      _$QuizAttemptHistoryImpl.fromJson;

  @override
  int get assignmentId;
  @override
  String get title;
  @override
  int get passPercent;
  @override
  int? get maxAttempts;
  @override
  int get attemptsUsed;
  @override
  int? get attemptsLeft;
  @override
  bool get canStart;
  @override
  bool get passed;
  @override
  int? get bestScore;
  @override
  int? get bestMaxScore;
  @override
  int? get bestPercent;
  @override
  int? get inProgressId;
  @override
  List<QuizHistoryItem> get attempts;

  /// Create a copy of QuizAttemptHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuizAttemptHistoryImplCopyWith<_$QuizAttemptHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
