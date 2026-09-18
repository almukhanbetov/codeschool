// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'teacher.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TeacherCourseBrief _$TeacherCourseBriefFromJson(Map<String, dynamic> json) {
  return _TeacherCourseBrief.fromJson(json);
}

/// @nodoc
mixin _$TeacherCourseBrief {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;

  /// Serializes this TeacherCourseBrief to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherCourseBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherCourseBriefCopyWith<TeacherCourseBrief> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherCourseBriefCopyWith<$Res> {
  factory $TeacherCourseBriefCopyWith(
    TeacherCourseBrief value,
    $Res Function(TeacherCourseBrief) then,
  ) = _$TeacherCourseBriefCopyWithImpl<$Res, TeacherCourseBrief>;
  @useResult
  $Res call({int id, String title, String slug});
}

/// @nodoc
class _$TeacherCourseBriefCopyWithImpl<$Res, $Val extends TeacherCourseBrief>
    implements $TeacherCourseBriefCopyWith<$Res> {
  _$TeacherCourseBriefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherCourseBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? title = null, Object? slug = null}) {
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeacherCourseBriefImplCopyWith<$Res>
    implements $TeacherCourseBriefCopyWith<$Res> {
  factory _$$TeacherCourseBriefImplCopyWith(
    _$TeacherCourseBriefImpl value,
    $Res Function(_$TeacherCourseBriefImpl) then,
  ) = __$$TeacherCourseBriefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String title, String slug});
}

