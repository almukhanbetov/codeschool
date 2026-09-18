// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'enrollment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CourseBrief _$CourseBriefFromJson(Map<String, dynamic> json) {
  return _CourseBrief.fromJson(json);
}

/// @nodoc
mixin _$CourseBrief {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String? get shortDescription => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  int? get durationLessons => throw _privateConstructorUsedError;

  /// Serializes this CourseBrief to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CourseBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CourseBriefCopyWith<CourseBrief> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CourseBriefCopyWith<$Res> {
  factory $CourseBriefCopyWith(
    CourseBrief value,
    $Res Function(CourseBrief) then,
  ) = _$CourseBriefCopyWithImpl<$Res, CourseBrief>;
  @useResult
  $Res call({
    int id,
    String title,
    String slug,
    String? shortDescription,
    String? imageUrl,
    int? durationLessons,
  });
}

/// @nodoc
class _$CourseBriefCopyWithImpl<$Res, $Val extends CourseBrief>
    implements $CourseBriefCopyWith<$Res> {
  _$CourseBriefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CourseBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? slug = null,
    Object? shortDescription = freezed,
    Object? imageUrl = freezed,
    Object? durationLessons = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            slug: null == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String,
            shortDescription: freezed == shortDescription
                ? _value.shortDescription
                : shortDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            durationLessons: freezed == durationLessons
                ? _value.durationLessons
                : durationLessons // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CourseBriefImplCopyWith<$Res>
    implements $CourseBriefCopyWith<$Res> {
  factory _$$CourseBriefImplCopyWith(
    _$CourseBriefImpl value,
    $Res Function(_$CourseBriefImpl) then,
  ) = __$$CourseBriefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    String slug,
    String? shortDescription,
    String? imageUrl,
    int? durationLessons,
  });
}

/// @nodoc
class __$$CourseBriefImplCopyWithImpl<$Res>
    extends _$CourseBriefCopyWithImpl<$Res, _$CourseBriefImpl>
    implements _$$CourseBriefImplCopyWith<$Res> {
  __$$CourseBriefImplCopyWithImpl(
    _$CourseBriefImpl _value,
    $Res Function(_$CourseBriefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CourseBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? slug = null,
    Object? shortDescription = freezed,
    Object? imageUrl = freezed,
    Object? durationLessons = freezed,
  }) {
    return _then(
      _$CourseBriefImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        shortDescription: freezed == shortDescription
            ? _value.shortDescription
            : shortDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        durationLessons: freezed == durationLessons
            ? _value.durationLessons
            : durationLessons // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CourseBriefImpl implements _CourseBrief {
  const _$CourseBriefImpl({
    required this.id,
    required this.title,
    required this.slug,
    this.shortDescription,
    this.imageUrl,
    this.durationLessons,
  });

  factory _$CourseBriefImpl.fromJson(Map<String, dynamic> json) =>
      _$$CourseBriefImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String slug;
  @override
  final String? shortDescription;
  @override
  final String? imageUrl;
  @override
  final int? durationLessons;

  @override
  String toString() {
    return 'CourseBrief(id: $id, title: $title, slug: $slug, shortDescription: $shortDescription, imageUrl: $imageUrl, durationLessons: $durationLessons)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CourseBriefImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.shortDescription, shortDescription) ||
                other.shortDescription == shortDescription) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.durationLessons, durationLessons) ||
                other.durationLessons == durationLessons));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    slug,
    shortDescription,
    imageUrl,
    durationLessons,
  );

  /// Create a copy of CourseBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CourseBriefImplCopyWith<_$CourseBriefImpl> get copyWith =>
      __$$CourseBriefImplCopyWithImpl<_$CourseBriefImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CourseBriefImplToJson(this);
  }
}

abstract class _CourseBrief implements CourseBrief {
  const factory _CourseBrief({
    required final int id,
    required final String title,
    required final String slug,
    final String? shortDescription,
    final String? imageUrl,
    final int? durationLessons,
  }) = _$CourseBriefImpl;

  factory _CourseBrief.fromJson(Map<String, dynamic> json) =
      _$CourseBriefImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String get slug;
  @override
  String? get shortDescription;
  @override
  String? get imageUrl;
  @override
  int? get durationLessons;

