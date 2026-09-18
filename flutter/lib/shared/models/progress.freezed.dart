// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LessonProgress _$LessonProgressFromJson(Map<String, dynamic> json) {
  return _LessonProgress.fromJson(json);
}

/// @nodoc
mixin _$LessonProgress {
  int get lessonId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int get progressPercent => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this LessonProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LessonProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LessonProgressCopyWith<LessonProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonProgressCopyWith<$Res> {
  factory $LessonProgressCopyWith(
    LessonProgress value,
    $Res Function(LessonProgress) then,
  ) = _$LessonProgressCopyWithImpl<$Res, LessonProgress>;
  @useResult
  $Res call({
    int lessonId,
    String status,
    int progressPercent,
    DateTime? startedAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class _$LessonProgressCopyWithImpl<$Res, $Val extends LessonProgress>
    implements $LessonProgressCopyWith<$Res> {
  _$LessonProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LessonProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lessonId = null,
    Object? status = null,
    Object? progressPercent = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            lessonId: null == lessonId
                ? _value.lessonId
                : lessonId // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            progressPercent: null == progressPercent
                ? _value.progressPercent
                : progressPercent // ignore: cast_nullable_to_non_nullable
                      as int,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LessonProgressImplCopyWith<$Res>
    implements $LessonProgressCopyWith<$Res> {
  factory _$$LessonProgressImplCopyWith(
    _$LessonProgressImpl value,
    $Res Function(_$LessonProgressImpl) then,
  ) = __$$LessonProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int lessonId,
    String status,
    int progressPercent,
    DateTime? startedAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class __$$LessonProgressImplCopyWithImpl<$Res>
    extends _$LessonProgressCopyWithImpl<$Res, _$LessonProgressImpl>
    implements _$$LessonProgressImplCopyWith<$Res> {
  __$$LessonProgressImplCopyWithImpl(
    _$LessonProgressImpl _value,
    $Res Function(_$LessonProgressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LessonProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lessonId = null,
    Object? status = null,
    Object? progressPercent = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(
      _$LessonProgressImpl(
        lessonId: null == lessonId
            ? _value.lessonId
            : lessonId // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        progressPercent: null == progressPercent
            ? _value.progressPercent
            : progressPercent // ignore: cast_nullable_to_non_nullable
                  as int,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonProgressImpl implements _LessonProgress {
  const _$LessonProgressImpl({
    required this.lessonId,
    required this.status,
    required this.progressPercent,
    this.startedAt,
    this.completedAt,
  });

  factory _$LessonProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonProgressImplFromJson(json);

  @override
  final int lessonId;
  @override
  final String status;
  @override
  final int progressPercent;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'LessonProgress(lessonId: $lessonId, status: $status, progressPercent: $progressPercent, startedAt: $startedAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonProgressImpl &&
            (identical(other.lessonId, lessonId) ||
                other.lessonId == lessonId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.progressPercent, progressPercent) ||
                other.progressPercent == progressPercent) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    lessonId,
    status,
    progressPercent,
    startedAt,
    completedAt,
  );

  /// Create a copy of LessonProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonProgressImplCopyWith<_$LessonProgressImpl> get copyWith =>
      __$$LessonProgressImplCopyWithImpl<_$LessonProgressImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonProgressImplToJson(this);
  }
}

abstract class _LessonProgress implements LessonProgress {
  const factory _LessonProgress({
    required final int lessonId,
    required final String status,
    required final int progressPercent,
    final DateTime? startedAt,
    final DateTime? completedAt,
  }) = _$LessonProgressImpl;

  factory _LessonProgress.fromJson(Map<String, dynamic> json) =
      _$LessonProgressImpl.fromJson;

  @override
  int get lessonId;
  @override
  String get status;
  @override
  int get progressPercent;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;

  /// Create a copy of LessonProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LessonProgressImplCopyWith<_$LessonProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CourseProgress _$CourseProgressFromJson(Map<String, dynamic> json) {
  return _CourseProgress.fromJson(json);
}

/// @nodoc
mixin _$CourseProgress {
  int get courseId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  int get completedLessons => throw _privateConstructorUsedError;
  int get totalLessons => throw _privateConstructorUsedError;
  int get progressPercent => throw _privateConstructorUsedError;

  /// Serializes this CourseProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CourseProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CourseProgressCopyWith<CourseProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CourseProgressCopyWith<$Res> {
  factory $CourseProgressCopyWith(
    CourseProgress value,
    $Res Function(CourseProgress) then,
  ) = _$CourseProgressCopyWithImpl<$Res, CourseProgress>;
  @useResult
  $Res call({
    int courseId,
    String title,
    int completedLessons,
    int totalLessons,
    int progressPercent,
  });
}

/// @nodoc
class _$CourseProgressCopyWithImpl<$Res, $Val extends CourseProgress>
    implements $CourseProgressCopyWith<$Res> {
  _$CourseProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CourseProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? courseId = null,
    Object? title = null,
    Object? completedLessons = null,
    Object? totalLessons = null,
    Object? progressPercent = null,
  }) {
    return _then(
      _value.copyWith(
            courseId: null == courseId
                ? _value.courseId
                : courseId // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            completedLessons: null == completedLessons
                ? _value.completedLessons
                : completedLessons // ignore: cast_nullable_to_non_nullable
                      as int,
            totalLessons: null == totalLessons
                ? _value.totalLessons
                : totalLessons // ignore: cast_nullable_to_non_nullable
                      as int,
            progressPercent: null == progressPercent
                ? _value.progressPercent
                : progressPercent // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CourseProgressImplCopyWith<$Res>
    implements $CourseProgressCopyWith<$Res> {
  factory _$$CourseProgressImplCopyWith(
    _$CourseProgressImpl value,
    $Res Function(_$CourseProgressImpl) then,
  ) = __$$CourseProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int courseId,
    String title,
    int completedLessons,
    int totalLessons,
    int progressPercent,
  });
}

/// @nodoc
class __$$CourseProgressImplCopyWithImpl<$Res>
    extends _$CourseProgressCopyWithImpl<$Res, _$CourseProgressImpl>
    implements _$$CourseProgressImplCopyWith<$Res> {
  __$$CourseProgressImplCopyWithImpl(
    _$CourseProgressImpl _value,
    $Res Function(_$CourseProgressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CourseProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? courseId = null,
    Object? title = null,
    Object? completedLessons = null,
    Object? totalLessons = null,
    Object? progressPercent = null,
  }) {
    return _then(
      _$CourseProgressImpl(
        courseId: null == courseId
            ? _value.courseId
            : courseId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        completedLessons: null == completedLessons
            ? _value.completedLessons
            : completedLessons // ignore: cast_nullable_to_non_nullable
                  as int,
        totalLessons: null == totalLessons
            ? _value.totalLessons
            : totalLessons // ignore: cast_nullable_to_non_nullable
                  as int,
        progressPercent: null == progressPercent
            ? _value.progressPercent
            : progressPercent // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CourseProgressImpl implements _CourseProgress {
  const _$CourseProgressImpl({
    required this.courseId,
    required this.title,
    required this.completedLessons,
    required this.totalLessons,
    required this.progressPercent,
  });

  factory _$CourseProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$CourseProgressImplFromJson(json);

  @override
  final int courseId;
  @override
  final String title;
  @override
  final int completedLessons;
  @override
  final int totalLessons;
  @override
  final int progressPercent;

  @override
  String toString() {
    return 'CourseProgress(courseId: $courseId, title: $title, completedLessons: $completedLessons, totalLessons: $totalLessons, progressPercent: $progressPercent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CourseProgressImpl &&
            (identical(other.courseId, courseId) ||
                other.courseId == courseId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.completedLessons, completedLessons) ||
                other.completedLessons == completedLessons) &&
            (identical(other.totalLessons, totalLessons) ||
                other.totalLessons == totalLessons) &&
            (identical(other.progressPercent, progressPercent) ||
                other.progressPercent == progressPercent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    courseId,
    title,
    completedLessons,
    totalLessons,
    progressPercent,
  );

  /// Create a copy of CourseProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CourseProgressImplCopyWith<_$CourseProgressImpl> get copyWith =>
      __$$CourseProgressImplCopyWithImpl<_$CourseProgressImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CourseProgressImplToJson(this);
  }
}

abstract class _CourseProgress implements CourseProgress {
  const factory _CourseProgress({
    required final int courseId,
    required final String title,
    required final int completedLessons,
    required final int totalLessons,
    required final int progressPercent,
  }) = _$CourseProgressImpl;

  factory _CourseProgress.fromJson(Map<String, dynamic> json) =
      _$CourseProgressImpl.fromJson;

  @override
  int get courseId;
  @override
  String get title;
  @override
  int get completedLessons;
  @override
  int get totalLessons;
  @override
  int get progressPercent;

  /// Create a copy of CourseProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CourseProgressImplCopyWith<_$CourseProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CourseProgressDetail _$CourseProgressDetailFromJson(Map<String, dynamic> json) {
  return _CourseProgressDetail.fromJson(json);
}

/// @nodoc
mixin _$CourseProgressDetail {
  int get courseId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  int get completedLessons => throw _privateConstructorUsedError;
  int get totalLessons => throw _privateConstructorUsedError;
  int get progressPercent => throw _privateConstructorUsedError;
  String get enrollmentStatus => throw _privateConstructorUsedError;
  List<LessonProgress> get lessons => throw _privateConstructorUsedError;

  /// Serializes this CourseProgressDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CourseProgressDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CourseProgressDetailCopyWith<CourseProgressDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CourseProgressDetailCopyWith<$Res> {
  factory $CourseProgressDetailCopyWith(
    CourseProgressDetail value,
    $Res Function(CourseProgressDetail) then,
  ) = _$CourseProgressDetailCopyWithImpl<$Res, CourseProgressDetail>;
  @useResult
  $Res call({
    int courseId,
    String title,
    int completedLessons,
    int totalLessons,
    int progressPercent,
    String enrollmentStatus,
    List<LessonProgress> lessons,
  });
}

/// @nodoc
class _$CourseProgressDetailCopyWithImpl<
  $Res,
  $Val extends CourseProgressDetail
>
    implements $CourseProgressDetailCopyWith<$Res> {
  _$CourseProgressDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CourseProgressDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? courseId = null,
    Object? title = null,
    Object? completedLessons = null,
    Object? totalLessons = null,
    Object? progressPercent = null,
    Object? enrollmentStatus = null,
    Object? lessons = null,
  }) {
    return _then(
      _value.copyWith(
            courseId: null == courseId
                ? _value.courseId
                : courseId // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            completedLessons: null == completedLessons
                ? _value.completedLessons
                : completedLessons // ignore: cast_nullable_to_non_nullable
                      as int,
            totalLessons: null == totalLessons
                ? _value.totalLessons
                : totalLessons // ignore: cast_nullable_to_non_nullable
                      as int,
            progressPercent: null == progressPercent
                ? _value.progressPercent
                : progressPercent // ignore: cast_nullable_to_non_nullable
                      as int,
            enrollmentStatus: null == enrollmentStatus
                ? _value.enrollmentStatus
                : enrollmentStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            lessons: null == lessons
                ? _value.lessons
                : lessons // ignore: cast_nullable_to_non_nullable
                      as List<LessonProgress>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CourseProgressDetailImplCopyWith<$Res>
    implements $CourseProgressDetailCopyWith<$Res> {
  factory _$$CourseProgressDetailImplCopyWith(
    _$CourseProgressDetailImpl value,
    $Res Function(_$CourseProgressDetailImpl) then,
  ) = __$$CourseProgressDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int courseId,
    String title,
    int completedLessons,
    int totalLessons,
    int progressPercent,
    String enrollmentStatus,
    List<LessonProgress> lessons,
  });
}

/// @nodoc
class __$$CourseProgressDetailImplCopyWithImpl<$Res>
    extends _$CourseProgressDetailCopyWithImpl<$Res, _$CourseProgressDetailImpl>
    implements _$$CourseProgressDetailImplCopyWith<$Res> {
  __$$CourseProgressDetailImplCopyWithImpl(
    _$CourseProgressDetailImpl _value,
    $Res Function(_$CourseProgressDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CourseProgressDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? courseId = null,
    Object? title = null,
    Object? completedLessons = null,
    Object? totalLessons = null,
    Object? progressPercent = null,
    Object? enrollmentStatus = null,
    Object? lessons = null,
  }) {
    return _then(
      _$CourseProgressDetailImpl(
        courseId: null == courseId
            ? _value.courseId
            : courseId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        completedLessons: null == completedLessons
            ? _value.completedLessons
            : completedLessons // ignore: cast_nullable_to_non_nullable
                  as int,
        totalLessons: null == totalLessons
            ? _value.totalLessons
            : totalLessons // ignore: cast_nullable_to_non_nullable
                  as int,
        progressPercent: null == progressPercent
            ? _value.progressPercent
            : progressPercent // ignore: cast_nullable_to_non_nullable
                  as int,
        enrollmentStatus: null == enrollmentStatus
            ? _value.enrollmentStatus
            : enrollmentStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        lessons: null == lessons
            ? _value._lessons
            : lessons // ignore: cast_nullable_to_non_nullable
                  as List<LessonProgress>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CourseProgressDetailImpl implements _CourseProgressDetail {
  const _$CourseProgressDetailImpl({
    required this.courseId,
    required this.title,
    required this.completedLessons,
    required this.totalLessons,
    required this.progressPercent,
    required this.enrollmentStatus,
    final List<LessonProgress> lessons = const [],
  }) : _lessons = lessons;

  factory _$CourseProgressDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$CourseProgressDetailImplFromJson(json);

  @override
  final int courseId;
  @override
  final String title;
  @override
  final int completedLessons;
  @override
  final int totalLessons;
  @override
  final int progressPercent;
  @override
  final String enrollmentStatus;
  final List<LessonProgress> _lessons;
  @override
  @JsonKey()
  List<LessonProgress> get lessons {
    if (_lessons is EqualUnmodifiableListView) return _lessons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lessons);
  }

  @override
  String toString() {
    return 'CourseProgressDetail(courseId: $courseId, title: $title, completedLessons: $completedLessons, totalLessons: $totalLessons, progressPercent: $progressPercent, enrollmentStatus: $enrollmentStatus, lessons: $lessons)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CourseProgressDetailImpl &&
            (identical(other.courseId, courseId) ||
                other.courseId == courseId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.completedLessons, completedLessons) ||
                other.completedLessons == completedLessons) &&
            (identical(other.totalLessons, totalLessons) ||
                other.totalLessons == totalLessons) &&
            (identical(other.progressPercent, progressPercent) ||
                other.progressPercent == progressPercent) &&
            (identical(other.enrollmentStatus, enrollmentStatus) ||
                other.enrollmentStatus == enrollmentStatus) &&
            const DeepCollectionEquality().equals(other._lessons, _lessons));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    courseId,
    title,
    completedLessons,
    totalLessons,
    progressPercent,
    enrollmentStatus,
    const DeepCollectionEquality().hash(_lessons),
  );

  /// Create a copy of CourseProgressDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CourseProgressDetailImplCopyWith<_$CourseProgressDetailImpl>
  get copyWith =>
      __$$CourseProgressDetailImplCopyWithImpl<_$CourseProgressDetailImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CourseProgressDetailImplToJson(this);
  }
}

abstract class _CourseProgressDetail implements CourseProgressDetail {
  const factory _CourseProgressDetail({
    required final int courseId,
    required final String title,
    required final int completedLessons,
    required final int totalLessons,
    required final int progressPercent,
    required final String enrollmentStatus,
    final List<LessonProgress> lessons,
  }) = _$CourseProgressDetailImpl;

  factory _CourseProgressDetail.fromJson(Map<String, dynamic> json) =
      _$CourseProgressDetailImpl.fromJson;

  @override
  int get courseId;
  @override
  String get title;
  @override
  int get completedLessons;
  @override
  int get totalLessons;
  @override
  int get progressPercent;
  @override
  String get enrollmentStatus;
  @override
  List<LessonProgress> get lessons;

  /// Create a copy of CourseProgressDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CourseProgressDetailImplCopyWith<_$CourseProgressDetailImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CompleteLessonResult _$CompleteLessonResultFromJson(Map<String, dynamic> json) {
  return _CompleteLessonResult.fromJson(json);
}

/// @nodoc
mixin _$CompleteLessonResult {
  LessonProgress get lesson => throw _privateConstructorUsedError;
  CourseProgress get course => throw _privateConstructorUsedError;
  bool get enrollmentCompleted => throw _privateConstructorUsedError;

  /// Serializes this CompleteLessonResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CompleteLessonResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompleteLessonResultCopyWith<CompleteLessonResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompleteLessonResultCopyWith<$Res> {
  factory $CompleteLessonResultCopyWith(
    CompleteLessonResult value,
    $Res Function(CompleteLessonResult) then,
  ) = _$CompleteLessonResultCopyWithImpl<$Res, CompleteLessonResult>;
  @useResult
  $Res call({
    LessonProgress lesson,
    CourseProgress course,
    bool enrollmentCompleted,
  });

  $LessonProgressCopyWith<$Res> get lesson;
  $CourseProgressCopyWith<$Res> get course;
}

/// @nodoc
class _$CompleteLessonResultCopyWithImpl<
  $Res,
  $Val extends CompleteLessonResult
>
    implements $CompleteLessonResultCopyWith<$Res> {
  _$CompleteLessonResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompleteLessonResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lesson = null,
    Object? course = null,
    Object? enrollmentCompleted = null,
  }) {
    return _then(
      _value.copyWith(
            lesson: null == lesson
                ? _value.lesson
                : lesson // ignore: cast_nullable_to_non_nullable
                      as LessonProgress,
            course: null == course
                ? _value.course
                : course // ignore: cast_nullable_to_non_nullable
                      as CourseProgress,
            enrollmentCompleted: null == enrollmentCompleted
                ? _value.enrollmentCompleted
                : enrollmentCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of CompleteLessonResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LessonProgressCopyWith<$Res> get lesson {
    return $LessonProgressCopyWith<$Res>(_value.lesson, (value) {
      return _then(_value.copyWith(lesson: value) as $Val);
    });
  }

  /// Create a copy of CompleteLessonResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CourseProgressCopyWith<$Res> get course {
    return $CourseProgressCopyWith<$Res>(_value.course, (value) {
      return _then(_value.copyWith(course: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CompleteLessonResultImplCopyWith<$Res>
    implements $CompleteLessonResultCopyWith<$Res> {
  factory _$$CompleteLessonResultImplCopyWith(
    _$CompleteLessonResultImpl value,
    $Res Function(_$CompleteLessonResultImpl) then,
  ) = __$$CompleteLessonResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    LessonProgress lesson,
    CourseProgress course,
    bool enrollmentCompleted,
  });

  @override
  $LessonProgressCopyWith<$Res> get lesson;
  @override
  $CourseProgressCopyWith<$Res> get course;
}

/// @nodoc
class __$$CompleteLessonResultImplCopyWithImpl<$Res>
    extends _$CompleteLessonResultCopyWithImpl<$Res, _$CompleteLessonResultImpl>
    implements _$$CompleteLessonResultImplCopyWith<$Res> {
  __$$CompleteLessonResultImplCopyWithImpl(
    _$CompleteLessonResultImpl _value,
    $Res Function(_$CompleteLessonResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CompleteLessonResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lesson = null,
    Object? course = null,
    Object? enrollmentCompleted = null,
  }) {
    return _then(
      _$CompleteLessonResultImpl(
        lesson: null == lesson
            ? _value.lesson
            : lesson // ignore: cast_nullable_to_non_nullable
                  as LessonProgress,
        course: null == course
            ? _value.course
            : course // ignore: cast_nullable_to_non_nullable
                  as CourseProgress,
        enrollmentCompleted: null == enrollmentCompleted
            ? _value.enrollmentCompleted
            : enrollmentCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CompleteLessonResultImpl implements _CompleteLessonResult {
  const _$CompleteLessonResultImpl({
    required this.lesson,
    required this.course,
    required this.enrollmentCompleted,
  });

  factory _$CompleteLessonResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompleteLessonResultImplFromJson(json);

  @override
  final LessonProgress lesson;
  @override
  final CourseProgress course;
  @override
  final bool enrollmentCompleted;

  @override
  String toString() {
    return 'CompleteLessonResult(lesson: $lesson, course: $course, enrollmentCompleted: $enrollmentCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompleteLessonResultImpl &&
            (identical(other.lesson, lesson) || other.lesson == lesson) &&
            (identical(other.course, course) || other.course == course) &&
            (identical(other.enrollmentCompleted, enrollmentCompleted) ||
                other.enrollmentCompleted == enrollmentCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, lesson, course, enrollmentCompleted);

  /// Create a copy of CompleteLessonResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompleteLessonResultImplCopyWith<_$CompleteLessonResultImpl>
  get copyWith =>
      __$$CompleteLessonResultImplCopyWithImpl<_$CompleteLessonResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CompleteLessonResultImplToJson(this);
  }
}

abstract class _CompleteLessonResult implements CompleteLessonResult {
  const factory _CompleteLessonResult({
    required final LessonProgress lesson,
    required final CourseProgress course,
    required final bool enrollmentCompleted,
  }) = _$CompleteLessonResultImpl;

  factory _CompleteLessonResult.fromJson(Map<String, dynamic> json) =
      _$CompleteLessonResultImpl.fromJson;

  @override
  LessonProgress get lesson;
  @override
  CourseProgress get course;
  @override
  bool get enrollmentCompleted;

  /// Create a copy of CompleteLessonResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompleteLessonResultImplCopyWith<_$CompleteLessonResultImpl>
  get copyWith => throw _privateConstructorUsedError;
}