/// @nodoc
class __$$TeacherCourseBriefImplCopyWithImpl<$Res>
    extends _$TeacherCourseBriefCopyWithImpl<$Res, _$TeacherCourseBriefImpl>
    implements _$$TeacherCourseBriefImplCopyWith<$Res> {
  __$$TeacherCourseBriefImplCopyWithImpl(
    _$TeacherCourseBriefImpl _value,
    $Res Function(_$TeacherCourseBriefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherCourseBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? title = null, Object? slug = null}) {
    return _then(
      _$TeacherCourseBriefImpl(
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeacherCourseBriefImpl implements _TeacherCourseBrief {
  const _$TeacherCourseBriefImpl({
    required this.id,
    required this.title,
    required this.slug,
  });

  factory _$TeacherCourseBriefImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherCourseBriefImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String slug;

  @override
  String toString() {
    return 'TeacherCourseBrief(id: $id, title: $title, slug: $slug)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherCourseBriefImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.slug, slug) || other.slug == slug));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, slug);

  /// Create a copy of TeacherCourseBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherCourseBriefImplCopyWith<_$TeacherCourseBriefImpl> get copyWith =>
      __$$TeacherCourseBriefImplCopyWithImpl<_$TeacherCourseBriefImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherCourseBriefImplToJson(this);
  }
}

abstract class _TeacherCourseBrief implements TeacherCourseBrief {
  const factory _TeacherCourseBrief({
    required final int id,
    required final String title,
    required final String slug,
  }) = _$TeacherCourseBriefImpl;

  factory _TeacherCourseBrief.fromJson(Map<String, dynamic> json) =
      _$TeacherCourseBriefImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String get slug;

  /// Create a copy of TeacherCourseBrief
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherCourseBriefImplCopyWith<_$TeacherCourseBriefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TeacherStudentBrief _$TeacherStudentBriefFromJson(Map<String, dynamic> json) {
  return _TeacherStudentBrief.fromJson(json);
}

/// @nodoc
mixin _$TeacherStudentBrief {
  int get id => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;

  /// Serializes this TeacherStudentBrief to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherStudentBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherStudentBriefCopyWith<TeacherStudentBrief> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherStudentBriefCopyWith<$Res> {
  factory $TeacherStudentBriefCopyWith(
    TeacherStudentBrief value,
    $Res Function(TeacherStudentBrief) then,
  ) = _$TeacherStudentBriefCopyWithImpl<$Res, TeacherStudentBrief>;
  @useResult
  $Res call({int id, String firstName, String? lastName});
}

/// @nodoc
class _$TeacherStudentBriefCopyWithImpl<$Res, $Val extends TeacherStudentBrief>
    implements $TeacherStudentBriefCopyWith<$Res> {
  _$TeacherStudentBriefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherStudentBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            firstName: null == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String,
            lastName: freezed == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeacherStudentBriefImplCopyWith<$Res>
    implements $TeacherStudentBriefCopyWith<$Res> {
  factory _$$TeacherStudentBriefImplCopyWith(
    _$TeacherStudentBriefImpl value,
    $Res Function(_$TeacherStudentBriefImpl) then,
  ) = __$$TeacherStudentBriefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String firstName, String? lastName});
}

/// @nodoc
class __$$TeacherStudentBriefImplCopyWithImpl<$Res>
    extends _$TeacherStudentBriefCopyWithImpl<$Res, _$TeacherStudentBriefImpl>
    implements _$$TeacherStudentBriefImplCopyWith<$Res> {
  __$$TeacherStudentBriefImplCopyWithImpl(
    _$TeacherStudentBriefImpl _value,
    $Res Function(_$TeacherStudentBriefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherStudentBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = freezed,
  }) {
    return _then(
      _$TeacherStudentBriefImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        firstName: null == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String,
        lastName: freezed == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeacherStudentBriefImpl implements _TeacherStudentBrief {
  const _$TeacherStudentBriefImpl({
    required this.id,
    required this.firstName,
    this.lastName,
  });

  factory _$TeacherStudentBriefImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherStudentBriefImplFromJson(json);

  @override
  final int id;
  @override
  final String firstName;
  @override
  final String? lastName;

  @override
  String toString() {
    return 'TeacherStudentBrief(id: $id, firstName: $firstName, lastName: $lastName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherStudentBriefImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, firstName, lastName);

  /// Create a copy of TeacherStudentBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherStudentBriefImplCopyWith<_$TeacherStudentBriefImpl> get copyWith =>
      __$$TeacherStudentBriefImplCopyWithImpl<_$TeacherStudentBriefImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherStudentBriefImplToJson(this);
  }
}

abstract class _TeacherStudentBrief implements TeacherStudentBrief {
  const factory _TeacherStudentBrief({
    required final int id,
    required final String firstName,
    final String? lastName,
  }) = _$TeacherStudentBriefImpl;

  factory _TeacherStudentBrief.fromJson(Map<String, dynamic> json) =
      _$TeacherStudentBriefImpl.fromJson;

  @override
  int get id;
  @override
  String get firstName;
  @override
  String? get lastName;

  /// Create a copy of TeacherStudentBrief
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherStudentBriefImplCopyWith<_$TeacherStudentBriefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TeacherProgressBrief _$TeacherProgressBriefFromJson(Map<String, dynamic> json) {
  return _TeacherProgressBrief.fromJson(json);
}

/// @nodoc
mixin _$TeacherProgressBrief {
  int get completedLessons => throw _privateConstructorUsedError;
  int get totalLessons => throw _privateConstructorUsedError;
  int get progressPercent => throw _privateConstructorUsedError;

  /// Serializes this TeacherProgressBrief to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherProgressBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherProgressBriefCopyWith<TeacherProgressBrief> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherProgressBriefCopyWith<$Res> {
  factory $TeacherProgressBriefCopyWith(
    TeacherProgressBrief value,
    $Res Function(TeacherProgressBrief) then,
  ) = _$TeacherProgressBriefCopyWithImpl<$Res, TeacherProgressBrief>;
  @useResult
  $Res call({int completedLessons, int totalLessons, int progressPercent});
}

/// @nodoc
class _$TeacherProgressBriefCopyWithImpl<
  $Res,
  $Val extends TeacherProgressBrief
>
    implements $TeacherProgressBriefCopyWith<$Res> {
  _$TeacherProgressBriefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherProgressBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? completedLessons = null,
    Object? totalLessons = null,
    Object? progressPercent = null,
  }) {
    return _then(
      _value.copyWith(
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
abstract class _$$TeacherProgressBriefImplCopyWith<$Res>
    implements $TeacherProgressBriefCopyWith<$Res> {
  factory _$$TeacherProgressBriefImplCopyWith(
    _$TeacherProgressBriefImpl value,
    $Res Function(_$TeacherProgressBriefImpl) then,
  ) = __$$TeacherProgressBriefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int completedLessons, int totalLessons, int progressPercent});
}

/// @nodoc
class __$$TeacherProgressBriefImplCopyWithImpl<$Res>
    extends _$TeacherProgressBriefCopyWithImpl<$Res, _$TeacherProgressBriefImpl>
    implements _$$TeacherProgressBriefImplCopyWith<$Res> {
  __$$TeacherProgressBriefImplCopyWithImpl(
    _$TeacherProgressBriefImpl _value,
    $Res Function(_$TeacherProgressBriefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherProgressBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? completedLessons = null,
    Object? totalLessons = null,
    Object? progressPercent = null,
  }) {
    return _then(
      _$TeacherProgressBriefImpl(
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
class _$TeacherProgressBriefImpl implements _TeacherProgressBrief {
  const _$TeacherProgressBriefImpl({
    required this.completedLessons,
    required this.totalLessons,
    required this.progressPercent,
  });

  factory _$TeacherProgressBriefImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherProgressBriefImplFromJson(json);

  @override
  final int completedLessons;
  @override
  final int totalLessons;
  @override
  final int progressPercent;

  @override
  String toString() {
    return 'TeacherProgressBrief(completedLessons: $completedLessons, totalLessons: $totalLessons, progressPercent: $progressPercent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherProgressBriefImpl &&
            (identical(other.completedLessons, completedLessons) ||
                other.completedLessons == completedLessons) &&
            (identical(other.totalLessons, totalLessons) ||
                other.totalLessons == totalLessons) &&
            (identical(other.progressPercent, progressPercent) ||
                other.progressPercent == progressPercent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, completedLessons, totalLessons, progressPercent);

  /// Create a copy of TeacherProgressBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherProgressBriefImplCopyWith<_$TeacherProgressBriefImpl>
  get copyWith =>
      __$$TeacherProgressBriefImplCopyWithImpl<_$TeacherProgressBriefImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherProgressBriefImplToJson(this);
  }
}

abstract class _TeacherProgressBrief implements TeacherProgressBrief {
  const factory _TeacherProgressBrief({
    required final int completedLessons,
    required final int totalLessons,
    required final int progressPercent,
  }) = _$TeacherProgressBriefImpl;

  factory _TeacherProgressBrief.fromJson(Map<String, dynamic> json) =
      _$TeacherProgressBriefImpl.fromJson;

  @override
  int get completedLessons;
  @override
  int get totalLessons;
  @override
  int get progressPercent;

  /// Create a copy of TeacherProgressBrief
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherProgressBriefImplCopyWith<_$TeacherProgressBriefImpl>
  get copyWith => throw _privateConstructorUsedError;
}

TeacherDashboard _$TeacherDashboardFromJson(Map<String, dynamic> json) {
  return _TeacherDashboard.fromJson(json);
}

/// @nodoc
mixin _$TeacherDashboard {
  int get groupsCount => throw _privateConstructorUsedError;
  int get studentsCount => throw _privateConstructorUsedError;
  int get pendingSubmissions => throw _privateConstructorUsedError;
  int get reviewedSubmissions => throw _privateConstructorUsedError;

  /// Serializes this TeacherDashboard to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherDashboard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherDashboardCopyWith<TeacherDashboard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherDashboardCopyWith<$Res> {
  factory $TeacherDashboardCopyWith(
    TeacherDashboard value,
    $Res Function(TeacherDashboard) then,
  ) = _$TeacherDashboardCopyWithImpl<$Res, TeacherDashboard>;
  @useResult
  $Res call({
    int groupsCount,
    int studentsCount,
    int pendingSubmissions,
    int reviewedSubmissions,
  });
}

/// @nodoc
class _$TeacherDashboardCopyWithImpl<$Res, $Val extends TeacherDashboard>
    implements $TeacherDashboardCopyWith<$Res> {
  _$TeacherDashboardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherDashboard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupsCount = null,
    Object? studentsCount = null,
    Object? pendingSubmissions = null,
    Object? reviewedSubmissions = null,
  }) {
    return _then(
      _value.copyWith(
            groupsCount: null == groupsCount
                ? _value.groupsCount
                : groupsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            studentsCount: null == studentsCount
                ? _value.studentsCount
                : studentsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            pendingSubmissions: null == pendingSubmissions
                ? _value.pendingSubmissions
                : pendingSubmissions // ignore: cast_nullable_to_non_nullable
                      as int,
            reviewedSubmissions: null == reviewedSubmissions
                ? _value.reviewedSubmissions
                : reviewedSubmissions // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeacherDashboardImplCopyWith<$Res>
    implements $TeacherDashboardCopyWith<$Res> {
  factory _$$TeacherDashboardImplCopyWith(
    _$TeacherDashboardImpl value,
    $Res Function(_$TeacherDashboardImpl) then,
  ) = __$$TeacherDashboardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int groupsCount,
    int studentsCount,
    int pendingSubmissions,
    int reviewedSubmissions,
  });
}

/// @nodoc
class __$$TeacherDashboardImplCopyWithImpl<$Res>
    extends _$TeacherDashboardCopyWithImpl<$Res, _$TeacherDashboardImpl>
    implements _$$TeacherDashboardImplCopyWith<$Res> {
  __$$TeacherDashboardImplCopyWithImpl(
    _$TeacherDashboardImpl _value,
    $Res Function(_$TeacherDashboardImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherDashboard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupsCount = null,
    Object? studentsCount = null,
    Object? pendingSubmissions = null,
    Object? reviewedSubmissions = null,
  }) {
    return _then(
      _$TeacherDashboardImpl(
        groupsCount: null == groupsCount
            ? _value.groupsCount
            : groupsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        studentsCount: null == studentsCount
            ? _value.studentsCount
            : studentsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        pendingSubmissions: null == pendingSubmissions
            ? _value.pendingSubmissions
            : pendingSubmissions // ignore: cast_nullable_to_non_nullable
                  as int,
        reviewedSubmissions: null == reviewedSubmissions
            ? _value.reviewedSubmissions
            : reviewedSubmissions // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeacherDashboardImpl implements _TeacherDashboard {
  const _$TeacherDashboardImpl({
    required this.groupsCount,
    required this.studentsCount,
    required this.pendingSubmissions,
    required this.reviewedSubmissions,
  });

  factory _$TeacherDashboardImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherDashboardImplFromJson(json);

  @override
  final int groupsCount;
  @override
  final int studentsCount;
  @override
  final int pendingSubmissions;
  @override
  final int reviewedSubmissions;

  @override
  String toString() {
    return 'TeacherDashboard(groupsCount: $groupsCount, studentsCount: $studentsCount, pendingSubmissions: $pendingSubmissions, reviewedSubmissions: $reviewedSubmissions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherDashboardImpl &&
            (identical(other.groupsCount, groupsCount) ||
                other.groupsCount == groupsCount) &&
            (identical(other.studentsCount, studentsCount) ||
                other.studentsCount == studentsCount) &&
            (identical(other.pendingSubmissions, pendingSubmissions) ||
                other.pendingSubmissions == pendingSubmissions) &&
            (identical(other.reviewedSubmissions, reviewedSubmissions) ||
                other.reviewedSubmissions == reviewedSubmissions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    groupsCount,
    studentsCount,
    pendingSubmissions,
    reviewedSubmissions,
  );

  /// Create a copy of TeacherDashboard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherDashboardImplCopyWith<_$TeacherDashboardImpl> get copyWith =>
      __$$TeacherDashboardImplCopyWithImpl<_$TeacherDashboardImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherDashboardImplToJson(this);
  }
}

abstract class _TeacherDashboard implements TeacherDashboard {
  const factory _TeacherDashboard({
    required final int groupsCount,
    required final int studentsCount,
    required final int pendingSubmissions,
    required final int reviewedSubmissions,
  }) = _$TeacherDashboardImpl;

  factory _TeacherDashboard.fromJson(Map<String, dynamic> json) =
      _$TeacherDashboardImpl.fromJson;

  @override
  int get groupsCount;
  @override
  int get studentsCount;
  @override
  int get pendingSubmissions;
  @override
  int get reviewedSubmissions;

  /// Create a copy of TeacherDashboard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherDashboardImplCopyWith<_$TeacherDashboardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TeacherGroupListItem _$TeacherGroupListItemFromJson(Map<String, dynamic> json) {
  return _TeacherGroupListItem.fromJson(json);
}

/// @nodoc
mixin _$TeacherGroupListItem {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int get studentCount => throw _privateConstructorUsedError;
  int get avgProgressPercent => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  TeacherCourseBrief get course => throw _privateConstructorUsedError;

  /// Serializes this TeacherGroupListItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherGroupListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherGroupListItemCopyWith<TeacherGroupListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherGroupListItemCopyWith<$Res> {
  factory $TeacherGroupListItemCopyWith(
    TeacherGroupListItem value,
    $Res Function(TeacherGroupListItem) then,
  ) = _$TeacherGroupListItemCopyWithImpl<$Res, TeacherGroupListItem>;
  @useResult
  $Res call({
    int id,
    String title,
    String status,
    int studentCount,
    int avgProgressPercent,
    DateTime? startDate,
    TeacherCourseBrief course,
  });

  $TeacherCourseBriefCopyWith<$Res> get course;
}

/// @nodoc
class _$TeacherGroupListItemCopyWithImpl<
  $Res,
  $Val extends TeacherGroupListItem
>
    implements $TeacherGroupListItemCopyWith<$Res> {
  _$TeacherGroupListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherGroupListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? status = null,
    Object? studentCount = null,
    Object? avgProgressPercent = null,
    Object? startDate = freezed,
    Object? course = null,
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
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            studentCount: null == studentCount
                ? _value.studentCount
                : studentCount // ignore: cast_nullable_to_non_nullable
                      as int,
            avgProgressPercent: null == avgProgressPercent
                ? _value.avgProgressPercent
                : avgProgressPercent // ignore: cast_nullable_to_non_nullable
                      as int,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            course: null == course
                ? _value.course
                : course // ignore: cast_nullable_to_non_nullable
                      as TeacherCourseBrief,
          )
          as $Val,
    );
  }

  /// Create a copy of TeacherGroupListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeacherCourseBriefCopyWith<$Res> get course {
    return $TeacherCourseBriefCopyWith<$Res>(_value.course, (value) {
      return _then(_value.copyWith(course: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TeacherGroupListItemImplCopyWith<$Res>
    implements $TeacherGroupListItemCopyWith<$Res> {
  factory _$$TeacherGroupListItemImplCopyWith(
    _$TeacherGroupListItemImpl value,
    $Res Function(_$TeacherGroupListItemImpl) then,
  ) = __$$TeacherGroupListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    String status,
    int studentCount,
    int avgProgressPercent,
    DateTime? startDate,
    TeacherCourseBrief course,
  });

  @override
  $TeacherCourseBriefCopyWith<$Res> get course;
}

/// @nodoc
class __$$TeacherGroupListItemImplCopyWithImpl<$Res>
    extends _$TeacherGroupListItemCopyWithImpl<$Res, _$TeacherGroupListItemImpl>
    implements _$$TeacherGroupListItemImplCopyWith<$Res> {
  __$$TeacherGroupListItemImplCopyWithImpl(
    _$TeacherGroupListItemImpl _value,
    $Res Function(_$TeacherGroupListItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherGroupListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? status = null,
    Object? studentCount = null,
    Object? avgProgressPercent = null,
    Object? startDate = freezed,
    Object? course = null,
  }) {
    return _then(
      _$TeacherGroupListItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        studentCount: null == studentCount
            ? _value.studentCount
            : studentCount // ignore: cast_nullable_to_non_nullable
                  as int,
        avgProgressPercent: null == avgProgressPercent
            ? _value.avgProgressPercent
            : avgProgressPercent // ignore: cast_nullable_to_non_nullable
                  as int,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        course: null == course
            ? _value.course
            : course // ignore: cast_nullable_to_non_nullable
                  as TeacherCourseBrief,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeacherGroupListItemImpl implements _TeacherGroupListItem {
  const _$TeacherGroupListItemImpl({
    required this.id,
    required this.title,
    required this.status,
    required this.studentCount,
    required this.avgProgressPercent,
    this.startDate,
    required this.course,
  });

  factory _$TeacherGroupListItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherGroupListItemImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String status;
  @override
  final int studentCount;
  @override
  final int avgProgressPercent;
  @override
  final DateTime? startDate;
  @override
  final TeacherCourseBrief course;

  @override
  String toString() {
    return 'TeacherGroupListItem(id: $id, title: $title, status: $status, studentCount: $studentCount, avgProgressPercent: $avgProgressPercent, startDate: $startDate, course: $course)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherGroupListItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.studentCount, studentCount) ||
                other.studentCount == studentCount) &&
            (identical(other.avgProgressPercent, avgProgressPercent) ||
                other.avgProgressPercent == avgProgressPercent) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.course, course) || other.course == course));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    status,
    studentCount,
    avgProgressPercent,
    startDate,
    course,
  );

  /// Create a copy of TeacherGroupListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherGroupListItemImplCopyWith<_$TeacherGroupListItemImpl>
  get copyWith =>
      __$$TeacherGroupListItemImplCopyWithImpl<_$TeacherGroupListItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherGroupListItemImplToJson(this);
  }
}

abstract class _TeacherGroupListItem implements TeacherGroupListItem {
  const factory _TeacherGroupListItem({
    required final int id,
    required final String title,
    required final String status,
    required final int studentCount,
    required final int avgProgressPercent,
    final DateTime? startDate,
    required final TeacherCourseBrief course,
  }) = _$TeacherGroupListItemImpl;

  factory _TeacherGroupListItem.fromJson(Map<String, dynamic> json) =
      _$TeacherGroupListItemImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String get status;
  @override
  int get studentCount;
  @override
  int get avgProgressPercent;
  @override
  DateTime? get startDate;
  @override
  TeacherCourseBrief get course;

  /// Create a copy of TeacherGroupListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherGroupListItemImplCopyWith<_$TeacherGroupListItemImpl>
  get copyWith => throw _privateConstructorUsedError;
}

TeacherGroupDetail _$TeacherGroupDetailFromJson(Map<String, dynamic> json) {
  return _TeacherGroupDetail.fromJson(json);
}

/// @nodoc
mixin _$TeacherGroupDetail {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int get studentCount => throw _privateConstructorUsedError;
  int get avgProgressPercent => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  TeacherCourseBrief get course => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  int? get maxStudents => throw _privateConstructorUsedError;

  /// Serializes this TeacherGroupDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherGroupDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherGroupDetailCopyWith<TeacherGroupDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherGroupDetailCopyWith<$Res> {
  factory $TeacherGroupDetailCopyWith(
    TeacherGroupDetail value,
    $Res Function(TeacherGroupDetail) then,
  ) = _$TeacherGroupDetailCopyWithImpl<$Res, TeacherGroupDetail>;
  @useResult
  $Res call({
    int id,
    String title,
    String status,
    int studentCount,
    int avgProgressPercent,
    DateTime? startDate,
    TeacherCourseBrief course,
    String? description,
    DateTime? endDate,
    int? maxStudents,
  });

  $TeacherCourseBriefCopyWith<$Res> get course;
}

/// @nodoc
class _$TeacherGroupDetailCopyWithImpl<$Res, $Val extends TeacherGroupDetail>
    implements $TeacherGroupDetailCopyWith<$Res> {
  _$TeacherGroupDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherGroupDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? status = null,
    Object? studentCount = null,
    Object? avgProgressPercent = null,
    Object? startDate = freezed,
    Object? course = null,
    Object? description = freezed,
    Object? endDate = freezed,
    Object? maxStudents = freezed,
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
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            studentCount: null == studentCount
                ? _value.studentCount
                : studentCount // ignore: cast_nullable_to_non_nullable
                      as int,
            avgProgressPercent: null == avgProgressPercent
                ? _value.avgProgressPercent
                : avgProgressPercent // ignore: cast_nullable_to_non_nullable
                      as int,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            course: null == course
                ? _value.course
                : course // ignore: cast_nullable_to_non_nullable
                      as TeacherCourseBrief,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            maxStudents: freezed == maxStudents
                ? _value.maxStudents
                : maxStudents // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }

  /// Create a copy of TeacherGroupDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeacherCourseBriefCopyWith<$Res> get course {
    return $TeacherCourseBriefCopyWith<$Res>(_value.course, (value) {
      return _then(_value.copyWith(course: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TeacherGroupDetailImplCopyWith<$Res>
    implements $TeacherGroupDetailCopyWith<$Res> {
  factory _$$TeacherGroupDetailImplCopyWith(
    _$TeacherGroupDetailImpl value,
    $Res Function(_$TeacherGroupDetailImpl) then,
  ) = __$$TeacherGroupDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    String status,
    int studentCount,
    int avgProgressPercent,
    DateTime? startDate,
    TeacherCourseBrief course,
    String? description,
    DateTime? endDate,
    int? maxStudents,
  });

  @override
  $TeacherCourseBriefCopyWith<$Res> get course;
}

/// @nodoc
class __$$TeacherGroupDetailImplCopyWithImpl<$Res>
    extends _$TeacherGroupDetailCopyWithImpl<$Res, _$TeacherGroupDetailImpl>
    implements _$$TeacherGroupDetailImplCopyWith<$Res> {
  __$$TeacherGroupDetailImplCopyWithImpl(
    _$TeacherGroupDetailImpl _value,
    $Res Function(_$TeacherGroupDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherGroupDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? status = null,
    Object? studentCount = null,
    Object? avgProgressPercent = null,
    Object? startDate = freezed,
    Object? course = null,
    Object? description = freezed,
    Object? endDate = freezed,
    Object? maxStudents = freezed,
  }) {
    return _then(
      _$TeacherGroupDetailImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        studentCount: null == studentCount
            ? _value.studentCount
            : studentCount // ignore: cast_nullable_to_non_nullable
                  as int,
        avgProgressPercent: null == avgProgressPercent
            ? _value.avgProgressPercent
            : avgProgressPercent // ignore: cast_nullable_to_non_nullable
                  as int,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        course: null == course
            ? _value.course
            : course // ignore: cast_nullable_to_non_nullable
                  as TeacherCourseBrief,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        maxStudents: freezed == maxStudents
            ? _value.maxStudents
            : maxStudents // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeacherGroupDetailImpl implements _TeacherGroupDetail {
  const _$TeacherGroupDetailImpl({
    required this.id,
    required this.title,
    required this.status,
    required this.studentCount,
    required this.avgProgressPercent,
    this.startDate,
    required this.course,
    this.description,
    this.endDate,
    this.maxStudents,
  });

  factory _$TeacherGroupDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherGroupDetailImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String status;
  @override
  final int studentCount;
  @override
  final int avgProgressPercent;
  @override
  final DateTime? startDate;
  @override
  final TeacherCourseBrief course;
  @override
  final String? description;
  @override
  final DateTime? endDate;
  @override
  final int? maxStudents;

  @override
  String toString() {
    return 'TeacherGroupDetail(id: $id, title: $title, status: $status, studentCount: $studentCount, avgProgressPercent: $avgProgressPercent, startDate: $startDate, course: $course, description: $description, endDate: $endDate, maxStudents: $maxStudents)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherGroupDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.studentCount, studentCount) ||
                other.studentCount == studentCount) &&
            (identical(other.avgProgressPercent, avgProgressPercent) ||
                other.avgProgressPercent == avgProgressPercent) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.course, course) || other.course == course) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.maxStudents, maxStudents) ||
                other.maxStudents == maxStudents));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    status,
    studentCount,
    avgProgressPercent,
    startDate,
    course,
    description,
    endDate,
    maxStudents,
  );

  /// Create a copy of TeacherGroupDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherGroupDetailImplCopyWith<_$TeacherGroupDetailImpl> get copyWith =>
      __$$TeacherGroupDetailImplCopyWithImpl<_$TeacherGroupDetailImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherGroupDetailImplToJson(this);
  }
}

abstract class _TeacherGroupDetail implements TeacherGroupDetail {
  const factory _TeacherGroupDetail({
    required final int id,
    required final String title,
    required final String status,
    required final int studentCount,
    required final int avgProgressPercent,
    final DateTime? startDate,
    required final TeacherCourseBrief course,
    final String? description,
    final DateTime? endDate,
    final int? maxStudents,
  }) = _$TeacherGroupDetailImpl;

  factory _TeacherGroupDetail.fromJson(Map<String, dynamic> json) =
      _$TeacherGroupDetailImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String get status;
  @override
  int get studentCount;
  @override
  int get avgProgressPercent;
  @override
  DateTime? get startDate;
  @override
  TeacherCourseBrief get course;
  @override
  String? get description;
  @override
  DateTime? get endDate;
  @override
  int? get maxStudents;

  /// Create a copy of TeacherGroupDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherGroupDetailImplCopyWith<_$TeacherGroupDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TeacherGroupStudentItem _$TeacherGroupStudentItemFromJson(
  Map<String, dynamic> json,
) {
  return _TeacherGroupStudentItem.fromJson(json);
}

/// @nodoc
mixin _$TeacherGroupStudentItem {
  TeacherStudentBrief get student => throw _privateConstructorUsedError;
  TeacherProgressBrief get progress => throw _privateConstructorUsedError;
  int get pendingSubmissions => throw _privateConstructorUsedError;
  DateTime get joinedAt => throw _privateConstructorUsedError;

  /// Serializes this TeacherGroupStudentItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherGroupStudentItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherGroupStudentItemCopyWith<TeacherGroupStudentItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherGroupStudentItemCopyWith<$Res> {
  factory $TeacherGroupStudentItemCopyWith(
    TeacherGroupStudentItem value,
    $Res Function(TeacherGroupStudentItem) then,
  ) = _$TeacherGroupStudentItemCopyWithImpl<$Res, TeacherGroupStudentItem>;
  @useResult
  $Res call({
    TeacherStudentBrief student,
    TeacherProgressBrief progress,
    int pendingSubmissions,
    DateTime joinedAt,
  });

  $TeacherStudentBriefCopyWith<$Res> get student;
  $TeacherProgressBriefCopyWith<$Res> get progress;
}

/// @nodoc
class _$TeacherGroupStudentItemCopyWithImpl<
  $Res,
  $Val extends TeacherGroupStudentItem
>
    implements $TeacherGroupStudentItemCopyWith<$Res> {
  _$TeacherGroupStudentItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherGroupStudentItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? student = null,
    Object? progress = null,
    Object? pendingSubmissions = null,
    Object? joinedAt = null,
  }) {
    return _then(
      _value.copyWith(
            student: null == student
                ? _value.student
                : student // ignore: cast_nullable_to_non_nullable
                      as TeacherStudentBrief,
            progress: null == progress
                ? _value.progress
                : progress // ignore: cast_nullable_to_non_nullable
                      as TeacherProgressBrief,
            pendingSubmissions: null == pendingSubmissions
                ? _value.pendingSubmissions
                : pendingSubmissions // ignore: cast_nullable_to_non_nullable
                      as int,
            joinedAt: null == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }

  /// Create a copy of TeacherGroupStudentItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeacherStudentBriefCopyWith<$Res> get student {
    return $TeacherStudentBriefCopyWith<$Res>(_value.student, (value) {
      return _then(_value.copyWith(student: value) as $Val);
    });
  }

  /// Create a copy of TeacherGroupStudentItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeacherProgressBriefCopyWith<$Res> get progress {
    return $TeacherProgressBriefCopyWith<$Res>(_value.progress, (value) {
      return _then(_value.copyWith(progress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TeacherGroupStudentItemImplCopyWith<$Res>
    implements $TeacherGroupStudentItemCopyWith<$Res> {
  factory _$$TeacherGroupStudentItemImplCopyWith(
    _$TeacherGroupStudentItemImpl value,
    $Res Function(_$TeacherGroupStudentItemImpl) then,
  ) = __$$TeacherGroupStudentItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    TeacherStudentBrief student,
    TeacherProgressBrief progress,
    int pendingSubmissions,
    DateTime joinedAt,
  });

  @override
  $TeacherStudentBriefCopyWith<$Res> get student;
  @override
  $TeacherProgressBriefCopyWith<$Res> get progress;
}

/// @nodoc
class __$$TeacherGroupStudentItemImplCopyWithImpl<$Res>
    extends
        _$TeacherGroupStudentItemCopyWithImpl<
          $Res,
          _$TeacherGroupStudentItemImpl
        >
    implements _$$TeacherGroupStudentItemImplCopyWith<$Res> {
  __$$TeacherGroupStudentItemImplCopyWithImpl(
    _$TeacherGroupStudentItemImpl _value,
    $Res Function(_$TeacherGroupStudentItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherGroupStudentItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? student = null,
    Object? progress = null,
    Object? pendingSubmissions = null,
    Object? joinedAt = null,
  }) {
    return _then(
      _$TeacherGroupStudentItemImpl(
        student: null == student
            ? _value.student
            : student // ignore: cast_nullable_to_non_nullable
                  as TeacherStudentBrief,
        progress: null == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as TeacherProgressBrief,
        pendingSubmissions: null == pendingSubmissions
            ? _value.pendingSubmissions
            : pendingSubmissions // ignore: cast_nullable_to_non_nullable
                  as int,
        joinedAt: null == joinedAt
            ? _value.joinedAt
            : joinedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeacherGroupStudentItemImpl implements _TeacherGroupStudentItem {
  const _$TeacherGroupStudentItemImpl({
    required this.student,
    required this.progress,
    required this.pendingSubmissions,
    required this.joinedAt,
  });

  factory _$TeacherGroupStudentItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherGroupStudentItemImplFromJson(json);

  @override
  final TeacherStudentBrief student;
  @override
  final TeacherProgressBrief progress;
  @override
  final int pendingSubmissions;
  @override
  final DateTime joinedAt;

  @override
  String toString() {
    return 'TeacherGroupStudentItem(student: $student, progress: $progress, pendingSubmissions: $pendingSubmissions, joinedAt: $joinedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherGroupStudentItemImpl &&
            (identical(other.student, student) || other.student == student) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.pendingSubmissions, pendingSubmissions) ||
                other.pendingSubmissions == pendingSubmissions) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, student, progress, pendingSubmissions, joinedAt);

  /// Create a copy of TeacherGroupStudentItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherGroupStudentItemImplCopyWith<_$TeacherGroupStudentItemImpl>
  get copyWith =>
      __$$TeacherGroupStudentItemImplCopyWithImpl<
        _$TeacherGroupStudentItemImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherGroupStudentItemImplToJson(this);
  }
}

abstract class _TeacherGroupStudentItem implements TeacherGroupStudentItem {
  const factory _TeacherGroupStudentItem({
    required final TeacherStudentBrief student,
    required final TeacherProgressBrief progress,
    required final int pendingSubmissions,
    required final DateTime joinedAt,
  }) = _$TeacherGroupStudentItemImpl;

  factory _TeacherGroupStudentItem.fromJson(Map<String, dynamic> json) =
      _$TeacherGroupStudentItemImpl.fromJson;

  @override
  TeacherStudentBrief get student;
  @override
  TeacherProgressBrief get progress;
  @override
  int get pendingSubmissions;
  @override
  DateTime get joinedAt;

  /// Create a copy of TeacherGroupStudentItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherGroupStudentItemImplCopyWith<_$TeacherGroupStudentItemImpl>
  get copyWith => throw _privateConstructorUsedError;
}

TeacherLessonProgressItem _$TeacherLessonProgressItemFromJson(
  Map<String, dynamic> json,
) {
  return _TeacherLessonProgressItem.fromJson(json);
}

/// @nodoc
mixin _$TeacherLessonProgressItem {
  int get lessonId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this TeacherLessonProgressItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherLessonProgressItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherLessonProgressItemCopyWith<TeacherLessonProgressItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherLessonProgressItemCopyWith<$Res> {
  factory $TeacherLessonProgressItemCopyWith(
    TeacherLessonProgressItem value,
    $Res Function(TeacherLessonProgressItem) then,
  ) = _$TeacherLessonProgressItemCopyWithImpl<$Res, TeacherLessonProgressItem>;
  @useResult
  $Res call({int lessonId, String title, String status, DateTime? completedAt});
}

/// @nodoc
class _$TeacherLessonProgressItemCopyWithImpl<
  $Res,
  $Val extends TeacherLessonProgressItem
>
    implements $TeacherLessonProgressItemCopyWith<$Res> {
  _$TeacherLessonProgressItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherLessonProgressItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lessonId = null,
    Object? title = null,
    Object? status = null,
    Object? completedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            lessonId: null == lessonId
                ? _value.lessonId
                : lessonId // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$TeacherLessonProgressItemImplCopyWith<$Res>
    implements $TeacherLessonProgressItemCopyWith<$Res> {
  factory _$$TeacherLessonProgressItemImplCopyWith(
    _$TeacherLessonProgressItemImpl value,
    $Res Function(_$TeacherLessonProgressItemImpl) then,
  ) = __$$TeacherLessonProgressItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int lessonId, String title, String status, DateTime? completedAt});
}

/// @nodoc
class __$$TeacherLessonProgressItemImplCopyWithImpl<$Res>
    extends
        _$TeacherLessonProgressItemCopyWithImpl<
          $Res,
          _$TeacherLessonProgressItemImpl
        >
    implements _$$TeacherLessonProgressItemImplCopyWith<$Res> {
  __$$TeacherLessonProgressItemImplCopyWithImpl(
    _$TeacherLessonProgressItemImpl _value,
    $Res Function(_$TeacherLessonProgressItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherLessonProgressItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lessonId = null,
    Object? title = null,
    Object? status = null,
    Object? completedAt = freezed,
  }) {
    return _then(
      _$TeacherLessonProgressItemImpl(
        lessonId: null == lessonId
            ? _value.lessonId
            : lessonId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$TeacherLessonProgressItemImpl implements _TeacherLessonProgressItem {
  const _$TeacherLessonProgressItemImpl({
    required this.lessonId,
    required this.title,
    required this.status,
    this.completedAt,
  });

  factory _$TeacherLessonProgressItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherLessonProgressItemImplFromJson(json);

  @override
  final int lessonId;
  @override
  final String title;
  @override
  final String status;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'TeacherLessonProgressItem(lessonId: $lessonId, title: $title, status: $status, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherLessonProgressItemImpl &&
            (identical(other.lessonId, lessonId) ||
                other.lessonId == lessonId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, lessonId, title, status, completedAt);

  /// Create a copy of TeacherLessonProgressItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherLessonProgressItemImplCopyWith<_$TeacherLessonProgressItemImpl>
  get copyWith =>
      __$$TeacherLessonProgressItemImplCopyWithImpl<
        _$TeacherLessonProgressItemImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherLessonProgressItemImplToJson(this);
  }
}

abstract class _TeacherLessonProgressItem implements TeacherLessonProgressItem {
  const factory _TeacherLessonProgressItem({
    required final int lessonId,
    required final String title,
    required final String status,
    final DateTime? completedAt,
  }) = _$TeacherLessonProgressItemImpl;

  factory _TeacherLessonProgressItem.fromJson(Map<String, dynamic> json) =
      _$TeacherLessonProgressItemImpl.fromJson;

  @override
  int get lessonId;
  @override
  String get title;
  @override
  String get status;
  @override
  DateTime? get completedAt;

  /// Create a copy of TeacherLessonProgressItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherLessonProgressItemImplCopyWith<_$TeacherLessonProgressItemImpl>
  get copyWith => throw _privateConstructorUsedError;
}

TeacherSubmissionSummaryItem _$TeacherSubmissionSummaryItemFromJson(
  Map<String, dynamic> json,
) {
  return _TeacherSubmissionSummaryItem.fromJson(json);
}

/// @nodoc
mixin _$TeacherSubmissionSummaryItem {
  int? get submissionId => throw _privateConstructorUsedError;
  int get assignmentId => throw _privateConstructorUsedError;
  String get assignmentTitle => throw _privateConstructorUsedError;
  String get lessonTitle => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int? get score => throw _privateConstructorUsedError;
  DateTime? get submittedAt => throw _privateConstructorUsedError;

  /// Serializes this TeacherSubmissionSummaryItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherSubmissionSummaryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherSubmissionSummaryItemCopyWith<TeacherSubmissionSummaryItem>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherSubmissionSummaryItemCopyWith<$Res> {
  factory $TeacherSubmissionSummaryItemCopyWith(
    TeacherSubmissionSummaryItem value,
    $Res Function(TeacherSubmissionSummaryItem) then,
  ) =
      _$TeacherSubmissionSummaryItemCopyWithImpl<
        $Res,
        TeacherSubmissionSummaryItem
      >;
  @useResult
  $Res call({
    int? submissionId,
    int assignmentId,
    String assignmentTitle,
    String lessonTitle,
    int points,
    String status,
    int? score,
    DateTime? submittedAt,
  });
}

/// @nodoc
class _$TeacherSubmissionSummaryItemCopyWithImpl<
  $Res,
  $Val extends TeacherSubmissionSummaryItem
>
    implements $TeacherSubmissionSummaryItemCopyWith<$Res> {
  _$TeacherSubmissionSummaryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherSubmissionSummaryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? submissionId = freezed,
    Object? assignmentId = null,
    Object? assignmentTitle = null,
    Object? lessonTitle = null,
    Object? points = null,
    Object? status = null,
    Object? score = freezed,
    Object? submittedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            submissionId: freezed == submissionId
                ? _value.submissionId
                : submissionId // ignore: cast_nullable_to_non_nullable
                      as int?,
            assignmentId: null == assignmentId
                ? _value.assignmentId
                : assignmentId // ignore: cast_nullable_to_non_nullable
                      as int,
            assignmentTitle: null == assignmentTitle
                ? _value.assignmentTitle
                : assignmentTitle // ignore: cast_nullable_to_non_nullable
                      as String,
            lessonTitle: null == lessonTitle
                ? _value.lessonTitle
                : lessonTitle // ignore: cast_nullable_to_non_nullable
                      as String,
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            score: freezed == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int?,
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
abstract class _$$TeacherSubmissionSummaryItemImplCopyWith<$Res>
    implements $TeacherSubmissionSummaryItemCopyWith<$Res> {
  factory _$$TeacherSubmissionSummaryItemImplCopyWith(
    _$TeacherSubmissionSummaryItemImpl value,
    $Res Function(_$TeacherSubmissionSummaryItemImpl) then,
  ) = __$$TeacherSubmissionSummaryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? submissionId,
    int assignmentId,
    String assignmentTitle,
    String lessonTitle,
    int points,
    String status,
    int? score,
    DateTime? submittedAt,
  });
}

/// @nodoc
class __$$TeacherSubmissionSummaryItemImplCopyWithImpl<$Res>
    extends
        _$TeacherSubmissionSummaryItemCopyWithImpl<
          $Res,
          _$TeacherSubmissionSummaryItemImpl
        >
    implements _$$TeacherSubmissionSummaryItemImplCopyWith<$Res> {
  __$$TeacherSubmissionSummaryItemImplCopyWithImpl(
    _$TeacherSubmissionSummaryItemImpl _value,
    $Res Function(_$TeacherSubmissionSummaryItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherSubmissionSummaryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? submissionId = freezed,
    Object? assignmentId = null,
    Object? assignmentTitle = null,
    Object? lessonTitle = null,
    Object? points = null,
    Object? status = null,
    Object? score = freezed,
    Object? submittedAt = freezed,
  }) {
    return _then(
      _$TeacherSubmissionSummaryItemImpl(
        submissionId: freezed == submissionId
            ? _value.submissionId
            : submissionId // ignore: cast_nullable_to_non_nullable
                  as int?,
        assignmentId: null == assignmentId
            ? _value.assignmentId
            : assignmentId // ignore: cast_nullable_to_non_nullable
                  as int,
        assignmentTitle: null == assignmentTitle
            ? _value.assignmentTitle
            : assignmentTitle // ignore: cast_nullable_to_non_nullable
                  as String,
        lessonTitle: null == lessonTitle
            ? _value.lessonTitle
            : lessonTitle // ignore: cast_nullable_to_non_nullable
                  as String,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        score: freezed == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int?,
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
class _$TeacherSubmissionSummaryItemImpl
    implements _TeacherSubmissionSummaryItem {
  const _$TeacherSubmissionSummaryItemImpl({
    this.submissionId,
    required this.assignmentId,
    required this.assignmentTitle,
    required this.lessonTitle,
    required this.points,
    required this.status,
    this.score,
    this.submittedAt,
  });

  factory _$TeacherSubmissionSummaryItemImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$TeacherSubmissionSummaryItemImplFromJson(json);

  @override
  final int? submissionId;
  @override
  final int assignmentId;
  @override
  final String assignmentTitle;
  @override
  final String lessonTitle;
  @override
  final int points;
  @override
  final String status;
  @override
  final int? score;
  @override
  final DateTime? submittedAt;

  @override
  String toString() {
    return 'TeacherSubmissionSummaryItem(submissionId: $submissionId, assignmentId: $assignmentId, assignmentTitle: $assignmentTitle, lessonTitle: $lessonTitle, points: $points, status: $status, score: $score, submittedAt: $submittedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherSubmissionSummaryItemImpl &&
            (identical(other.submissionId, submissionId) ||
                other.submissionId == submissionId) &&
            (identical(other.assignmentId, assignmentId) ||
                other.assignmentId == assignmentId) &&
            (identical(other.assignmentTitle, assignmentTitle) ||
                other.assignmentTitle == assignmentTitle) &&
            (identical(other.lessonTitle, lessonTitle) ||
                other.lessonTitle == lessonTitle) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    submissionId,
    assignmentId,
    assignmentTitle,
    lessonTitle,
    points,
    status,
    score,
    submittedAt,
  );

  /// Create a copy of TeacherSubmissionSummaryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherSubmissionSummaryItemImplCopyWith<
    _$TeacherSubmissionSummaryItemImpl
  >
  get copyWith =>
      __$$TeacherSubmissionSummaryItemImplCopyWithImpl<
        _$TeacherSubmissionSummaryItemImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherSubmissionSummaryItemImplToJson(this);
  }
}

abstract class _TeacherSubmissionSummaryItem
    implements TeacherSubmissionSummaryItem {
  const factory _TeacherSubmissionSummaryItem({
    final int? submissionId,
    required final int assignmentId,
    required final String assignmentTitle,
    required final String lessonTitle,
    required final int points,
    required final String status,
    final int? score,
    final DateTime? submittedAt,
  }) = _$TeacherSubmissionSummaryItemImpl;

  factory _TeacherSubmissionSummaryItem.fromJson(Map<String, dynamic> json) =
      _$TeacherSubmissionSummaryItemImpl.fromJson;

  @override
  int? get submissionId;
  @override
  int get assignmentId;
  @override
  String get assignmentTitle;
  @override
  String get lessonTitle;
  @override
  int get points;
  @override
  String get status;
  @override
  int? get score;
  @override
  DateTime? get submittedAt;

  /// Create a copy of TeacherSubmissionSummaryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherSubmissionSummaryItemImplCopyWith<
    _$TeacherSubmissionSummaryItemImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

TeacherQuizResultItem _$TeacherQuizResultItemFromJson(
  Map<String, dynamic> json,
) {
  return _TeacherQuizResultItem.fromJson(json);
}

/// @nodoc
mixin _$TeacherQuizResultItem {
  int get assignmentId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get lessonTitle => throw _privateConstructorUsedError;
  int get attempts => throw _privateConstructorUsedError;
  int? get bestPercent => throw _privateConstructorUsedError;
  bool get passed => throw _privateConstructorUsedError;

  /// Serializes this TeacherQuizResultItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherQuizResultItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherQuizResultItemCopyWith<TeacherQuizResultItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherQuizResultItemCopyWith<$Res> {
  factory $TeacherQuizResultItemCopyWith(
    TeacherQuizResultItem value,
    $Res Function(TeacherQuizResultItem) then,
  ) = _$TeacherQuizResultItemCopyWithImpl<$Res, TeacherQuizResultItem>;
  @useResult
  $Res call({
    int assignmentId,
    String title,
    String lessonTitle,
    int attempts,
    int? bestPercent,
    bool passed,
  });
}

/// @nodoc
class _$TeacherQuizResultItemCopyWithImpl<
  $Res,
  $Val extends TeacherQuizResultItem
>
    implements $TeacherQuizResultItemCopyWith<$Res> {
  _$TeacherQuizResultItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherQuizResultItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assignmentId = null,
    Object? title = null,
    Object? lessonTitle = null,
    Object? attempts = null,
    Object? bestPercent = freezed,
    Object? passed = null,
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
            lessonTitle: null == lessonTitle
                ? _value.lessonTitle
                : lessonTitle // ignore: cast_nullable_to_non_nullable
                      as String,
            attempts: null == attempts
                ? _value.attempts
                : attempts // ignore: cast_nullable_to_non_nullable
                      as int,
            bestPercent: freezed == bestPercent
                ? _value.bestPercent
                : bestPercent // ignore: cast_nullable_to_non_nullable
                      as int?,
            passed: null == passed
                ? _value.passed
                : passed // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeacherQuizResultItemImplCopyWith<$Res>
    implements $TeacherQuizResultItemCopyWith<$Res> {
  factory _$$TeacherQuizResultItemImplCopyWith(
    _$TeacherQuizResultItemImpl value,
    $Res Function(_$TeacherQuizResultItemImpl) then,
  ) = __$$TeacherQuizResultItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int assignmentId,
    String title,
    String lessonTitle,
    int attempts,
    int? bestPercent,
    bool passed,
  });
}

/// @nodoc
class __$$TeacherQuizResultItemImplCopyWithImpl<$Res>
    extends
        _$TeacherQuizResultItemCopyWithImpl<$Res, _$TeacherQuizResultItemImpl>
    implements _$$TeacherQuizResultItemImplCopyWith<$Res> {
  __$$TeacherQuizResultItemImplCopyWithImpl(
    _$TeacherQuizResultItemImpl _value,
    $Res Function(_$TeacherQuizResultItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherQuizResultItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assignmentId = null,
    Object? title = null,
    Object? lessonTitle = null,
    Object? attempts = null,
    Object? bestPercent = freezed,
    Object? passed = null,
  }) {
    return _then(
      _$TeacherQuizResultItemImpl(
        assignmentId: null == assignmentId
            ? _value.assignmentId
            : assignmentId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        lessonTitle: null == lessonTitle
            ? _value.lessonTitle
            : lessonTitle // ignore: cast_nullable_to_non_nullable
                  as String,
        attempts: null == attempts
            ? _value.attempts
            : attempts // ignore: cast_nullable_to_non_nullable
                  as int,
        bestPercent: freezed == bestPercent
            ? _value.bestPercent
            : bestPercent // ignore: cast_nullable_to_non_nullable
                  as int?,
        passed: null == passed
            ? _value.passed
            : passed // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeacherQuizResultItemImpl implements _TeacherQuizResultItem {
  const _$TeacherQuizResultItemImpl({
    required this.assignmentId,
    required this.title,
    required this.lessonTitle,
    required this.attempts,
    this.bestPercent,
    required this.passed,
  });

  factory _$TeacherQuizResultItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherQuizResultItemImplFromJson(json);

  @override
  final int assignmentId;
  @override
  final String title;
  @override
  final String lessonTitle;
  @override
  final int attempts;
  @override
  final int? bestPercent;
  @override
  final bool passed;

  @override
  String toString() {
    return 'TeacherQuizResultItem(assignmentId: $assignmentId, title: $title, lessonTitle: $lessonTitle, attempts: $attempts, bestPercent: $bestPercent, passed: $passed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherQuizResultItemImpl &&
            (identical(other.assignmentId, assignmentId) ||
                other.assignmentId == assignmentId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.lessonTitle, lessonTitle) ||
                other.lessonTitle == lessonTitle) &&
            (identical(other.attempts, attempts) ||
                other.attempts == attempts) &&
            (identical(other.bestPercent, bestPercent) ||
                other.bestPercent == bestPercent) &&
            (identical(other.passed, passed) || other.passed == passed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    assignmentId,
    title,
    lessonTitle,
    attempts,
    bestPercent,
    passed,
  );

  /// Create a copy of TeacherQuizResultItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherQuizResultItemImplCopyWith<_$TeacherQuizResultItemImpl>
  get copyWith =>
      __$$TeacherQuizResultItemImplCopyWithImpl<_$TeacherQuizResultItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherQuizResultItemImplToJson(this);
  }
}

abstract class _TeacherQuizResultItem implements TeacherQuizResultItem {
  const factory _TeacherQuizResultItem({
    required final int assignmentId,
    required final String title,
    required final String lessonTitle,
    required final int attempts,
    final int? bestPercent,
    required final bool passed,
  }) = _$TeacherQuizResultItemImpl;

  factory _TeacherQuizResultItem.fromJson(Map<String, dynamic> json) =
      _$TeacherQuizResultItemImpl.fromJson;

  @override
  int get assignmentId;
  @override
  String get title;
  @override
  String get lessonTitle;
  @override
  int get attempts;
  @override
  int? get bestPercent;
  @override
  bool get passed;

  /// Create a copy of TeacherQuizResultItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherQuizResultItemImplCopyWith<_$TeacherQuizResultItemImpl>
  get copyWith => throw _privateConstructorUsedError;
}

TeacherStudentDetail _$TeacherStudentDetailFromJson(Map<String, dynamic> json) {
  return _TeacherStudentDetail.fromJson(json);
}

/// @nodoc
mixin _$TeacherStudentDetail {
  TeacherStudentBrief get student => throw _privateConstructorUsedError;
  TeacherCourseBrief get course => throw _privateConstructorUsedError;
  TeacherProgressBrief get progress => throw _privateConstructorUsedError;
  List<TeacherLessonProgressItem> get lessons =>
      throw _privateConstructorUsedError;
  List<TeacherSubmissionSummaryItem> get submissions =>
      throw _privateConstructorUsedError;
  List<TeacherQuizResultItem> get quizResults =>
      throw _privateConstructorUsedError;

  /// Serializes this TeacherStudentDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherStudentDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherStudentDetailCopyWith<TeacherStudentDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherStudentDetailCopyWith<$Res> {
  factory $TeacherStudentDetailCopyWith(
    TeacherStudentDetail value,
    $Res Function(TeacherStudentDetail) then,
  ) = _$TeacherStudentDetailCopyWithImpl<$Res, TeacherStudentDetail>;
  @useResult
  $Res call({
    TeacherStudentBrief student,
    TeacherCourseBrief course,
    TeacherProgressBrief progress,
    List<TeacherLessonProgressItem> lessons,
    List<TeacherSubmissionSummaryItem> submissions,
    List<TeacherQuizResultItem> quizResults,
  });

  $TeacherStudentBriefCopyWith<$Res> get student;
  $TeacherCourseBriefCopyWith<$Res> get course;
  $TeacherProgressBriefCopyWith<$Res> get progress;
}

/// @nodoc
class _$TeacherStudentDetailCopyWithImpl<
  $Res,
  $Val extends TeacherStudentDetail
>
    implements $TeacherStudentDetailCopyWith<$Res> {
  _$TeacherStudentDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherStudentDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? student = null,
    Object? course = null,
    Object? progress = null,
    Object? lessons = null,
    Object? submissions = null,
    Object? quizResults = null,
  }) {
    return _then(
      _value.copyWith(
            student: null == student
                ? _value.student
                : student // ignore: cast_nullable_to_non_nullable
                      as TeacherStudentBrief,
            course: null == course
                ? _value.course
                : course // ignore: cast_nullable_to_non_nullable
                      as TeacherCourseBrief,
            progress: null == progress
                ? _value.progress
                : progress // ignore: cast_nullable_to_non_nullable
                      as TeacherProgressBrief,
            lessons: null == lessons
                ? _value.lessons
                : lessons // ignore: cast_nullable_to_non_nullable
                      as List<TeacherLessonProgressItem>,
            submissions: null == submissions
                ? _value.submissions
                : submissions // ignore: cast_nullable_to_non_nullable
                      as List<TeacherSubmissionSummaryItem>,
            quizResults: null == quizResults
                ? _value.quizResults
                : quizResults // ignore: cast_nullable_to_non_nullable
                      as List<TeacherQuizResultItem>,
          )
          as $Val,
    );
  }

  /// Create a copy of TeacherStudentDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeacherStudentBriefCopyWith<$Res> get student {
    return $TeacherStudentBriefCopyWith<$Res>(_value.student, (value) {
      return _then(_value.copyWith(student: value) as $Val);
    });
  }

  /// Create a copy of TeacherStudentDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeacherCourseBriefCopyWith<$Res> get course {
    return $TeacherCourseBriefCopyWith<$Res>(_value.course, (value) {
      return _then(_value.copyWith(course: value) as $Val);
    });
  }

  /// Create a copy of TeacherStudentDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeacherProgressBriefCopyWith<$Res> get progress {
    return $TeacherProgressBriefCopyWith<$Res>(_value.progress, (value) {
      return _then(_value.copyWith(progress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TeacherStudentDetailImplCopyWith<$Res>
    implements $TeacherStudentDetailCopyWith<$Res> {
  factory _$$TeacherStudentDetailImplCopyWith(
    _$TeacherStudentDetailImpl value,
    $Res Function(_$TeacherStudentDetailImpl) then,
  ) = __$$TeacherStudentDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    TeacherStudentBrief student,
    TeacherCourseBrief course,
    TeacherProgressBrief progress,
    List<TeacherLessonProgressItem> lessons,
    List<TeacherSubmissionSummaryItem> submissions,
    List<TeacherQuizResultItem> quizResults,
  });

  @override
  $TeacherStudentBriefCopyWith<$Res> get student;
  @override
  $TeacherCourseBriefCopyWith<$Res> get course;
  @override
  $TeacherProgressBriefCopyWith<$Res> get progress;
}

/// @nodoc
class __$$TeacherStudentDetailImplCopyWithImpl<$Res>
    extends _$TeacherStudentDetailCopyWithImpl<$Res, _$TeacherStudentDetailImpl>
    implements _$$TeacherStudentDetailImplCopyWith<$Res> {
  __$$TeacherStudentDetailImplCopyWithImpl(
    _$TeacherStudentDetailImpl _value,
    $Res Function(_$TeacherStudentDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherStudentDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? student = null,
    Object? course = null,
    Object? progress = null,
    Object? lessons = null,
    Object? submissions = null,
    Object? quizResults = null,
  }) {
    return _then(
      _$TeacherStudentDetailImpl(
        student: null == student
            ? _value.student
            : student // ignore: cast_nullable_to_non_nullable
                  as TeacherStudentBrief,
        course: null == course
            ? _value.course
            : course // ignore: cast_nullable_to_non_nullable
                  as TeacherCourseBrief,
        progress: null == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as TeacherProgressBrief,
        lessons: null == lessons
            ? _value._lessons
            : lessons // ignore: cast_nullable_to_non_nullable
                  as List<TeacherLessonProgressItem>,
        submissions: null == submissions
            ? _value._submissions
            : submissions // ignore: cast_nullable_to_non_nullable
                  as List<TeacherSubmissionSummaryItem>,
        quizResults: null == quizResults
            ? _value._quizResults
            : quizResults // ignore: cast_nullable_to_non_nullable
                  as List<TeacherQuizResultItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeacherStudentDetailImpl implements _TeacherStudentDetail {
  const _$TeacherStudentDetailImpl({
    required this.student,
    required this.course,
    required this.progress,
    final List<TeacherLessonProgressItem> lessons = const [],
    final List<TeacherSubmissionSummaryItem> submissions = const [],
    final List<TeacherQuizResultItem> quizResults = const [],
  }) : _lessons = lessons,
       _submissions = submissions,
       _quizResults = quizResults;

  factory _$TeacherStudentDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherStudentDetailImplFromJson(json);

  @override
  final TeacherStudentBrief student;
  @override
  final TeacherCourseBrief course;
  @override
  final TeacherProgressBrief progress;
  final List<TeacherLessonProgressItem> _lessons;
  @override
  @JsonKey()
  List<TeacherLessonProgressItem> get lessons {
    if (_lessons is EqualUnmodifiableListView) return _lessons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lessons);
  }

  final List<TeacherSubmissionSummaryItem> _submissions;
  @override
  @JsonKey()
  List<TeacherSubmissionSummaryItem> get submissions {
    if (_submissions is EqualUnmodifiableListView) return _submissions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_submissions);
  }

  final List<TeacherQuizResultItem> _quizResults;
  @override
  @JsonKey()
  List<TeacherQuizResultItem> get quizResults {
    if (_quizResults is EqualUnmodifiableListView) return _quizResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_quizResults);
  }

  @override
  String toString() {
    return 'TeacherStudentDetail(student: $student, course: $course, progress: $progress, lessons: $lessons, submissions: $submissions, quizResults: $quizResults)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherStudentDetailImpl &&
            (identical(other.student, student) || other.student == student) &&
            (identical(other.course, course) || other.course == course) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            const DeepCollectionEquality().equals(other._lessons, _lessons) &&
            const DeepCollectionEquality().equals(
              other._submissions,
              _submissions,
            ) &&
            const DeepCollectionEquality().equals(
              other._quizResults,
              _quizResults,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    student,
    course,
    progress,
    const DeepCollectionEquality().hash(_lessons),
    const DeepCollectionEquality().hash(_submissions),
    const DeepCollectionEquality().hash(_quizResults),
  );

  /// Create a copy of TeacherStudentDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherStudentDetailImplCopyWith<_$TeacherStudentDetailImpl>
  get copyWith =>
      __$$TeacherStudentDetailImplCopyWithImpl<_$TeacherStudentDetailImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherStudentDetailImplToJson(this);
  }
}

abstract class _TeacherStudentDetail implements TeacherStudentDetail {
  const factory _TeacherStudentDetail({
    required final TeacherStudentBrief student,
    required final TeacherCourseBrief course,
    required final TeacherProgressBrief progress,
    final List<TeacherLessonProgressItem> lessons,
    final List<TeacherSubmissionSummaryItem> submissions,
    final List<TeacherQuizResultItem> quizResults,
  }) = _$TeacherStudentDetailImpl;

  factory _TeacherStudentDetail.fromJson(Map<String, dynamic> json) =
      _$TeacherStudentDetailImpl.fromJson;

  @override
  TeacherStudentBrief get student;
  @override
  TeacherCourseBrief get course;
  @override
  TeacherProgressBrief get progress;
  @override
  List<TeacherLessonProgressItem> get lessons;
  @override
  List<TeacherSubmissionSummaryItem> get submissions;
  @override
  List<TeacherQuizResultItem> get quizResults;

  /// Create a copy of TeacherStudentDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherStudentDetailImplCopyWith<_$TeacherStudentDetailImpl>
  get copyWith => throw _privateConstructorUsedError;
}

TeacherLessonBrief _$TeacherLessonBriefFromJson(Map<String, dynamic> json) {
  return _TeacherLessonBrief.fromJson(json);
}

/// @nodoc
mixin _$TeacherLessonBrief {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;

  /// Serializes this TeacherLessonBrief to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherLessonBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherLessonBriefCopyWith<TeacherLessonBrief> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherLessonBriefCopyWith<$Res> {
  factory $TeacherLessonBriefCopyWith(
    TeacherLessonBrief value,
    $Res Function(TeacherLessonBrief) then,
  ) = _$TeacherLessonBriefCopyWithImpl<$Res, TeacherLessonBrief>;
  @useResult
  $Res call({int id, String title});
}

/// @nodoc
class _$TeacherLessonBriefCopyWithImpl<$Res, $Val extends TeacherLessonBrief>
    implements $TeacherLessonBriefCopyWith<$Res> {
  _$TeacherLessonBriefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherLessonBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? title = null}) {
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeacherLessonBriefImplCopyWith<$Res>
    implements $TeacherLessonBriefCopyWith<$Res> {
  factory _$$TeacherLessonBriefImplCopyWith(
    _$TeacherLessonBriefImpl value,
    $Res Function(_$TeacherLessonBriefImpl) then,
  ) = __$$TeacherLessonBriefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String title});
}

/// @nodoc
class __$$TeacherLessonBriefImplCopyWithImpl<$Res>
    extends _$TeacherLessonBriefCopyWithImpl<$Res, _$TeacherLessonBriefImpl>
    implements _$$TeacherLessonBriefImplCopyWith<$Res> {
  __$$TeacherLessonBriefImplCopyWithImpl(
    _$TeacherLessonBriefImpl _value,
    $Res Function(_$TeacherLessonBriefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherLessonBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? title = null}) {
    return _then(
      _$TeacherLessonBriefImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeacherLessonBriefImpl implements _TeacherLessonBrief {
  const _$TeacherLessonBriefImpl({required this.id, required this.title});

  factory _$TeacherLessonBriefImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherLessonBriefImplFromJson(json);

  @override
  final int id;
  @override
  final String title;

  @override
  String toString() {
    return 'TeacherLessonBrief(id: $id, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherLessonBriefImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title);

  /// Create a copy of TeacherLessonBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherLessonBriefImplCopyWith<_$TeacherLessonBriefImpl> get copyWith =>
      __$$TeacherLessonBriefImplCopyWithImpl<_$TeacherLessonBriefImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherLessonBriefImplToJson(this);
  }
}

abstract class _TeacherLessonBrief implements TeacherLessonBrief {
  const factory _TeacherLessonBrief({
    required final int id,
    required final String title,
  }) = _$TeacherLessonBriefImpl;

  factory _TeacherLessonBrief.fromJson(Map<String, dynamic> json) =
      _$TeacherLessonBriefImpl.fromJson;

  @override
  int get id;
  @override
  String get title;

  /// Create a copy of TeacherLessonBrief
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherLessonBriefImplCopyWith<_$TeacherLessonBriefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TeacherAssignmentBrief _$TeacherAssignmentBriefFromJson(
  Map<String, dynamic> json,
) {
  return _TeacherAssignmentBrief.fromJson(json);
}

/// @nodoc
mixin _$TeacherAssignmentBrief {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;

  /// Serializes this TeacherAssignmentBrief to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherAssignmentBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherAssignmentBriefCopyWith<TeacherAssignmentBrief> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherAssignmentBriefCopyWith<$Res> {
  factory $TeacherAssignmentBriefCopyWith(
    TeacherAssignmentBrief value,
    $Res Function(TeacherAssignmentBrief) then,
  ) = _$TeacherAssignmentBriefCopyWithImpl<$Res, TeacherAssignmentBrief>;
  @useResult
  $Res call({int id, String title, int points});
}

/// @nodoc
class _$TeacherAssignmentBriefCopyWithImpl<
  $Res,
  $Val extends TeacherAssignmentBrief
>
    implements $TeacherAssignmentBriefCopyWith<$Res> {
  _$TeacherAssignmentBriefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherAssignmentBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? title = null, Object? points = null}) {
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
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeacherAssignmentBriefImplCopyWith<$Res>
    implements $TeacherAssignmentBriefCopyWith<$Res> {
  factory _$$TeacherAssignmentBriefImplCopyWith(
    _$TeacherAssignmentBriefImpl value,
    $Res Function(_$TeacherAssignmentBriefImpl) then,
  ) = __$$TeacherAssignmentBriefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String title, int points});
}

/// @nodoc
class __$$TeacherAssignmentBriefImplCopyWithImpl<$Res>
    extends
        _$TeacherAssignmentBriefCopyWithImpl<$Res, _$TeacherAssignmentBriefImpl>
    implements _$$TeacherAssignmentBriefImplCopyWith<$Res> {
  __$$TeacherAssignmentBriefImplCopyWithImpl(
    _$TeacherAssignmentBriefImpl _value,
    $Res Function(_$TeacherAssignmentBriefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherAssignmentBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? title = null, Object? points = null}) {
    return _then(
      _$TeacherAssignmentBriefImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeacherAssignmentBriefImpl implements _TeacherAssignmentBrief {
  const _$TeacherAssignmentBriefImpl({
    required this.id,
    required this.title,
    required this.points,
  });

  factory _$TeacherAssignmentBriefImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherAssignmentBriefImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final int points;

  @override
  String toString() {
    return 'TeacherAssignmentBrief(id: $id, title: $title, points: $points)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherAssignmentBriefImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.points, points) || other.points == points));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, points);

  /// Create a copy of TeacherAssignmentBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherAssignmentBriefImplCopyWith<_$TeacherAssignmentBriefImpl>
  get copyWith =>
      __$$TeacherAssignmentBriefImplCopyWithImpl<_$TeacherAssignmentBriefImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherAssignmentBriefImplToJson(this);
  }
}

abstract class _TeacherAssignmentBrief implements TeacherAssignmentBrief {
  const factory _TeacherAssignmentBrief({
    required final int id,
    required final String title,
    required final int points,
  }) = _$TeacherAssignmentBriefImpl;

  factory _TeacherAssignmentBrief.fromJson(Map<String, dynamic> json) =
      _$TeacherAssignmentBriefImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  int get points;

  /// Create a copy of TeacherAssignmentBrief
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherAssignmentBriefImplCopyWith<_$TeacherAssignmentBriefImpl>
  get copyWith => throw _privateConstructorUsedError;
}

TeacherSubmissionListItem _$TeacherSubmissionListItemFromJson(
  Map<String, dynamic> json,
) {
  return _TeacherSubmissionListItem.fromJson(json);
}

/// @nodoc
mixin _$TeacherSubmissionListItem {
  int get id => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime? get submittedAt => throw _privateConstructorUsedError;
  TeacherStudentBrief get student => throw _privateConstructorUsedError;
  TeacherCourseBrief get course => throw _privateConstructorUsedError;
  TeacherLessonBrief get lesson => throw _privateConstructorUsedError;
  TeacherAssignmentBrief get assignment => throw _privateConstructorUsedError;

  /// Serializes this TeacherSubmissionListItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherSubmissionListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherSubmissionListItemCopyWith<TeacherSubmissionListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherSubmissionListItemCopyWith<$Res> {
  factory $TeacherSubmissionListItemCopyWith(
    TeacherSubmissionListItem value,
    $Res Function(TeacherSubmissionListItem) then,
  ) = _$TeacherSubmissionListItemCopyWithImpl<$Res, TeacherSubmissionListItem>;
  @useResult
  $Res call({
    int id,
    String status,
    DateTime? submittedAt,
    TeacherStudentBrief student,
    TeacherCourseBrief course,
    TeacherLessonBrief lesson,
    TeacherAssignmentBrief assignment,
  });

  $TeacherStudentBriefCopyWith<$Res> get student;
  $TeacherCourseBriefCopyWith<$Res> get course;
  $TeacherLessonBriefCopyWith<$Res> get lesson;
  $TeacherAssignmentBriefCopyWith<$Res> get assignment;
}

/// @nodoc
class _$TeacherSubmissionListItemCopyWithImpl<
  $Res,
  $Val extends TeacherSubmissionListItem
>
    implements $TeacherSubmissionListItemCopyWith<$Res> {
  _$TeacherSubmissionListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherSubmissionListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? submittedAt = freezed,
    Object? student = null,
    Object? course = null,
    Object? lesson = null,
    Object? assignment = null,
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
            submittedAt: freezed == submittedAt
                ? _value.submittedAt
                : submittedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            student: null == student
                ? _value.student
                : student // ignore: cast_nullable_to_non_nullable
                      as TeacherStudentBrief,
            course: null == course
                ? _value.course
                : course // ignore: cast_nullable_to_non_nullable
                      as TeacherCourseBrief,
            lesson: null == lesson
                ? _value.lesson
                : lesson // ignore: cast_nullable_to_non_nullable
                      as TeacherLessonBrief,
            assignment: null == assignment
                ? _value.assignment
                : assignment // ignore: cast_nullable_to_non_nullable
                      as TeacherAssignmentBrief,
          )
          as $Val,
    );
  }

  /// Create a copy of TeacherSubmissionListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeacherStudentBriefCopyWith<$Res> get student {
    return $TeacherStudentBriefCopyWith<$Res>(_value.student, (value) {
      return _then(_value.copyWith(student: value) as $Val);
    });
  }

  /// Create a copy of TeacherSubmissionListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeacherCourseBriefCopyWith<$Res> get course {
    return $TeacherCourseBriefCopyWith<$Res>(_value.course, (value) {
      return _then(_value.copyWith(course: value) as $Val);
    });
  }

  /// Create a copy of TeacherSubmissionListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeacherLessonBriefCopyWith<$Res> get lesson {
    return $TeacherLessonBriefCopyWith<$Res>(_value.lesson, (value) {
      return _then(_value.copyWith(lesson: value) as $Val);
    });
  }

  /// Create a copy of TeacherSubmissionListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeacherAssignmentBriefCopyWith<$Res> get assignment {
    return $TeacherAssignmentBriefCopyWith<$Res>(_value.assignment, (value) {
      return _then(_value.copyWith(assignment: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TeacherSubmissionListItemImplCopyWith<$Res>
    implements $TeacherSubmissionListItemCopyWith<$Res> {
  factory _$$TeacherSubmissionListItemImplCopyWith(
    _$TeacherSubmissionListItemImpl value,
    $Res Function(_$TeacherSubmissionListItemImpl) then,
  ) = __$$TeacherSubmissionListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String status,
    DateTime? submittedAt,
    TeacherStudentBrief student,
    TeacherCourseBrief course,
    TeacherLessonBrief lesson,
    TeacherAssignmentBrief assignment,
  });

  @override
  $TeacherStudentBriefCopyWith<$Res> get student;
  @override
  $TeacherCourseBriefCopyWith<$Res> get course;
  @override
  $TeacherLessonBriefCopyWith<$Res> get lesson;
  @override
  $TeacherAssignmentBriefCopyWith<$Res> get assignment;
}

/// @nodoc
class __$$TeacherSubmissionListItemImplCopyWithImpl<$Res>
    extends
        _$TeacherSubmissionListItemCopyWithImpl<
          $Res,
          _$TeacherSubmissionListItemImpl
        >
    implements _$$TeacherSubmissionListItemImplCopyWith<$Res> {
  __$$TeacherSubmissionListItemImplCopyWithImpl(
    _$TeacherSubmissionListItemImpl _value,
    $Res Function(_$TeacherSubmissionListItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherSubmissionListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? submittedAt = freezed,
    Object? student = null,
    Object? course = null,
    Object? lesson = null,
    Object? assignment = null,
  }) {
    return _then(
      _$TeacherSubmissionListItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        submittedAt: freezed == submittedAt
            ? _value.submittedAt
            : submittedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        student: null == student
            ? _value.student
            : student // ignore: cast_nullable_to_non_nullable
                  as TeacherStudentBrief,
        course: null == course
            ? _value.course
            : course // ignore: cast_nullable_to_non_nullable
                  as TeacherCourseBrief,
        lesson: null == lesson
            ? _value.lesson
            : lesson // ignore: cast_nullable_to_non_nullable
                  as TeacherLessonBrief,
        assignment: null == assignment
            ? _value.assignment
            : assignment // ignore: cast_nullable_to_non_nullable
                  as TeacherAssignmentBrief,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeacherSubmissionListItemImpl implements _TeacherSubmissionListItem {
  const _$TeacherSubmissionListItemImpl({
    required this.id,
    required this.status,
    this.submittedAt,
    required this.student,
    required this.course,
    required this.lesson,
    required this.assignment,
  });

  factory _$TeacherSubmissionListItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherSubmissionListItemImplFromJson(json);

  @override
  final int id;
  @override
  final String status;
  @override
  final DateTime? submittedAt;
  @override
  final TeacherStudentBrief student;
  @override
  final TeacherCourseBrief course;
  @override
  final TeacherLessonBrief lesson;
  @override
  final TeacherAssignmentBrief assignment;

  @override
  String toString() {
    return 'TeacherSubmissionListItem(id: $id, status: $status, submittedAt: $submittedAt, student: $student, course: $course, lesson: $lesson, assignment: $assignment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherSubmissionListItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.student, student) || other.student == student) &&
            (identical(other.course, course) || other.course == course) &&
            (identical(other.lesson, lesson) || other.lesson == lesson) &&
            (identical(other.assignment, assignment) ||
                other.assignment == assignment));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    status,
    submittedAt,
    student,
    course,
    lesson,
    assignment,
  );

  /// Create a copy of TeacherSubmissionListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherSubmissionListItemImplCopyWith<_$TeacherSubmissionListItemImpl>
  get copyWith =>
      __$$TeacherSubmissionListItemImplCopyWithImpl<
        _$TeacherSubmissionListItemImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherSubmissionListItemImplToJson(this);
  }
}

abstract class _TeacherSubmissionListItem implements TeacherSubmissionListItem {
  const factory _TeacherSubmissionListItem({
    required final int id,
    required final String status,
    final DateTime? submittedAt,
    required final TeacherStudentBrief student,
    required final TeacherCourseBrief course,
    required final TeacherLessonBrief lesson,
    required final TeacherAssignmentBrief assignment,
  }) = _$TeacherSubmissionListItemImpl;

  factory _TeacherSubmissionListItem.fromJson(Map<String, dynamic> json) =
      _$TeacherSubmissionListItemImpl.fromJson;

  @override
  int get id;
  @override
  String get status;
  @override
  DateTime? get submittedAt;
  @override
  TeacherStudentBrief get student;
  @override
  TeacherCourseBrief get course;
  @override
  TeacherLessonBrief get lesson;
  @override
  TeacherAssignmentBrief get assignment;

  /// Create a copy of TeacherSubmissionListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherSubmissionListItemImplCopyWith<_$TeacherSubmissionListItemImpl>
  get copyWith => throw _privateConstructorUsedError;
}

TeacherSubmissionListMeta _$TeacherSubmissionListMetaFromJson(
  Map<String, dynamic> json,
) {
  return _TeacherSubmissionListMeta.fromJson(json);
}

/// @nodoc
mixin _$TeacherSubmissionListMeta {
  int get page => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  /// Serializes this TeacherSubmissionListMeta to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherSubmissionListMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherSubmissionListMetaCopyWith<TeacherSubmissionListMeta> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherSubmissionListMetaCopyWith<$Res> {
  factory $TeacherSubmissionListMetaCopyWith(
    TeacherSubmissionListMeta value,
    $Res Function(TeacherSubmissionListMeta) then,
  ) = _$TeacherSubmissionListMetaCopyWithImpl<$Res, TeacherSubmissionListMeta>;
  @useResult
  $Res call({int page, int limit, int total});
}

/// @nodoc
class _$TeacherSubmissionListMetaCopyWithImpl<
  $Res,
  $Val extends TeacherSubmissionListMeta
>
    implements $TeacherSubmissionListMetaCopyWith<$Res> {
  _$TeacherSubmissionListMetaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherSubmissionListMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? page = null, Object? limit = null, Object? total = null}) {
    return _then(
      _value.copyWith(
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            limit: null == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeacherSubmissionListMetaImplCopyWith<$Res>
    implements $TeacherSubmissionListMetaCopyWith<$Res> {
  factory _$$TeacherSubmissionListMetaImplCopyWith(
    _$TeacherSubmissionListMetaImpl value,
    $Res Function(_$TeacherSubmissionListMetaImpl) then,
  ) = __$$TeacherSubmissionListMetaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int page, int limit, int total});
}

/// @nodoc
class __$$TeacherSubmissionListMetaImplCopyWithImpl<$Res>
    extends
        _$TeacherSubmissionListMetaCopyWithImpl<
          $Res,
          _$TeacherSubmissionListMetaImpl
        >
    implements _$$TeacherSubmissionListMetaImplCopyWith<$Res> {
  __$$TeacherSubmissionListMetaImplCopyWithImpl(
    _$TeacherSubmissionListMetaImpl _value,
    $Res Function(_$TeacherSubmissionListMetaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherSubmissionListMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? page = null, Object? limit = null, Object? total = null}) {
    return _then(
      _$TeacherSubmissionListMetaImpl(
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeacherSubmissionListMetaImpl implements _TeacherSubmissionListMeta {
  const _$TeacherSubmissionListMetaImpl({
    required this.page,
    required this.limit,
    required this.total,
  });

  factory _$TeacherSubmissionListMetaImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherSubmissionListMetaImplFromJson(json);

  @override
  final int page;
  @override
  final int limit;
  @override
  final int total;

  @override
  String toString() {
    return 'TeacherSubmissionListMeta(page: $page, limit: $limit, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherSubmissionListMetaImpl &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, page, limit, total);

  /// Create a copy of TeacherSubmissionListMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherSubmissionListMetaImplCopyWith<_$TeacherSubmissionListMetaImpl>
  get copyWith =>
      __$$TeacherSubmissionListMetaImplCopyWithImpl<
        _$TeacherSubmissionListMetaImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherSubmissionListMetaImplToJson(this);
  }
}

abstract class _TeacherSubmissionListMeta implements TeacherSubmissionListMeta {
  const factory _TeacherSubmissionListMeta({
    required final int page,
    required final int limit,
    required final int total,
  }) = _$TeacherSubmissionListMetaImpl;

  factory _TeacherSubmissionListMeta.fromJson(Map<String, dynamic> json) =
      _$TeacherSubmissionListMetaImpl.fromJson;

  @override
  int get page;
  @override
  int get limit;
  @override
  int get total;

  /// Create a copy of TeacherSubmissionListMeta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherSubmissionListMetaImplCopyWith<_$TeacherSubmissionListMetaImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TeacherSubmissionListResult {
  List<TeacherSubmissionListItem> get items =>
      throw _privateConstructorUsedError;
  TeacherSubmissionListMeta get meta => throw _privateConstructorUsedError;

  /// Create a copy of TeacherSubmissionListResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherSubmissionListResultCopyWith<TeacherSubmissionListResult>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherSubmissionListResultCopyWith<$Res> {
  factory $TeacherSubmissionListResultCopyWith(
    TeacherSubmissionListResult value,
    $Res Function(TeacherSubmissionListResult) then,
  ) =
      _$TeacherSubmissionListResultCopyWithImpl<
        $Res,
        TeacherSubmissionListResult
      >;
  @useResult
  $Res call({
    List<TeacherSubmissionListItem> items,
    TeacherSubmissionListMeta meta,
  });

  $TeacherSubmissionListMetaCopyWith<$Res> get meta;
}

/// @nodoc
class _$TeacherSubmissionListResultCopyWithImpl<
  $Res,
  $Val extends TeacherSubmissionListResult
>
    implements $TeacherSubmissionListResultCopyWith<$Res> {
  _$TeacherSubmissionListResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherSubmissionListResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? items = null, Object? meta = null}) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<TeacherSubmissionListItem>,
            meta: null == meta
                ? _value.meta
                : meta // ignore: cast_nullable_to_non_nullable
                      as TeacherSubmissionListMeta,
          )
          as $Val,
    );
  }

  /// Create a copy of TeacherSubmissionListResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeacherSubmissionListMetaCopyWith<$Res> get meta {
    return $TeacherSubmissionListMetaCopyWith<$Res>(_value.meta, (value) {
      return _then(_value.copyWith(meta: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TeacherSubmissionListResultImplCopyWith<$Res>
    implements $TeacherSubmissionListResultCopyWith<$Res> {
  factory _$$TeacherSubmissionListResultImplCopyWith(
    _$TeacherSubmissionListResultImpl value,
    $Res Function(_$TeacherSubmissionListResultImpl) then,
  ) = __$$TeacherSubmissionListResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<TeacherSubmissionListItem> items,
    TeacherSubmissionListMeta meta,
  });

  @override
  $TeacherSubmissionListMetaCopyWith<$Res> get meta;
}

/// @nodoc
class __$$TeacherSubmissionListResultImplCopyWithImpl<$Res>
    extends
        _$TeacherSubmissionListResultCopyWithImpl<
          $Res,
          _$TeacherSubmissionListResultImpl
        >
    implements _$$TeacherSubmissionListResultImplCopyWith<$Res> {
  __$$TeacherSubmissionListResultImplCopyWithImpl(
    _$TeacherSubmissionListResultImpl _value,
    $Res Function(_$TeacherSubmissionListResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherSubmissionListResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? items = null, Object? meta = null}) {
    return _then(
      _$TeacherSubmissionListResultImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<TeacherSubmissionListItem>,
        meta: null == meta
            ? _value.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as TeacherSubmissionListMeta,
      ),
    );
  }
}

/// @nodoc

class _$TeacherSubmissionListResultImpl
    implements _TeacherSubmissionListResult {
  const _$TeacherSubmissionListResultImpl({
    required final List<TeacherSubmissionListItem> items,
    required this.meta,
  }) : _items = items;

  final List<TeacherSubmissionListItem> _items;
  @override
  List<TeacherSubmissionListItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final TeacherSubmissionListMeta meta;

  @override
  String toString() {
    return 'TeacherSubmissionListResult(items: $items, meta: $meta)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherSubmissionListResultImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.meta, meta) || other.meta == meta));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    meta,
  );

  /// Create a copy of TeacherSubmissionListResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherSubmissionListResultImplCopyWith<_$TeacherSubmissionListResultImpl>
  get copyWith =>
      __$$TeacherSubmissionListResultImplCopyWithImpl<
        _$TeacherSubmissionListResultImpl
      >(this, _$identity);
}

abstract class _TeacherSubmissionListResult
    implements TeacherSubmissionListResult {
  const factory _TeacherSubmissionListResult({
    required final List<TeacherSubmissionListItem> items,
    required final TeacherSubmissionListMeta meta,
  }) = _$TeacherSubmissionListResultImpl;

  @override
  List<TeacherSubmissionListItem> get items;
  @override
  TeacherSubmissionListMeta get meta;

  /// Create a copy of TeacherSubmissionListResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherSubmissionListResultImplCopyWith<_$TeacherSubmissionListResultImpl>
  get copyWith => throw _privateConstructorUsedError;
}

TeacherGroupRef _$TeacherGroupRefFromJson(Map<String, dynamic> json) {
  return _TeacherGroupRef.fromJson(json);
}

/// @nodoc
mixin _$TeacherGroupRef {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;

  /// Serializes this TeacherGroupRef to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherGroupRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherGroupRefCopyWith<TeacherGroupRef> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherGroupRefCopyWith<$Res> {
  factory $TeacherGroupRefCopyWith(
    TeacherGroupRef value,
    $Res Function(TeacherGroupRef) then,
  ) = _$TeacherGroupRefCopyWithImpl<$Res, TeacherGroupRef>;
  @useResult
  $Res call({int id, String title});
}

/// @nodoc
class _$TeacherGroupRefCopyWithImpl<$Res, $Val extends TeacherGroupRef>
    implements $TeacherGroupRefCopyWith<$Res> {
  _$TeacherGroupRefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherGroupRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? title = null}) {
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeacherGroupRefImplCopyWith<$Res>
    implements $TeacherGroupRefCopyWith<$Res> {
  factory _$$TeacherGroupRefImplCopyWith(
    _$TeacherGroupRefImpl value,
    $Res Function(_$TeacherGroupRefImpl) then,
  ) = __$$TeacherGroupRefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String title});
}

/// @nodoc
class __$$TeacherGroupRefImplCopyWithImpl<$Res>
    extends _$TeacherGroupRefCopyWithImpl<$Res, _$TeacherGroupRefImpl>
    implements _$$TeacherGroupRefImplCopyWith<$Res> {
  __$$TeacherGroupRefImplCopyWithImpl(
    _$TeacherGroupRefImpl _value,
    $Res Function(_$TeacherGroupRefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherGroupRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? title = null}) {
    return _then(
      _$TeacherGroupRefImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeacherGroupRefImpl implements _TeacherGroupRef {
  const _$TeacherGroupRefImpl({required this.id, required this.title});

  factory _$TeacherGroupRefImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherGroupRefImplFromJson(json);

  @override
  final int id;
  @override
  final String title;

  @override
  String toString() {
    return 'TeacherGroupRef(id: $id, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherGroupRefImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title);

  /// Create a copy of TeacherGroupRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherGroupRefImplCopyWith<_$TeacherGroupRefImpl> get copyWith =>
      __$$TeacherGroupRefImplCopyWithImpl<_$TeacherGroupRefImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherGroupRefImplToJson(this);
  }
}

abstract class _TeacherGroupRef implements TeacherGroupRef {
  const factory _TeacherGroupRef({
    required final int id,
    required final String title,
  }) = _$TeacherGroupRefImpl;

  factory _TeacherGroupRef.fromJson(Map<String, dynamic> json) =
      _$TeacherGroupRefImpl.fromJson;

  @override
  int get id;
  @override
  String get title;

  /// Create a copy of TeacherGroupRef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherGroupRefImplCopyWith<_$TeacherGroupRefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TeacherModuleRef _$TeacherModuleRefFromJson(Map<String, dynamic> json) {
  return _TeacherModuleRef.fromJson(json);
}

/// @nodoc
mixin _$TeacherModuleRef {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;

  /// Serializes this TeacherModuleRef to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherModuleRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherModuleRefCopyWith<TeacherModuleRef> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherModuleRefCopyWith<$Res> {
  factory $TeacherModuleRefCopyWith(
    TeacherModuleRef value,
    $Res Function(TeacherModuleRef) then,
  ) = _$TeacherModuleRefCopyWithImpl<$Res, TeacherModuleRef>;
  @useResult
  $Res call({int id, String title});
}

/// @nodoc
class _$TeacherModuleRefCopyWithImpl<$Res, $Val extends TeacherModuleRef>
    implements $TeacherModuleRefCopyWith<$Res> {
  _$TeacherModuleRefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherModuleRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? title = null}) {
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeacherModuleRefImplCopyWith<$Res>
    implements $TeacherModuleRefCopyWith<$Res> {
  factory _$$TeacherModuleRefImplCopyWith(
    _$TeacherModuleRefImpl value,
    $Res Function(_$TeacherModuleRefImpl) then,
  ) = __$$TeacherModuleRefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String title});
}

/// @nodoc
class __$$TeacherModuleRefImplCopyWithImpl<$Res>
    extends _$TeacherModuleRefCopyWithImpl<$Res, _$TeacherModuleRefImpl>
    implements _$$TeacherModuleRefImplCopyWith<$Res> {
  __$$TeacherModuleRefImplCopyWithImpl(
    _$TeacherModuleRefImpl _value,
    $Res Function(_$TeacherModuleRefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherModuleRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? title = null}) {
    return _then(
      _$TeacherModuleRefImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeacherModuleRefImpl implements _TeacherModuleRef {
  const _$TeacherModuleRefImpl({required this.id, required this.title});

  factory _$TeacherModuleRefImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherModuleRefImplFromJson(json);

  @override
  final int id;
  @override
  final String title;

  @override
  String toString() {
    return 'TeacherModuleRef(id: $id, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherModuleRefImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title);

  /// Create a copy of TeacherModuleRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherModuleRefImplCopyWith<_$TeacherModuleRefImpl> get copyWith =>
      __$$TeacherModuleRefImplCopyWithImpl<_$TeacherModuleRefImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherModuleRefImplToJson(this);
  }
}

abstract class _TeacherModuleRef implements TeacherModuleRef {
  const factory _TeacherModuleRef({
    required final int id,
    required final String title,
  }) = _$TeacherModuleRefImpl;

  factory _TeacherModuleRef.fromJson(Map<String, dynamic> json) =
      _$TeacherModuleRefImpl.fromJson;

  @override
  int get id;
  @override
  String get title;

  /// Create a copy of TeacherModuleRef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherModuleRefImplCopyWith<_$TeacherModuleRefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TeacherAssignmentContent _$TeacherAssignmentContentFromJson(
  Map<String, dynamic> json,
) {
  return _TeacherAssignmentContent.fromJson(json);
}

/// @nodoc
mixin _$TeacherAssignmentContent {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get assignmentType => throw _privateConstructorUsedError;
  String? get starterCode => throw _privateConstructorUsedError;
  String? get expectedOutput => throw _privateConstructorUsedError;
  String? get language => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;

  /// Serializes this TeacherAssignmentContent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherAssignmentContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherAssignmentContentCopyWith<TeacherAssignmentContent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherAssignmentContentCopyWith<$Res> {
  factory $TeacherAssignmentContentCopyWith(
    TeacherAssignmentContent value,
    $Res Function(TeacherAssignmentContent) then,
  ) = _$TeacherAssignmentContentCopyWithImpl<$Res, TeacherAssignmentContent>;
  @useResult
  $Res call({
    int id,
    String title,
    String? description,
    String assignmentType,
    String? starterCode,
    String? expectedOutput,
    String? language,
    int points,
  });
}

/// @nodoc
class _$TeacherAssignmentContentCopyWithImpl<
  $Res,
  $Val extends TeacherAssignmentContent
>
    implements $TeacherAssignmentContentCopyWith<$Res> {
  _$TeacherAssignmentContentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherAssignmentContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? assignmentType = null,
    Object? starterCode = freezed,
    Object? expectedOutput = freezed,
    Object? language = freezed,
    Object? points = null,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeacherAssignmentContentImplCopyWith<$Res>
    implements $TeacherAssignmentContentCopyWith<$Res> {
  factory _$$TeacherAssignmentContentImplCopyWith(
    _$TeacherAssignmentContentImpl value,
    $Res Function(_$TeacherAssignmentContentImpl) then,
  ) = __$$TeacherAssignmentContentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    String? description,
    String assignmentType,
    String? starterCode,
    String? expectedOutput,
    String? language,
    int points,
  });
}

/// @nodoc
class __$$TeacherAssignmentContentImplCopyWithImpl<$Res>
    extends
        _$TeacherAssignmentContentCopyWithImpl<
          $Res,
          _$TeacherAssignmentContentImpl
        >
    implements _$$TeacherAssignmentContentImplCopyWith<$Res> {
  __$$TeacherAssignmentContentImplCopyWithImpl(
    _$TeacherAssignmentContentImpl _value,
    $Res Function(_$TeacherAssignmentContentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherAssignmentContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? assignmentType = null,
    Object? starterCode = freezed,
    Object? expectedOutput = freezed,
    Object? language = freezed,
    Object? points = null,
  }) {
    return _then(
      _$TeacherAssignmentContentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeacherAssignmentContentImpl implements _TeacherAssignmentContent {
  const _$TeacherAssignmentContentImpl({
    required this.id,
    required this.title,
    this.description,
    required this.assignmentType,
    this.starterCode,
    this.expectedOutput,
    this.language,
    required this.points,
  });

  factory _$TeacherAssignmentContentImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherAssignmentContentImplFromJson(json);

  @override
  final int id;
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
  String toString() {
    return 'TeacherAssignmentContent(id: $id, title: $title, description: $description, assignmentType: $assignmentType, starterCode: $starterCode, expectedOutput: $expectedOutput, language: $language, points: $points)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherAssignmentContentImpl &&
            (identical(other.id, id) || other.id == id) &&
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
            (identical(other.points, points) || other.points == points));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    assignmentType,
    starterCode,
    expectedOutput,
    language,
    points,
  );

  /// Create a copy of TeacherAssignmentContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherAssignmentContentImplCopyWith<_$TeacherAssignmentContentImpl>
  get copyWith =>
      __$$TeacherAssignmentContentImplCopyWithImpl<
        _$TeacherAssignmentContentImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherAssignmentContentImplToJson(this);
  }
}

abstract class _TeacherAssignmentContent implements TeacherAssignmentContent {
  const factory _TeacherAssignmentContent({
    required final int id,
    required final String title,
    final String? description,
    required final String assignmentType,
    final String? starterCode,
    final String? expectedOutput,
    final String? language,
    required final int points,
  }) = _$TeacherAssignmentContentImpl;

  factory _TeacherAssignmentContent.fromJson(Map<String, dynamic> json) =
      _$TeacherAssignmentContentImpl.fromJson;

  @override
  int get id;
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

  /// Create a copy of TeacherAssignmentContent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherAssignmentContentImplCopyWith<_$TeacherAssignmentContentImpl>
  get copyWith => throw _privateConstructorUsedError;
}

TeacherSubmissionDetail _$TeacherSubmissionDetailFromJson(
  Map<String, dynamic> json,
) {
  return _TeacherSubmissionDetail.fromJson(json);
}

/// @nodoc
mixin _$TeacherSubmissionDetail {
  int get id => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get code => throw _privateConstructorUsedError;
  String? get answer => throw _privateConstructorUsedError;
  int? get score => throw _privateConstructorUsedError;
  String? get teacherFeedback => throw _privateConstructorUsedError;
  DateTime? get submittedAt => throw _privateConstructorUsedError;
  DateTime? get checkedAt => throw _privateConstructorUsedError;
  TeacherStudentBrief get student => throw _privateConstructorUsedError;
  TeacherGroupRef get group => throw _privateConstructorUsedError;
  TeacherCourseBrief get course => throw _privateConstructorUsedError;
  TeacherModuleRef get module => throw _privateConstructorUsedError;
  TeacherLessonBrief get lesson => throw _privateConstructorUsedError;
  TeacherAssignmentContent get assignment => throw _privateConstructorUsedError;

  /// Serializes this TeacherSubmissionDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherSubmissionDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherSubmissionDetailCopyWith<TeacherSubmissionDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherSubmissionDetailCopyWith<$Res> {
  factory $TeacherSubmissionDetailCopyWith(
    TeacherSubmissionDetail value,
    $Res Function(TeacherSubmissionDetail) then,
  ) = _$TeacherSubmissionDetailCopyWithImpl<$Res, TeacherSubmissionDetail>;
  @useResult
  $Res call({
    int id,
    String status,
    String? code,
    String? answer,
    int? score,
    String? teacherFeedback,
    DateTime? submittedAt,
    DateTime? checkedAt,
    TeacherStudentBrief student,
    TeacherGroupRef group,
    TeacherCourseBrief course,
    TeacherModuleRef module,
    TeacherLessonBrief lesson,
    TeacherAssignmentContent assignment,
  });

  $TeacherStudentBriefCopyWith<$Res> get student;
  $TeacherGroupRefCopyWith<$Res> get group;
  $TeacherCourseBriefCopyWith<$Res> get course;
  $TeacherModuleRefCopyWith<$Res> get module;
  $TeacherLessonBriefCopyWith<$Res> get lesson;
  $TeacherAssignmentContentCopyWith<$Res> get assignment;
}

/// @nodoc
class _$TeacherSubmissionDetailCopyWithImpl<
  $Res,
  $Val extends TeacherSubmissionDetail
>
    implements $TeacherSubmissionDetailCopyWith<$Res> {
  _$TeacherSubmissionDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherSubmissionDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? code = freezed,
    Object? answer = freezed,
    Object? score = freezed,
    Object? teacherFeedback = freezed,
    Object? submittedAt = freezed,
    Object? checkedAt = freezed,
    Object? student = null,
    Object? group = null,
    Object? course = null,
    Object? module = null,
    Object? lesson = null,
    Object? assignment = null,
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
            code: freezed == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String?,
            answer: freezed == answer
                ? _value.answer
                : answer // ignore: cast_nullable_to_non_nullable
                      as String?,
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
            student: null == student
                ? _value.student
                : student // ignore: cast_nullable_to_non_nullable
                      as TeacherStudentBrief,
            group: null == group
                ? _value.group
                : group // ignore: cast_nullable_to_non_nullable
                      as TeacherGroupRef,
            course: null == course
                ? _value.course
                : course // ignore: cast_nullable_to_non_nullable
                      as TeacherCourseBrief,
            module: null == module
                ? _value.module
                : module // ignore: cast_nullable_to_non_nullable
                      as TeacherModuleRef,
            lesson: null == lesson
                ? _value.lesson
                : lesson // ignore: cast_nullable_to_non_nullable
                      as TeacherLessonBrief,
            assignment: null == assignment
                ? _value.assignment
                : assignment // ignore: cast_nullable_to_non_nullable
                      as TeacherAssignmentContent,
          )
          as $Val,
    );
  }

  /// Create a copy of TeacherSubmissionDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeacherStudentBriefCopyWith<$Res> get student {
    return $TeacherStudentBriefCopyWith<$Res>(_value.student, (value) {
      return _then(_value.copyWith(student: value) as $Val);
    });
  }

  /// Create a copy of TeacherSubmissionDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeacherGroupRefCopyWith<$Res> get group {
    return $TeacherGroupRefCopyWith<$Res>(_value.group, (value) {
      return _then(_value.copyWith(group: value) as $Val);
    });
  }

  /// Create a copy of TeacherSubmissionDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeacherCourseBriefCopyWith<$Res> get course {
    return $TeacherCourseBriefCopyWith<$Res>(_value.course, (value) {
      return _then(_value.copyWith(course: value) as $Val);
    });
  }

  /// Create a copy of TeacherSubmissionDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeacherModuleRefCopyWith<$Res> get module {
    return $TeacherModuleRefCopyWith<$Res>(_value.module, (value) {
      return _then(_value.copyWith(module: value) as $Val);
    });
  }

  /// Create a copy of TeacherSubmissionDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeacherLessonBriefCopyWith<$Res> get lesson {
    return $TeacherLessonBriefCopyWith<$Res>(_value.lesson, (value) {
      return _then(_value.copyWith(lesson: value) as $Val);
    });
  }

  /// Create a copy of TeacherSubmissionDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeacherAssignmentContentCopyWith<$Res> get assignment {
    return $TeacherAssignmentContentCopyWith<$Res>(_value.assignment, (value) {
      return _then(_value.copyWith(assignment: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TeacherSubmissionDetailImplCopyWith<$Res>
    implements $TeacherSubmissionDetailCopyWith<$Res> {
  factory _$$TeacherSubmissionDetailImplCopyWith(
    _$TeacherSubmissionDetailImpl value,
    $Res Function(_$TeacherSubmissionDetailImpl) then,
  ) = __$$TeacherSubmissionDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String status,
    String? code,
    String? answer,
    int? score,
    String? teacherFeedback,
    DateTime? submittedAt,
    DateTime? checkedAt,
    TeacherStudentBrief student,
    TeacherGroupRef group,
    TeacherCourseBrief course,
    TeacherModuleRef module,
    TeacherLessonBrief lesson,
    TeacherAssignmentContent assignment,
  });

  @override
  $TeacherStudentBriefCopyWith<$Res> get student;
  @override
  $TeacherGroupRefCopyWith<$Res> get group;
  @override
  $TeacherCourseBriefCopyWith<$Res> get course;
  @override
  $TeacherModuleRefCopyWith<$Res> get module;
  @override
  $TeacherLessonBriefCopyWith<$Res> get lesson;
  @override
  $TeacherAssignmentContentCopyWith<$Res> get assignment;
}

/// @nodoc
class __$$TeacherSubmissionDetailImplCopyWithImpl<$Res>
    extends
        _$TeacherSubmissionDetailCopyWithImpl<
          $Res,
          _$TeacherSubmissionDetailImpl
        >
    implements _$$TeacherSubmissionDetailImplCopyWith<$Res> {
  __$$TeacherSubmissionDetailImplCopyWithImpl(
    _$TeacherSubmissionDetailImpl _value,
    $Res Function(_$TeacherSubmissionDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherSubmissionDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? code = freezed,
    Object? answer = freezed,
    Object? score = freezed,
    Object? teacherFeedback = freezed,
    Object? submittedAt = freezed,
    Object? checkedAt = freezed,
    Object? student = null,
    Object? group = null,
    Object? course = null,
    Object? module = null,
    Object? lesson = null,
    Object? assignment = null,
  }) {
    return _then(
      _$TeacherSubmissionDetailImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
        answer: freezed == answer
            ? _value.answer
            : answer // ignore: cast_nullable_to_non_nullable
                  as String?,
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
        student: null == student
            ? _value.student
            : student // ignore: cast_nullable_to_non_nullable
                  as TeacherStudentBrief,
        group: null == group
            ? _value.group
            : group // ignore: cast_nullable_to_non_nullable
                  as TeacherGroupRef,
        course: null == course
            ? _value.course
            : course // ignore: cast_nullable_to_non_nullable
                  as TeacherCourseBrief,
        module: null == module
            ? _value.module
            : module // ignore: cast_nullable_to_non_nullable
                  as TeacherModuleRef,
        lesson: null == lesson
            ? _value.lesson
            : lesson // ignore: cast_nullable_to_non_nullable
                  as TeacherLessonBrief,
        assignment: null == assignment
            ? _value.assignment
            : assignment // ignore: cast_nullable_to_non_nullable
                  as TeacherAssignmentContent,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeacherSubmissionDetailImpl implements _TeacherSubmissionDetail {
  const _$TeacherSubmissionDetailImpl({
    required this.id,
    required this.status,
    this.code,
    this.answer,
    this.score,
    this.teacherFeedback,
    this.submittedAt,
    this.checkedAt,
    required this.student,
    required this.group,
    required this.course,
    required this.module,
    required this.lesson,
    required this.assignment,
  });

  factory _$TeacherSubmissionDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherSubmissionDetailImplFromJson(json);

  @override
  final int id;
  @override
  final String status;
  @override
  final String? code;
  @override
  final String? answer;
  @override
  final int? score;
  @override
  final String? teacherFeedback;
  @override
  final DateTime? submittedAt;
  @override
  final DateTime? checkedAt;
  @override
  final TeacherStudentBrief student;
  @override
  final TeacherGroupRef group;
  @override
  final TeacherCourseBrief course;
  @override
  final TeacherModuleRef module;
  @override
  final TeacherLessonBrief lesson;
  @override
  final TeacherAssignmentContent assignment;

  @override
  String toString() {
    return 'TeacherSubmissionDetail(id: $id, status: $status, code: $code, answer: $answer, score: $score, teacherFeedback: $teacherFeedback, submittedAt: $submittedAt, checkedAt: $checkedAt, student: $student, group: $group, course: $course, module: $module, lesson: $lesson, assignment: $assignment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherSubmissionDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.answer, answer) || other.answer == answer) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.teacherFeedback, teacherFeedback) ||
                other.teacherFeedback == teacherFeedback) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.checkedAt, checkedAt) ||
                other.checkedAt == checkedAt) &&
            (identical(other.student, student) || other.student == student) &&
            (identical(other.group, group) || other.group == group) &&
            (identical(other.course, course) || other.course == course) &&
            (identical(other.module, module) || other.module == module) &&
            (identical(other.lesson, lesson) || other.lesson == lesson) &&
            (identical(other.assignment, assignment) ||
                other.assignment == assignment));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    status,
    code,
    answer,
    score,
    teacherFeedback,
    submittedAt,
    checkedAt,
    student,
    group,
    course,
    module,
    lesson,
    assignment,
  );

  /// Create a copy of TeacherSubmissionDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherSubmissionDetailImplCopyWith<_$TeacherSubmissionDetailImpl>
  get copyWith =>
      __$$TeacherSubmissionDetailImplCopyWithImpl<
        _$TeacherSubmissionDetailImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherSubmissionDetailImplToJson(this);
  }
}

abstract class _TeacherSubmissionDetail implements TeacherSubmissionDetail {
  const factory _TeacherSubmissionDetail({
    required final int id,
    required final String status,
    final String? code,
    final String? answer,
    final int? score,
    final String? teacherFeedback,
    final DateTime? submittedAt,
    final DateTime? checkedAt,
    required final TeacherStudentBrief student,
    required final TeacherGroupRef group,
    required final TeacherCourseBrief course,
    required final TeacherModuleRef module,
    required final TeacherLessonBrief lesson,
    required final TeacherAssignmentContent assignment,
  }) = _$TeacherSubmissionDetailImpl;

  factory _TeacherSubmissionDetail.fromJson(Map<String, dynamic> json) =
      _$TeacherSubmissionDetailImpl.fromJson;

  @override
  int get id;
  @override
  String get status;
  @override
  String? get code;
  @override
  String? get answer;
  @override
  int? get score;
  @override
  String? get teacherFeedback;
  @override
  DateTime? get submittedAt;
  @override
  DateTime? get checkedAt;
  @override
  TeacherStudentBrief get student;
  @override
  TeacherGroupRef get group;
  @override
  TeacherCourseBrief get course;
  @override
  TeacherModuleRef get module;
  @override
  TeacherLessonBrief get lesson;
  @override
  TeacherAssignmentContent get assignment;

  /// Create a copy of TeacherSubmissionDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherSubmissionDetailImplCopyWith<_$TeacherSubmissionDetailImpl>
  get copyWith => throw _privateConstructorUsedError;
}