  /// Create a copy of CourseBrief
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CourseBriefImplCopyWith<_$CourseBriefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Enrollment _$EnrollmentFromJson(Map<String, dynamic> json) {
  return _Enrollment.fromJson(json);
}

/// @nodoc
mixin _$Enrollment {
  int get id => throw _privateConstructorUsedError;
  int get studentId => throw _privateConstructorUsedError;
  int get courseId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime get enrolledAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this Enrollment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Enrollment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EnrollmentCopyWith<Enrollment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EnrollmentCopyWith<$Res> {
  factory $EnrollmentCopyWith(
    Enrollment value,
    $Res Function(Enrollment) then,
  ) = _$EnrollmentCopyWithImpl<$Res, Enrollment>;
  @useResult
  $Res call({
    int id,
    int studentId,
    int courseId,
    String status,
    DateTime enrolledAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class _$EnrollmentCopyWithImpl<$Res, $Val extends Enrollment>
    implements $EnrollmentCopyWith<$Res> {
  _$EnrollmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Enrollment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? courseId = null,
    Object? status = null,
    Object? enrolledAt = null,
    Object? completedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as int,
            courseId: null == courseId
                ? _value.courseId
                : courseId // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            enrolledAt: null == enrolledAt
                ? _value.enrolledAt
                : enrolledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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
abstract class _$$EnrollmentImplCopyWith<$Res>
    implements $EnrollmentCopyWith<$Res> {
  factory _$$EnrollmentImplCopyWith(
    _$EnrollmentImpl value,
    $Res Function(_$EnrollmentImpl) then,
  ) = __$$EnrollmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int studentId,
    int courseId,
    String status,
    DateTime enrolledAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class __$$EnrollmentImplCopyWithImpl<$Res>
    extends _$EnrollmentCopyWithImpl<$Res, _$EnrollmentImpl>
    implements _$$EnrollmentImplCopyWith<$Res> {
  __$$EnrollmentImplCopyWithImpl(
    _$EnrollmentImpl _value,
    $Res Function(_$EnrollmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Enrollment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? courseId = null,
    Object? status = null,
    Object? enrolledAt = null,
    Object? completedAt = freezed,
  }) {
    return _then(
      _$EnrollmentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as int,
        courseId: null == courseId
            ? _value.courseId
            : courseId // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        enrolledAt: null == enrolledAt
            ? _value.enrolledAt
            : enrolledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
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
class _$EnrollmentImpl implements _Enrollment {
  const _$EnrollmentImpl({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.status,
    required this.enrolledAt,
    this.completedAt,
  });

  factory _$EnrollmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$EnrollmentImplFromJson(json);

  @override
  final int id;
  @override
  final int studentId;
  @override
  final int courseId;
  @override
  final String status;
  @override
  final DateTime enrolledAt;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'Enrollment(id: $id, studentId: $studentId, courseId: $courseId, status: $status, enrolledAt: $enrolledAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EnrollmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.courseId, courseId) ||
                other.courseId == courseId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.enrolledAt, enrolledAt) ||
                other.enrolledAt == enrolledAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    studentId,
    courseId,
    status,
    enrolledAt,
    completedAt,
  );

  /// Create a copy of Enrollment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EnrollmentImplCopyWith<_$EnrollmentImpl> get copyWith =>
      __$$EnrollmentImplCopyWithImpl<_$EnrollmentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EnrollmentImplToJson(this);
  }
}

abstract class _Enrollment implements Enrollment {
  const factory _Enrollment({
    required final int id,
    required final int studentId,
    required final int courseId,
    required final String status,
    required final DateTime enrolledAt,
    final DateTime? completedAt,
  }) = _$EnrollmentImpl;

  factory _Enrollment.fromJson(Map<String, dynamic> json) =
      _$EnrollmentImpl.fromJson;

  @override
  int get id;
  @override
  int get studentId;
  @override
  int get courseId;
  @override
  String get status;
  @override
  DateTime get enrolledAt;
  @override
  DateTime? get completedAt;

  /// Create a copy of Enrollment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EnrollmentImplCopyWith<_$EnrollmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MyCourseItem _$MyCourseItemFromJson(Map<String, dynamic> json) {
  return _MyCourseItem.fromJson(json);
}

/// @nodoc
mixin _$MyCourseItem {
  int get enrollmentId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime get enrolledAt => throw _privateConstructorUsedError;
  CourseBrief get course => throw _privateConstructorUsedError;

  /// Serializes this MyCourseItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MyCourseItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MyCourseItemCopyWith<MyCourseItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyCourseItemCopyWith<$Res> {
  factory $MyCourseItemCopyWith(
    MyCourseItem value,
    $Res Function(MyCourseItem) then,
  ) = _$MyCourseItemCopyWithImpl<$Res, MyCourseItem>;
  @useResult
  $Res call({
    int enrollmentId,
    String status,
    DateTime enrolledAt,
    CourseBrief course,
  });

  $CourseBriefCopyWith<$Res> get course;
}

/// @nodoc
class _$MyCourseItemCopyWithImpl<$Res, $Val extends MyCourseItem>
    implements $MyCourseItemCopyWith<$Res> {
  _$MyCourseItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MyCourseItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enrollmentId = null,
    Object? status = null,
    Object? enrolledAt = null,
    Object? course = null,
  }) {
    return _then(
      _value.copyWith(
            enrollmentId: null == enrollmentId
                ? _value.enrollmentId
                : enrollmentId // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            enrolledAt: null == enrolledAt
                ? _value.enrolledAt
                : enrolledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            course: null == course
                ? _value.course
                : course // ignore: cast_nullable_to_non_nullable
                      as CourseBrief,
          )
          as $Val,
    );
  }

  /// Create a copy of MyCourseItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CourseBriefCopyWith<$Res> get course {
    return $CourseBriefCopyWith<$Res>(_value.course, (value) {
      return _then(_value.copyWith(course: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MyCourseItemImplCopyWith<$Res>
    implements $MyCourseItemCopyWith<$Res> {
  factory _$$MyCourseItemImplCopyWith(
    _$MyCourseItemImpl value,
    $Res Function(_$MyCourseItemImpl) then,
  ) = __$$MyCourseItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int enrollmentId,
    String status,
    DateTime enrolledAt,
    CourseBrief course,
  });

  @override
  $CourseBriefCopyWith<$Res> get course;
}

/// @nodoc
class __$$MyCourseItemImplCopyWithImpl<$Res>
    extends _$MyCourseItemCopyWithImpl<$Res, _$MyCourseItemImpl>
    implements _$$MyCourseItemImplCopyWith<$Res> {
  __$$MyCourseItemImplCopyWithImpl(
    _$MyCourseItemImpl _value,
    $Res Function(_$MyCourseItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MyCourseItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enrollmentId = null,
    Object? status = null,
    Object? enrolledAt = null,
    Object? course = null,
  }) {
    return _then(
      _$MyCourseItemImpl(
        enrollmentId: null == enrollmentId
            ? _value.enrollmentId
            : enrollmentId // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        enrolledAt: null == enrolledAt
            ? _value.enrolledAt
            : enrolledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        course: null == course
            ? _value.course
            : course // ignore: cast_nullable_to_non_nullable
                  as CourseBrief,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MyCourseItemImpl implements _MyCourseItem {
  const _$MyCourseItemImpl({
    required this.enrollmentId,
    required this.status,
    required this.enrolledAt,
    required this.course,
  });

  factory _$MyCourseItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$MyCourseItemImplFromJson(json);

  @override
  final int enrollmentId;
  @override
  final String status;
  @override
  final DateTime enrolledAt;
  @override
  final CourseBrief course;

  @override
  String toString() {
    return 'MyCourseItem(enrollmentId: $enrollmentId, status: $status, enrolledAt: $enrolledAt, course: $course)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MyCourseItemImpl &&
            (identical(other.enrollmentId, enrollmentId) ||
                other.enrollmentId == enrollmentId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.enrolledAt, enrolledAt) ||
                other.enrolledAt == enrolledAt) &&
            (identical(other.course, course) || other.course == course));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, enrollmentId, status, enrolledAt, course);

  /// Create a copy of MyCourseItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MyCourseItemImplCopyWith<_$MyCourseItemImpl> get copyWith =>
      __$$MyCourseItemImplCopyWithImpl<_$MyCourseItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MyCourseItemImplToJson(this);
  }
}

abstract class _MyCourseItem implements MyCourseItem {
  const factory _MyCourseItem({
    required final int enrollmentId,
    required final String status,
    required final DateTime enrolledAt,
    required final CourseBrief course,
  }) = _$MyCourseItemImpl;

  factory _MyCourseItem.fromJson(Map<String, dynamic> json) =
      _$MyCourseItemImpl.fromJson;

  @override
  int get enrollmentId;
  @override
  String get status;
  @override
  DateTime get enrolledAt;
  @override
  CourseBrief get course;

  /// Create a copy of MyCourseItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MyCourseItemImplCopyWith<_$MyCourseItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
