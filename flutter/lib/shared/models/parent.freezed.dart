// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parent.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ParentChildBrief _$ParentChildBriefFromJson(Map<String, dynamic> json) {
  return _ParentChildBrief.fromJson(json);
}

/// @nodoc
mixin _$ParentChildBrief {
  int get id => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;

  /// Serializes this ParentChildBrief to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParentChildBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParentChildBriefCopyWith<ParentChildBrief> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParentChildBriefCopyWith<$Res> {
  factory $ParentChildBriefCopyWith(
    ParentChildBrief value,
    $Res Function(ParentChildBrief) then,
  ) = _$ParentChildBriefCopyWithImpl<$Res, ParentChildBrief>;
  @useResult
  $Res call({int id, String firstName, String? lastName});
}

/// @nodoc
class _$ParentChildBriefCopyWithImpl<$Res, $Val extends ParentChildBrief>
    implements $ParentChildBriefCopyWith<$Res> {
  _$ParentChildBriefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParentChildBrief
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
abstract class _$$ParentChildBriefImplCopyWith<$Res>
    implements $ParentChildBriefCopyWith<$Res> {
  factory _$$ParentChildBriefImplCopyWith(
    _$ParentChildBriefImpl value,
    $Res Function(_$ParentChildBriefImpl) then,
  ) = __$$ParentChildBriefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String firstName, String? lastName});
}

/// @nodoc
class __$$ParentChildBriefImplCopyWithImpl<$Res>
    extends _$ParentChildBriefCopyWithImpl<$Res, _$ParentChildBriefImpl>
    implements _$$ParentChildBriefImplCopyWith<$Res> {
  __$$ParentChildBriefImplCopyWithImpl(
    _$ParentChildBriefImpl _value,
    $Res Function(_$ParentChildBriefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParentChildBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = freezed,
  }) {
    return _then(
      _$ParentChildBriefImpl(
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
class _$ParentChildBriefImpl implements _ParentChildBrief {
  const _$ParentChildBriefImpl({
    required this.id,
    required this.firstName,
    this.lastName,
  });

  factory _$ParentChildBriefImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParentChildBriefImplFromJson(json);

  @override
  final int id;
  @override
  final String firstName;
  @override
  final String? lastName;

  @override
  String toString() {
    return 'ParentChildBrief(id: $id, firstName: $firstName, lastName: $lastName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParentChildBriefImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, firstName, lastName);

  /// Create a copy of ParentChildBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParentChildBriefImplCopyWith<_$ParentChildBriefImpl> get copyWith =>
      __$$ParentChildBriefImplCopyWithImpl<_$ParentChildBriefImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ParentChildBriefImplToJson(this);
  }
}

abstract class _ParentChildBrief implements ParentChildBrief {
  const factory _ParentChildBrief({
    required final int id,
    required final String firstName,
    final String? lastName,
  }) = _$ParentChildBriefImpl;

  factory _ParentChildBrief.fromJson(Map<String, dynamic> json) =
      _$ParentChildBriefImpl.fromJson;

  @override
  int get id;
  @override
  String get firstName;
  @override
  String? get lastName;

  /// Create a copy of ParentChildBrief
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParentChildBriefImplCopyWith<_$ParentChildBriefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ParentCourseBrief _$ParentCourseBriefFromJson(Map<String, dynamic> json) {
  return _ParentCourseBrief.fromJson(json);
}

/// @nodoc
mixin _$ParentCourseBrief {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;

  /// Serializes this ParentCourseBrief to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParentCourseBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParentCourseBriefCopyWith<ParentCourseBrief> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParentCourseBriefCopyWith<$Res> {
  factory $ParentCourseBriefCopyWith(
    ParentCourseBrief value,
    $Res Function(ParentCourseBrief) then,
  ) = _$ParentCourseBriefCopyWithImpl<$Res, ParentCourseBrief>;
  @useResult
  $Res call({int id, String title, String slug});
}

/// @nodoc
class _$ParentCourseBriefCopyWithImpl<$Res, $Val extends ParentCourseBrief>
    implements $ParentCourseBriefCopyWith<$Res> {
  _$ParentCourseBriefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParentCourseBrief
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
abstract class _$$ParentCourseBriefImplCopyWith<$Res>
    implements $ParentCourseBriefCopyWith<$Res> {
  factory _$$ParentCourseBriefImplCopyWith(
    _$ParentCourseBriefImpl value,
    $Res Function(_$ParentCourseBriefImpl) then,
  ) = __$$ParentCourseBriefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String title, String slug});
}

/// @nodoc
class __$$ParentCourseBriefImplCopyWithImpl<$Res>
    extends _$ParentCourseBriefCopyWithImpl<$Res, _$ParentCourseBriefImpl>
    implements _$$ParentCourseBriefImplCopyWith<$Res> {
  __$$ParentCourseBriefImplCopyWithImpl(
    _$ParentCourseBriefImpl _value,
    $Res Function(_$ParentCourseBriefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParentCourseBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? title = null, Object? slug = null}) {
    return _then(
      _$ParentCourseBriefImpl(
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
class _$ParentCourseBriefImpl implements _ParentCourseBrief {
  const _$ParentCourseBriefImpl({
    required this.id,
    required this.title,
    required this.slug,
  });

  factory _$ParentCourseBriefImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParentCourseBriefImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String slug;

  @override
  String toString() {
    return 'ParentCourseBrief(id: $id, title: $title, slug: $slug)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParentCourseBriefImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.slug, slug) || other.slug == slug));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, slug);

  /// Create a copy of ParentCourseBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParentCourseBriefImplCopyWith<_$ParentCourseBriefImpl> get copyWith =>
      __$$ParentCourseBriefImplCopyWithImpl<_$ParentCourseBriefImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ParentCourseBriefImplToJson(this);
  }
}

abstract class _ParentCourseBrief implements ParentCourseBrief {
  const factory _ParentCourseBrief({
    required final int id,
    required final String title,
    required final String slug,
  }) = _$ParentCourseBriefImpl;

  factory _ParentCourseBrief.fromJson(Map<String, dynamic> json) =
      _$ParentCourseBriefImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String get slug;

  /// Create a copy of ParentCourseBrief
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParentCourseBriefImplCopyWith<_$ParentCourseBriefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ParentProgressBrief _$ParentProgressBriefFromJson(Map<String, dynamic> json) {
  return _ParentProgressBrief.fromJson(json);
}

/// @nodoc
mixin _$ParentProgressBrief {
  int get completedLessons => throw _privateConstructorUsedError;
  int get totalLessons => throw _privateConstructorUsedError;
  int get progressPercent => throw _privateConstructorUsedError;

  /// Serializes this ParentProgressBrief to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParentProgressBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParentProgressBriefCopyWith<ParentProgressBrief> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParentProgressBriefCopyWith<$Res> {
  factory $ParentProgressBriefCopyWith(
    ParentProgressBrief value,
    $Res Function(ParentProgressBrief) then,
  ) = _$ParentProgressBriefCopyWithImpl<$Res, ParentProgressBrief>;
  @useResult
  $Res call({int completedLessons, int totalLessons, int progressPercent});
}

/// @nodoc
class _$ParentProgressBriefCopyWithImpl<$Res, $Val extends ParentProgressBrief>
    implements $ParentProgressBriefCopyWith<$Res> {
  _$ParentProgressBriefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParentProgressBrief
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
abstract class _$$ParentProgressBriefImplCopyWith<$Res>
    implements $ParentProgressBriefCopyWith<$Res> {
  factory _$$ParentProgressBriefImplCopyWith(
    _$ParentProgressBriefImpl value,
    $Res Function(_$ParentProgressBriefImpl) then,
  ) = __$$ParentProgressBriefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int completedLessons, int totalLessons, int progressPercent});
}

/// @nodoc
class __$$ParentProgressBriefImplCopyWithImpl<$Res>
    extends _$ParentProgressBriefCopyWithImpl<$Res, _$ParentProgressBriefImpl>
    implements _$$ParentProgressBriefImplCopyWith<$Res> {
  __$$ParentProgressBriefImplCopyWithImpl(
    _$ParentProgressBriefImpl _value,
    $Res Function(_$ParentProgressBriefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParentProgressBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? completedLessons = null,
    Object? totalLessons = null,
    Object? progressPercent = null,
  }) {
    return _then(
      _$ParentProgressBriefImpl(
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
class _$ParentProgressBriefImpl implements _ParentProgressBrief {
  const _$ParentProgressBriefImpl({
    required this.completedLessons,
    required this.totalLessons,
    required this.progressPercent,
  });

  factory _$ParentProgressBriefImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParentProgressBriefImplFromJson(json);

  @override
  final int completedLessons;
  @override
  final int totalLessons;
  @override
  final int progressPercent;

  @override
  String toString() {
    return 'ParentProgressBrief(completedLessons: $completedLessons, totalLessons: $totalLessons, progressPercent: $progressPercent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParentProgressBriefImpl &&
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

  /// Create a copy of ParentProgressBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParentProgressBriefImplCopyWith<_$ParentProgressBriefImpl> get copyWith =>
      __$$ParentProgressBriefImplCopyWithImpl<_$ParentProgressBriefImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ParentProgressBriefImplToJson(this);
  }
}

abstract class _ParentProgressBrief implements ParentProgressBrief {
  const factory _ParentProgressBrief({
    required final int completedLessons,
    required final int totalLessons,
    required final int progressPercent,
  }) = _$ParentProgressBriefImpl;

  factory _ParentProgressBrief.fromJson(Map<String, dynamic> json) =
      _$ParentProgressBriefImpl.fromJson;

  @override
  int get completedLessons;
  @override
  int get totalLessons;
  @override
  int get progressPercent;

  /// Create a copy of ParentProgressBrief
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParentProgressBriefImplCopyWith<_$ParentProgressBriefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ParentChildListItem _$ParentChildListItemFromJson(Map<String, dynamic> json) {
  return _ParentChildListItem.fromJson(json);
}

/// @nodoc
mixin _$ParentChildListItem {
  ParentChildBrief get child => throw _privateConstructorUsedError;
  int get coursesCount => throw _privateConstructorUsedError;
  int get overallProgressPercent => throw _privateConstructorUsedError;
  int get pendingReview => throw _privateConstructorUsedError;
  int get needsWork => throw _privateConstructorUsedError;

  /// Serializes this ParentChildListItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParentChildListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParentChildListItemCopyWith<ParentChildListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParentChildListItemCopyWith<$Res> {
  factory $ParentChildListItemCopyWith(
    ParentChildListItem value,
    $Res Function(ParentChildListItem) then,
  ) = _$ParentChildListItemCopyWithImpl<$Res, ParentChildListItem>;
  @useResult
  $Res call({
    ParentChildBrief child,
    int coursesCount,
    int overallProgressPercent,
    int pendingReview,
    int needsWork,
  });

  $ParentChildBriefCopyWith<$Res> get child;
}

/// @nodoc
class _$ParentChildListItemCopyWithImpl<$Res, $Val extends ParentChildListItem>
    implements $ParentChildListItemCopyWith<$Res> {
  _$ParentChildListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParentChildListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? child = null,
    Object? coursesCount = null,
    Object? overallProgressPercent = null,
    Object? pendingReview = null,
    Object? needsWork = null,
  }) {
    return _then(
      _value.copyWith(
            child: null == child
                ? _value.child
                : child // ignore: cast_nullable_to_non_nullable
                      as ParentChildBrief,
            coursesCount: null == coursesCount
                ? _value.coursesCount
                : coursesCount // ignore: cast_nullable_to_non_nullable
                      as int,
            overallProgressPercent: null == overallProgressPercent
                ? _value.overallProgressPercent
                : overallProgressPercent // ignore: cast_nullable_to_non_nullable
                      as int,
            pendingReview: null == pendingReview
                ? _value.pendingReview
                : pendingReview // ignore: cast_nullable_to_non_nullable
                      as int,
            needsWork: null == needsWork
                ? _value.needsWork
                : needsWork // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of ParentChildListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ParentChildBriefCopyWith<$Res> get child {
    return $ParentChildBriefCopyWith<$Res>(_value.child, (value) {
      return _then(_value.copyWith(child: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ParentChildListItemImplCopyWith<$Res>
    implements $ParentChildListItemCopyWith<$Res> {
  factory _$$ParentChildListItemImplCopyWith(
    _$ParentChildListItemImpl value,
    $Res Function(_$ParentChildListItemImpl) then,
  ) = __$$ParentChildListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ParentChildBrief child,
    int coursesCount,
    int overallProgressPercent,
    int pendingReview,
    int needsWork,
  });

  @override
  $ParentChildBriefCopyWith<$Res> get child;
}

/// @nodoc
class __$$ParentChildListItemImplCopyWithImpl<$Res>
    extends _$ParentChildListItemCopyWithImpl<$Res, _$ParentChildListItemImpl>
    implements _$$ParentChildListItemImplCopyWith<$Res> {
  __$$ParentChildListItemImplCopyWithImpl(
    _$ParentChildListItemImpl _value,
    $Res Function(_$ParentChildListItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParentChildListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? child = null,
    Object? coursesCount = null,
    Object? overallProgressPercent = null,
    Object? pendingReview = null,
    Object? needsWork = null,
  }) {
    return _then(
      _$ParentChildListItemImpl(
        child: null == child
            ? _value.child
            : child // ignore: cast_nullable_to_non_nullable
                  as ParentChildBrief,
        coursesCount: null == coursesCount
            ? _value.coursesCount
            : coursesCount // ignore: cast_nullable_to_non_nullable
                  as int,
        overallProgressPercent: null == overallProgressPercent
            ? _value.overallProgressPercent
            : overallProgressPercent // ignore: cast_nullable_to_non_nullable
                  as int,
        pendingReview: null == pendingReview
            ? _value.pendingReview
            : pendingReview // ignore: cast_nullable_to_non_nullable
                  as int,
        needsWork: null == needsWork
            ? _value.needsWork
            : needsWork // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ParentChildListItemImpl implements _ParentChildListItem {
  const _$ParentChildListItemImpl({
    required this.child,
    required this.coursesCount,
    required this.overallProgressPercent,
    required this.pendingReview,
    required this.needsWork,
  });

  factory _$ParentChildListItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParentChildListItemImplFromJson(json);

  @override
  final ParentChildBrief child;
  @override
  final int coursesCount;
  @override
  final int overallProgressPercent;
  @override
  final int pendingReview;
  @override
  final int needsWork;

  @override
  String toString() {
    return 'ParentChildListItem(child: $child, coursesCount: $coursesCount, overallProgressPercent: $overallProgressPercent, pendingReview: $pendingReview, needsWork: $needsWork)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParentChildListItemImpl &&
            (identical(other.child, child) || other.child == child) &&
            (identical(other.coursesCount, coursesCount) ||
                other.coursesCount == coursesCount) &&
            (identical(other.overallProgressPercent, overallProgressPercent) ||
                other.overallProgressPercent == overallProgressPercent) &&
            (identical(other.pendingReview, pendingReview) ||
                other.pendingReview == pendingReview) &&
            (identical(other.needsWork, needsWork) ||
                other.needsWork == needsWork));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    child,
    coursesCount,
    overallProgressPercent,
    pendingReview,
    needsWork,
  );

  /// Create a copy of ParentChildListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParentChildListItemImplCopyWith<_$ParentChildListItemImpl> get copyWith =>
      __$$ParentChildListItemImplCopyWithImpl<_$ParentChildListItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ParentChildListItemImplToJson(this);
  }
}

abstract class _ParentChildListItem implements ParentChildListItem {
  const factory _ParentChildListItem({
    required final ParentChildBrief child,
    required final int coursesCount,
    required final int overallProgressPercent,
    required final int pendingReview,
    required final int needsWork,
  }) = _$ParentChildListItemImpl;

  factory _ParentChildListItem.fromJson(Map<String, dynamic> json) =
      _$ParentChildListItemImpl.fromJson;

  @override
  ParentChildBrief get child;
  @override
  int get coursesCount;
  @override
  int get overallProgressPercent;
  @override
  int get pendingReview;
  @override
  int get needsWork;

  /// Create a copy of ParentChildListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParentChildListItemImplCopyWith<_$ParentChildListItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ParentChildCourseProgress _$ParentChildCourseProgressFromJson(
  Map<String, dynamic> json,
) {
  return _ParentChildCourseProgress.fromJson(json);
}

/// @nodoc
mixin _$ParentChildCourseProgress {
  ParentCourseBrief get course => throw _privateConstructorUsedError;
  String get enrollmentStatus => throw _privateConstructorUsedError;
  ParentProgressBrief get progress => throw _privateConstructorUsedError;

  /// Serializes this ParentChildCourseProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParentChildCourseProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParentChildCourseProgressCopyWith<ParentChildCourseProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParentChildCourseProgressCopyWith<$Res> {
  factory $ParentChildCourseProgressCopyWith(
    ParentChildCourseProgress value,
    $Res Function(ParentChildCourseProgress) then,
  ) = _$ParentChildCourseProgressCopyWithImpl<$Res, ParentChildCourseProgress>;
  @useResult
  $Res call({
    ParentCourseBrief course,
    String enrollmentStatus,
    ParentProgressBrief progress,
  });

  $ParentCourseBriefCopyWith<$Res> get course;
  $ParentProgressBriefCopyWith<$Res> get progress;
}

/// @nodoc
class _$ParentChildCourseProgressCopyWithImpl<
  $Res,
  $Val extends ParentChildCourseProgress
>
    implements $ParentChildCourseProgressCopyWith<$Res> {
  _$ParentChildCourseProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParentChildCourseProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? course = null,
    Object? enrollmentStatus = null,
    Object? progress = null,
  }) {
    return _then(
      _value.copyWith(
            course: null == course
                ? _value.course
                : course // ignore: cast_nullable_to_non_nullable
                      as ParentCourseBrief,
            enrollmentStatus: null == enrollmentStatus
                ? _value.enrollmentStatus
                : enrollmentStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            progress: null == progress
                ? _value.progress
                : progress // ignore: cast_nullable_to_non_nullable
                      as ParentProgressBrief,
          )
          as $Val,
    );
  }

  /// Create a copy of ParentChildCourseProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ParentCourseBriefCopyWith<$Res> get course {
    return $ParentCourseBriefCopyWith<$Res>(_value.course, (value) {
      return _then(_value.copyWith(course: value) as $Val);
    });
  }

  /// Create a copy of ParentChildCourseProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ParentProgressBriefCopyWith<$Res> get progress {
    return $ParentProgressBriefCopyWith<$Res>(_value.progress, (value) {
      return _then(_value.copyWith(progress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ParentChildCourseProgressImplCopyWith<$Res>
    implements $ParentChildCourseProgressCopyWith<$Res> {
  factory _$$ParentChildCourseProgressImplCopyWith(
    _$ParentChildCourseProgressImpl value,
    $Res Function(_$ParentChildCourseProgressImpl) then,
  ) = __$$ParentChildCourseProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ParentCourseBrief course,
    String enrollmentStatus,
    ParentProgressBrief progress,
  });

  @override
  $ParentCourseBriefCopyWith<$Res> get course;
  @override
  $ParentProgressBriefCopyWith<$Res> get progress;
}

/// @nodoc
class __$$ParentChildCourseProgressImplCopyWithImpl<$Res>
    extends
        _$ParentChildCourseProgressCopyWithImpl<
          $Res,
          _$ParentChildCourseProgressImpl
        >
    implements _$$ParentChildCourseProgressImplCopyWith<$Res> {
  __$$ParentChildCourseProgressImplCopyWithImpl(
    _$ParentChildCourseProgressImpl _value,
    $Res Function(_$ParentChildCourseProgressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParentChildCourseProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? course = null,
    Object? enrollmentStatus = null,
    Object? progress = null,
  }) {
    return _then(
      _$ParentChildCourseProgressImpl(
        course: null == course
            ? _value.course
            : course // ignore: cast_nullable_to_non_nullable
                  as ParentCourseBrief,
        enrollmentStatus: null == enrollmentStatus
            ? _value.enrollmentStatus
            : enrollmentStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        progress: null == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as ParentProgressBrief,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ParentChildCourseProgressImpl implements _ParentChildCourseProgress {
  const _$ParentChildCourseProgressImpl({
    required this.course,
    required this.enrollmentStatus,
    required this.progress,
  });

  factory _$ParentChildCourseProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParentChildCourseProgressImplFromJson(json);

  @override
  final ParentCourseBrief course;
  @override
  final String enrollmentStatus;
  @override
  final ParentProgressBrief progress;

  @override
  String toString() {
    return 'ParentChildCourseProgress(course: $course, enrollmentStatus: $enrollmentStatus, progress: $progress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParentChildCourseProgressImpl &&
            (identical(other.course, course) || other.course == course) &&
            (identical(other.enrollmentStatus, enrollmentStatus) ||
                other.enrollmentStatus == enrollmentStatus) &&
            (identical(other.progress, progress) ||
                other.progress == progress));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, course, enrollmentStatus, progress);

  /// Create a copy of ParentChildCourseProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParentChildCourseProgressImplCopyWith<_$ParentChildCourseProgressImpl>
  get copyWith =>
      __$$ParentChildCourseProgressImplCopyWithImpl<
        _$ParentChildCourseProgressImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ParentChildCourseProgressImplToJson(this);
  }
}

abstract class _ParentChildCourseProgress implements ParentChildCourseProgress {
  const factory _ParentChildCourseProgress({
    required final ParentCourseBrief course,
    required final String enrollmentStatus,
    required final ParentProgressBrief progress,
  }) = _$ParentChildCourseProgressImpl;

  factory _ParentChildCourseProgress.fromJson(Map<String, dynamic> json) =
      _$ParentChildCourseProgressImpl.fromJson;

  @override
  ParentCourseBrief get course;
  @override
  String get enrollmentStatus;
  @override
  ParentProgressBrief get progress;

  /// Create a copy of ParentChildCourseProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParentChildCourseProgressImplCopyWith<_$ParentChildCourseProgressImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ParentChildOverview _$ParentChildOverviewFromJson(Map<String, dynamic> json) {
  return _ParentChildOverview.fromJson(json);
}

/// @nodoc
mixin _$ParentChildOverview {
  ParentChildBrief get child => throw _privateConstructorUsedError;
  List<ParentChildCourseProgress> get courses =>
      throw _privateConstructorUsedError;

  /// Serializes this ParentChildOverview to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParentChildOverview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParentChildOverviewCopyWith<ParentChildOverview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParentChildOverviewCopyWith<$Res> {
  factory $ParentChildOverviewCopyWith(
    ParentChildOverview value,
    $Res Function(ParentChildOverview) then,
  ) = _$ParentChildOverviewCopyWithImpl<$Res, ParentChildOverview>;
  @useResult
  $Res call({ParentChildBrief child, List<ParentChildCourseProgress> courses});

  $ParentChildBriefCopyWith<$Res> get child;
}

/// @nodoc
class _$ParentChildOverviewCopyWithImpl<$Res, $Val extends ParentChildOverview>
    implements $ParentChildOverviewCopyWith<$Res> {
  _$ParentChildOverviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParentChildOverview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? child = null, Object? courses = null}) {
    return _then(
      _value.copyWith(
            child: null == child
                ? _value.child
                : child // ignore: cast_nullable_to_non_nullable
                      as ParentChildBrief,
            courses: null == courses
                ? _value.courses
                : courses // ignore: cast_nullable_to_non_nullable
                      as List<ParentChildCourseProgress>,
          )
          as $Val,
    );
  }

  /// Create a copy of ParentChildOverview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ParentChildBriefCopyWith<$Res> get child {
    return $ParentChildBriefCopyWith<$Res>(_value.child, (value) {
      return _then(_value.copyWith(child: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ParentChildOverviewImplCopyWith<$Res>
    implements $ParentChildOverviewCopyWith<$Res> {
  factory _$$ParentChildOverviewImplCopyWith(
    _$ParentChildOverviewImpl value,
    $Res Function(_$ParentChildOverviewImpl) then,
  ) = __$$ParentChildOverviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ParentChildBrief child, List<ParentChildCourseProgress> courses});

  @override
  $ParentChildBriefCopyWith<$Res> get child;
}

/// @nodoc
class __$$ParentChildOverviewImplCopyWithImpl<$Res>
    extends _$ParentChildOverviewCopyWithImpl<$Res, _$ParentChildOverviewImpl>
    implements _$$ParentChildOverviewImplCopyWith<$Res> {
  __$$ParentChildOverviewImplCopyWithImpl(
    _$ParentChildOverviewImpl _value,
    $Res Function(_$ParentChildOverviewImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParentChildOverview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? child = null, Object? courses = null}) {
    return _then(
      _$ParentChildOverviewImpl(
        child: null == child
            ? _value.child
            : child // ignore: cast_nullable_to_non_nullable
                  as ParentChildBrief,
        courses: null == courses
            ? _value._courses
            : courses // ignore: cast_nullable_to_non_nullable
                  as List<ParentChildCourseProgress>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ParentChildOverviewImpl implements _ParentChildOverview {
  const _$ParentChildOverviewImpl({
    required this.child,
    final List<ParentChildCourseProgress> courses = const [],
  }) : _courses = courses;

  factory _$ParentChildOverviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParentChildOverviewImplFromJson(json);

  @override
  final ParentChildBrief child;
  final List<ParentChildCourseProgress> _courses;
  @override
  @JsonKey()
  List<ParentChildCourseProgress> get courses {
    if (_courses is EqualUnmodifiableListView) return _courses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_courses);
  }

  @override
  String toString() {
    return 'ParentChildOverview(child: $child, courses: $courses)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParentChildOverviewImpl &&
            (identical(other.child, child) || other.child == child) &&
            const DeepCollectionEquality().equals(other._courses, _courses));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    child,
    const DeepCollectionEquality().hash(_courses),
  );

  /// Create a copy of ParentChildOverview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParentChildOverviewImplCopyWith<_$ParentChildOverviewImpl> get copyWith =>
      __$$ParentChildOverviewImplCopyWithImpl<_$ParentChildOverviewImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ParentChildOverviewImplToJson(this);
  }
}

abstract class _ParentChildOverview implements ParentChildOverview {
  const factory _ParentChildOverview({
    required final ParentChildBrief child,
    final List<ParentChildCourseProgress> courses,
  }) = _$ParentChildOverviewImpl;

  factory _ParentChildOverview.fromJson(Map<String, dynamic> json) =
      _$ParentChildOverviewImpl.fromJson;

  @override
  ParentChildBrief get child;
  @override
  List<ParentChildCourseProgress> get courses;

  /// Create a copy of ParentChildOverview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParentChildOverviewImplCopyWith<_$ParentChildOverviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ParentLessonProgressItem _$ParentLessonProgressItemFromJson(
  Map<String, dynamic> json,
) {
  return _ParentLessonProgressItem.fromJson(json);
}

/// @nodoc
mixin _$ParentLessonProgressItem {
  int get lessonId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this ParentLessonProgressItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParentLessonProgressItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParentLessonProgressItemCopyWith<ParentLessonProgressItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParentLessonProgressItemCopyWith<$Res> {
  factory $ParentLessonProgressItemCopyWith(
    ParentLessonProgressItem value,
    $Res Function(ParentLessonProgressItem) then,
  ) = _$ParentLessonProgressItemCopyWithImpl<$Res, ParentLessonProgressItem>;
  @useResult
  $Res call({int lessonId, String title, String status, DateTime? completedAt});
}

/// @nodoc
class _$ParentLessonProgressItemCopyWithImpl<
  $Res,
  $Val extends ParentLessonProgressItem
>
    implements $ParentLessonProgressItemCopyWith<$Res> {
  _$ParentLessonProgressItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParentLessonProgressItem
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
abstract class _$$ParentLessonProgressItemImplCopyWith<$Res>
    implements $ParentLessonProgressItemCopyWith<$Res> {
  factory _$$ParentLessonProgressItemImplCopyWith(
    _$ParentLessonProgressItemImpl value,
    $Res Function(_$ParentLessonProgressItemImpl) then,
  ) = __$$ParentLessonProgressItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int lessonId, String title, String status, DateTime? completedAt});
}

/// @nodoc
class __$$ParentLessonProgressItemImplCopyWithImpl<$Res>
    extends
        _$ParentLessonProgressItemCopyWithImpl<
          $Res,
          _$ParentLessonProgressItemImpl
        >
    implements _$$ParentLessonProgressItemImplCopyWith<$Res> {
  __$$ParentLessonProgressItemImplCopyWithImpl(
    _$ParentLessonProgressItemImpl _value,
    $Res Function(_$ParentLessonProgressItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParentLessonProgressItem
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
      _$ParentLessonProgressItemImpl(
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
class _$ParentLessonProgressItemImpl implements _ParentLessonProgressItem {
  const _$ParentLessonProgressItemImpl({
    required this.lessonId,
    required this.title,
    required this.status,
    this.completedAt,
  });

  factory _$ParentLessonProgressItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParentLessonProgressItemImplFromJson(json);

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
    return 'ParentLessonProgressItem(lessonId: $lessonId, title: $title, status: $status, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParentLessonProgressItemImpl &&
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

  /// Create a copy of ParentLessonProgressItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParentLessonProgressItemImplCopyWith<_$ParentLessonProgressItemImpl>
  get copyWith =>
      __$$ParentLessonProgressItemImplCopyWithImpl<
        _$ParentLessonProgressItemImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ParentLessonProgressItemImplToJson(this);
  }
}

abstract class _ParentLessonProgressItem implements ParentLessonProgressItem {
  const factory _ParentLessonProgressItem({
    required final int lessonId,
    required final String title,
    required final String status,
    final DateTime? completedAt,
  }) = _$ParentLessonProgressItemImpl;

  factory _ParentLessonProgressItem.fromJson(Map<String, dynamic> json) =
      _$ParentLessonProgressItemImpl.fromJson;

  @override
  int get lessonId;
  @override
  String get title;
  @override
  String get status;
  @override
  DateTime? get completedAt;

  /// Create a copy of ParentLessonProgressItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParentLessonProgressItemImplCopyWith<_$ParentLessonProgressItemImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ParentAssignmentFeedbackItem _$ParentAssignmentFeedbackItemFromJson(
  Map<String, dynamic> json,
) {
  return _ParentAssignmentFeedbackItem.fromJson(json);
}

/// @nodoc
mixin _$ParentAssignmentFeedbackItem {
  int get assignmentId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get lessonTitle => throw _privateConstructorUsedError;
  String get assignmentType => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int? get score => throw _privateConstructorUsedError;
  String? get teacherFeedback => throw _privateConstructorUsedError;
  DateTime? get submittedAt => throw _privateConstructorUsedError;
  DateTime? get checkedAt => throw _privateConstructorUsedError;
  int? get quizAttempts => throw _privateConstructorUsedError;
  int? get quizBestPercent => throw _privateConstructorUsedError;
  bool? get quizPassed => throw _privateConstructorUsedError;

  /// Serializes this ParentAssignmentFeedbackItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParentAssignmentFeedbackItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParentAssignmentFeedbackItemCopyWith<ParentAssignmentFeedbackItem>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParentAssignmentFeedbackItemCopyWith<$Res> {
  factory $ParentAssignmentFeedbackItemCopyWith(
    ParentAssignmentFeedbackItem value,
    $Res Function(ParentAssignmentFeedbackItem) then,
  ) =
      _$ParentAssignmentFeedbackItemCopyWithImpl<
        $Res,
        ParentAssignmentFeedbackItem
      >;
  @useResult
  $Res call({
    int assignmentId,
    String title,
    String lessonTitle,
    String assignmentType,
    int points,
    String status,
    int? score,
    String? teacherFeedback,
    DateTime? submittedAt,
    DateTime? checkedAt,
    int? quizAttempts,
    int? quizBestPercent,
    bool? quizPassed,
  });
}

/// @nodoc
class _$ParentAssignmentFeedbackItemCopyWithImpl<
  $Res,
  $Val extends ParentAssignmentFeedbackItem
>
    implements $ParentAssignmentFeedbackItemCopyWith<$Res> {
  _$ParentAssignmentFeedbackItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParentAssignmentFeedbackItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assignmentId = null,
    Object? title = null,
    Object? lessonTitle = null,
    Object? assignmentType = null,
    Object? points = null,
    Object? status = null,
    Object? score = freezed,
    Object? teacherFeedback = freezed,
    Object? submittedAt = freezed,
    Object? checkedAt = freezed,
    Object? quizAttempts = freezed,
    Object? quizBestPercent = freezed,
    Object? quizPassed = freezed,
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
            assignmentType: null == assignmentType
                ? _value.assignmentType
                : assignmentType // ignore: cast_nullable_to_non_nullable
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
            quizAttempts: freezed == quizAttempts
                ? _value.quizAttempts
                : quizAttempts // ignore: cast_nullable_to_non_nullable
                      as int?,
            quizBestPercent: freezed == quizBestPercent
                ? _value.quizBestPercent
                : quizBestPercent // ignore: cast_nullable_to_non_nullable
                      as int?,
            quizPassed: freezed == quizPassed
                ? _value.quizPassed
                : quizPassed // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ParentAssignmentFeedbackItemImplCopyWith<$Res>
    implements $ParentAssignmentFeedbackItemCopyWith<$Res> {
  factory _$$ParentAssignmentFeedbackItemImplCopyWith(
    _$ParentAssignmentFeedbackItemImpl value,
    $Res Function(_$ParentAssignmentFeedbackItemImpl) then,
  ) = __$$ParentAssignmentFeedbackItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int assignmentId,
    String title,
    String lessonTitle,
    String assignmentType,
    int points,
    String status,
    int? score,
    String? teacherFeedback,
    DateTime? submittedAt,
    DateTime? checkedAt,
    int? quizAttempts,
    int? quizBestPercent,
    bool? quizPassed,
  });
}

/// @nodoc
class __$$ParentAssignmentFeedbackItemImplCopyWithImpl<$Res>
    extends
        _$ParentAssignmentFeedbackItemCopyWithImpl<
          $Res,
          _$ParentAssignmentFeedbackItemImpl
        >
    implements _$$ParentAssignmentFeedbackItemImplCopyWith<$Res> {
  __$$ParentAssignmentFeedbackItemImplCopyWithImpl(
    _$ParentAssignmentFeedbackItemImpl _value,
    $Res Function(_$ParentAssignmentFeedbackItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParentAssignmentFeedbackItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assignmentId = null,
    Object? title = null,
    Object? lessonTitle = null,
    Object? assignmentType = null,
    Object? points = null,
    Object? status = null,
    Object? score = freezed,
    Object? teacherFeedback = freezed,
    Object? submittedAt = freezed,
    Object? checkedAt = freezed,
    Object? quizAttempts = freezed,
    Object? quizBestPercent = freezed,
    Object? quizPassed = freezed,
  }) {
    return _then(
      _$ParentAssignmentFeedbackItemImpl(
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
        assignmentType: null == assignmentType
            ? _value.assignmentType
            : assignmentType // ignore: cast_nullable_to_non_nullable
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
        quizAttempts: freezed == quizAttempts
            ? _value.quizAttempts
            : quizAttempts // ignore: cast_nullable_to_non_nullable
                  as int?,
        quizBestPercent: freezed == quizBestPercent
            ? _value.quizBestPercent
            : quizBestPercent // ignore: cast_nullable_to_non_nullable
                  as int?,
        quizPassed: freezed == quizPassed
            ? _value.quizPassed
            : quizPassed // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ParentAssignmentFeedbackItemImpl
    implements _ParentAssignmentFeedbackItem {
  const _$ParentAssignmentFeedbackItemImpl({
    required this.assignmentId,
    required this.title,
    required this.lessonTitle,
    required this.assignmentType,
    required this.points,
    required this.status,
    this.score,
    this.teacherFeedback,
    this.submittedAt,
    this.checkedAt,
    this.quizAttempts,
    this.quizBestPercent,
    this.quizPassed,
  });

  factory _$ParentAssignmentFeedbackItemImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$ParentAssignmentFeedbackItemImplFromJson(json);

  @override
  final int assignmentId;
  @override
  final String title;
  @override
  final String lessonTitle;
  @override
  final String assignmentType;
  @override
  final int points;
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
  final int? quizAttempts;
  @override
  final int? quizBestPercent;
  @override
  final bool? quizPassed;

  @override
  String toString() {
    return 'ParentAssignmentFeedbackItem(assignmentId: $assignmentId, title: $title, lessonTitle: $lessonTitle, assignmentType: $assignmentType, points: $points, status: $status, score: $score, teacherFeedback: $teacherFeedback, submittedAt: $submittedAt, checkedAt: $checkedAt, quizAttempts: $quizAttempts, quizBestPercent: $quizBestPercent, quizPassed: $quizPassed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParentAssignmentFeedbackItemImpl &&
            (identical(other.assignmentId, assignmentId) ||
                other.assignmentId == assignmentId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.lessonTitle, lessonTitle) ||
                other.lessonTitle == lessonTitle) &&
            (identical(other.assignmentType, assignmentType) ||
                other.assignmentType == assignmentType) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.teacherFeedback, teacherFeedback) ||
                other.teacherFeedback == teacherFeedback) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.checkedAt, checkedAt) ||
                other.checkedAt == checkedAt) &&
            (identical(other.quizAttempts, quizAttempts) ||
                other.quizAttempts == quizAttempts) &&
            (identical(other.quizBestPercent, quizBestPercent) ||
                other.quizBestPercent == quizBestPercent) &&
            (identical(other.quizPassed, quizPassed) ||
                other.quizPassed == quizPassed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    assignmentId,
    title,
    lessonTitle,
    assignmentType,
    points,
    status,
    score,
    teacherFeedback,
    submittedAt,
    checkedAt,
    quizAttempts,
    quizBestPercent,
    quizPassed,
  );

  /// Create a copy of ParentAssignmentFeedbackItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParentAssignmentFeedbackItemImplCopyWith<
    _$ParentAssignmentFeedbackItemImpl
  >
  get copyWith =>
      __$$ParentAssignmentFeedbackItemImplCopyWithImpl<
        _$ParentAssignmentFeedbackItemImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ParentAssignmentFeedbackItemImplToJson(this);
  }
}

abstract class _ParentAssignmentFeedbackItem
    implements ParentAssignmentFeedbackItem {
  const factory _ParentAssignmentFeedbackItem({
    required final int assignmentId,
    required final String title,
    required final String lessonTitle,
    required final String assignmentType,
    required final int points,
    required final String status,
    final int? score,
    final String? teacherFeedback,
    final DateTime? submittedAt,
    final DateTime? checkedAt,
    final int? quizAttempts,
    final int? quizBestPercent,
    final bool? quizPassed,
  }) = _$ParentAssignmentFeedbackItemImpl;

  factory _ParentAssignmentFeedbackItem.fromJson(Map<String, dynamic> json) =
      _$ParentAssignmentFeedbackItemImpl.fromJson;

  @override
  int get assignmentId;
  @override
  String get title;
  @override
  String get lessonTitle;
  @override
  String get assignmentType;
  @override
  int get points;
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
  int? get quizAttempts;
  @override
  int? get quizBestPercent;
  @override
  bool? get quizPassed;

  /// Create a copy of ParentAssignmentFeedbackItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParentAssignmentFeedbackItemImplCopyWith<
    _$ParentAssignmentFeedbackItemImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

ParentChildCourseDetail _$ParentChildCourseDetailFromJson(
  Map<String, dynamic> json,
) {
  return _ParentChildCourseDetail.fromJson(json);
}

/// @nodoc
mixin _$ParentChildCourseDetail {
  ParentChildBrief get child => throw _privateConstructorUsedError;
  ParentCourseBrief get course => throw _privateConstructorUsedError;
  ParentProgressBrief get progress => throw _privateConstructorUsedError;
  List<ParentLessonProgressItem> get lessons =>
      throw _privateConstructorUsedError;
  List<ParentAssignmentFeedbackItem> get assignments =>
      throw _privateConstructorUsedError;

  /// Serializes this ParentChildCourseDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParentChildCourseDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParentChildCourseDetailCopyWith<ParentChildCourseDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParentChildCourseDetailCopyWith<$Res> {
  factory $ParentChildCourseDetailCopyWith(
    ParentChildCourseDetail value,
    $Res Function(ParentChildCourseDetail) then,
  ) = _$ParentChildCourseDetailCopyWithImpl<$Res, ParentChildCourseDetail>;
  @useResult
  $Res call({
    ParentChildBrief child,
    ParentCourseBrief course,
    ParentProgressBrief progress,
    List<ParentLessonProgressItem> lessons,
    List<ParentAssignmentFeedbackItem> assignments,
  });

  $ParentChildBriefCopyWith<$Res> get child;
  $ParentCourseBriefCopyWith<$Res> get course;
  $ParentProgressBriefCopyWith<$Res> get progress;
}

/// @nodoc
class _$ParentChildCourseDetailCopyWithImpl<
  $Res,
  $Val extends ParentChildCourseDetail
>
    implements $ParentChildCourseDetailCopyWith<$Res> {
  _$ParentChildCourseDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParentChildCourseDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? child = null,
    Object? course = null,
    Object? progress = null,
    Object? lessons = null,
    Object? assignments = null,
  }) {
    return _then(
      _value.copyWith(
            child: null == child
                ? _value.child
                : child // ignore: cast_nullable_to_non_nullable
                      as ParentChildBrief,
            course: null == course
                ? _value.course
                : course // ignore: cast_nullable_to_non_nullable
                      as ParentCourseBrief,
            progress: null == progress
                ? _value.progress
                : progress // ignore: cast_nullable_to_non_nullable
                      as ParentProgressBrief,
            lessons: null == lessons
                ? _value.lessons
                : lessons // ignore: cast_nullable_to_non_nullable
                      as List<ParentLessonProgressItem>,
            assignments: null == assignments
                ? _value.assignments
                : assignments // ignore: cast_nullable_to_non_nullable
                      as List<ParentAssignmentFeedbackItem>,
          )
          as $Val,
    );
  }

  /// Create a copy of ParentChildCourseDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ParentChildBriefCopyWith<$Res> get child {
    return $ParentChildBriefCopyWith<$Res>(_value.child, (value) {
      return _then(_value.copyWith(child: value) as $Val);
    });
  }

  /// Create a copy of ParentChildCourseDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ParentCourseBriefCopyWith<$Res> get course {
    return $ParentCourseBriefCopyWith<$Res>(_value.course, (value) {
      return _then(_value.copyWith(course: value) as $Val);
    });
  }

  /// Create a copy of ParentChildCourseDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ParentProgressBriefCopyWith<$Res> get progress {
    return $ParentProgressBriefCopyWith<$Res>(_value.progress, (value) {
      return _then(_value.copyWith(progress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ParentChildCourseDetailImplCopyWith<$Res>
    implements $ParentChildCourseDetailCopyWith<$Res> {
  factory _$$ParentChildCourseDetailImplCopyWith(
    _$ParentChildCourseDetailImpl value,
    $Res Function(_$ParentChildCourseDetailImpl) then,
  ) = __$$ParentChildCourseDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ParentChildBrief child,
    ParentCourseBrief course,
    ParentProgressBrief progress,
    List<ParentLessonProgressItem> lessons,
    List<ParentAssignmentFeedbackItem> assignments,
  });

  @override
  $ParentChildBriefCopyWith<$Res> get child;
  @override
  $ParentCourseBriefCopyWith<$Res> get course;
  @override
  $ParentProgressBriefCopyWith<$Res> get progress;
}

/// @nodoc
class __$$ParentChildCourseDetailImplCopyWithImpl<$Res>
    extends
        _$ParentChildCourseDetailCopyWithImpl<
          $Res,
          _$ParentChildCourseDetailImpl
        >
    implements _$$ParentChildCourseDetailImplCopyWith<$Res> {
  __$$ParentChildCourseDetailImplCopyWithImpl(
    _$ParentChildCourseDetailImpl _value,
    $Res Function(_$ParentChildCourseDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParentChildCourseDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? child = null,
    Object? course = null,
    Object? progress = null,
    Object? lessons = null,
    Object? assignments = null,
  }) {
    return _then(
      _$ParentChildCourseDetailImpl(
        child: null == child
            ? _value.child
            : child // ignore: cast_nullable_to_non_nullable
                  as ParentChildBrief,
        course: null == course
            ? _value.course
            : course // ignore: cast_nullable_to_non_nullable
                  as ParentCourseBrief,
        progress: null == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as ParentProgressBrief,
        lessons: null == lessons
            ? _value._lessons
            : lessons // ignore: cast_nullable_to_non_nullable
                  as List<ParentLessonProgressItem>,
        assignments: null == assignments
            ? _value._assignments
            : assignments // ignore: cast_nullable_to_non_nullable
                  as List<ParentAssignmentFeedbackItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ParentChildCourseDetailImpl implements _ParentChildCourseDetail {
  const _$ParentChildCourseDetailImpl({
    required this.child,
    required this.course,
    required this.progress,
    final List<ParentLessonProgressItem> lessons = const [],
    final List<ParentAssignmentFeedbackItem> assignments = const [],
  }) : _lessons = lessons,
       _assignments = assignments;

  factory _$ParentChildCourseDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParentChildCourseDetailImplFromJson(json);

  @override
  final ParentChildBrief child;
  @override
  final ParentCourseBrief course;
  @override
  final ParentProgressBrief progress;
  final List<ParentLessonProgressItem> _lessons;
  @override
  @JsonKey()
  List<ParentLessonProgressItem> get lessons {
    if (_lessons is EqualUnmodifiableListView) return _lessons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lessons);
  }

  final List<ParentAssignmentFeedbackItem> _assignments;
  @override
  @JsonKey()
  List<ParentAssignmentFeedbackItem> get assignments {
    if (_assignments is EqualUnmodifiableListView) return _assignments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_assignments);
  }

  @override
  String toString() {
    return 'ParentChildCourseDetail(child: $child, course: $course, progress: $progress, lessons: $lessons, assignments: $assignments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParentChildCourseDetailImpl &&
            (identical(other.child, child) || other.child == child) &&
            (identical(other.course, course) || other.course == course) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            const DeepCollectionEquality().equals(other._lessons, _lessons) &&
            const DeepCollectionEquality().equals(
              other._assignments,
              _assignments,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    child,
    course,
    progress,
    const DeepCollectionEquality().hash(_lessons),
    const DeepCollectionEquality().hash(_assignments),
  );

  /// Create a copy of ParentChildCourseDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParentChildCourseDetailImplCopyWith<_$ParentChildCourseDetailImpl>
  get copyWith =>
      __$$ParentChildCourseDetailImplCopyWithImpl<
        _$ParentChildCourseDetailImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ParentChildCourseDetailImplToJson(this);
  }
}

abstract class _ParentChildCourseDetail implements ParentChildCourseDetail {
  const factory _ParentChildCourseDetail({
    required final ParentChildBrief child,
    required final ParentCourseBrief course,
    required final ParentProgressBrief progress,
    final List<ParentLessonProgressItem> lessons,
    final List<ParentAssignmentFeedbackItem> assignments,
  }) = _$ParentChildCourseDetailImpl;

  factory _ParentChildCourseDetail.fromJson(Map<String, dynamic> json) =
      _$ParentChildCourseDetailImpl.fromJson;

  @override
  ParentChildBrief get child;
  @override
  ParentCourseBrief get course;
  @override
  ParentProgressBrief get progress;
  @override
  List<ParentLessonProgressItem> get lessons;
  @override
  List<ParentAssignmentFeedbackItem> get assignments;

  /// Create a copy of ParentChildCourseDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParentChildCourseDetailImplCopyWith<_$ParentChildCourseDetailImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ParentActivityItem _$ParentActivityItemFromJson(Map<String, dynamic> json) {
  return _ParentActivityItem.fromJson(json);
}

/// @nodoc
mixin _$ParentActivityItem {
  String get type => throw _privateConstructorUsedError;
  DateTime get at => throw _privateConstructorUsedError;
  String get courseTitle => throw _privateConstructorUsedError;
  String get lessonTitle => throw _privateConstructorUsedError;
  String? get assignmentTitle => throw _privateConstructorUsedError;
  int? get score => throw _privateConstructorUsedError;
  int? get points => throw _privateConstructorUsedError;

  /// Serializes this ParentActivityItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParentActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParentActivityItemCopyWith<ParentActivityItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParentActivityItemCopyWith<$Res> {
  factory $ParentActivityItemCopyWith(
    ParentActivityItem value,
    $Res Function(ParentActivityItem) then,
  ) = _$ParentActivityItemCopyWithImpl<$Res, ParentActivityItem>;
  @useResult
  $Res call({
    String type,
    DateTime at,
    String courseTitle,
    String lessonTitle,
    String? assignmentTitle,
    int? score,
    int? points,
  });
}

/// @nodoc
class _$ParentActivityItemCopyWithImpl<$Res, $Val extends ParentActivityItem>
    implements $ParentActivityItemCopyWith<$Res> {
  _$ParentActivityItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParentActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? at = null,
    Object? courseTitle = null,
    Object? lessonTitle = null,
    Object? assignmentTitle = freezed,
    Object? score = freezed,
    Object? points = freezed,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            at: null == at
                ? _value.at
                : at // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            courseTitle: null == courseTitle
                ? _value.courseTitle
                : courseTitle // ignore: cast_nullable_to_non_nullable
                      as String,
            lessonTitle: null == lessonTitle
                ? _value.lessonTitle
                : lessonTitle // ignore: cast_nullable_to_non_nullable
                      as String,
            assignmentTitle: freezed == assignmentTitle
                ? _value.assignmentTitle
                : assignmentTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            score: freezed == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int?,
            points: freezed == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ParentActivityItemImplCopyWith<$Res>
    implements $ParentActivityItemCopyWith<$Res> {
  factory _$$ParentActivityItemImplCopyWith(
    _$ParentActivityItemImpl value,
    $Res Function(_$ParentActivityItemImpl) then,
  ) = __$$ParentActivityItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String type,
    DateTime at,
    String courseTitle,
    String lessonTitle,
    String? assignmentTitle,
    int? score,
    int? points,
  });
}

/// @nodoc
class __$$ParentActivityItemImplCopyWithImpl<$Res>
    extends _$ParentActivityItemCopyWithImpl<$Res, _$ParentActivityItemImpl>
    implements _$$ParentActivityItemImplCopyWith<$Res> {
  __$$ParentActivityItemImplCopyWithImpl(
    _$ParentActivityItemImpl _value,
    $Res Function(_$ParentActivityItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParentActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? at = null,
    Object? courseTitle = null,
    Object? lessonTitle = null,
    Object? assignmentTitle = freezed,
    Object? score = freezed,
    Object? points = freezed,
  }) {
    return _then(
      _$ParentActivityItemImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        at: null == at
            ? _value.at
            : at // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        courseTitle: null == courseTitle
            ? _value.courseTitle
            : courseTitle // ignore: cast_nullable_to_non_nullable
                  as String,
        lessonTitle: null == lessonTitle
            ? _value.lessonTitle
            : lessonTitle // ignore: cast_nullable_to_non_nullable
                  as String,
        assignmentTitle: freezed == assignmentTitle
            ? _value.assignmentTitle
            : assignmentTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        score: freezed == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int?,
        points: freezed == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ParentActivityItemImpl implements _ParentActivityItem {
  const _$ParentActivityItemImpl({
    required this.type,
    required this.at,
    required this.courseTitle,
    required this.lessonTitle,
    this.assignmentTitle,
    this.score,
    this.points,
  });

  factory _$ParentActivityItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParentActivityItemImplFromJson(json);

  @override
  final String type;
  @override
  final DateTime at;
  @override
  final String courseTitle;
  @override
  final String lessonTitle;
  @override
  final String? assignmentTitle;
  @override
  final int? score;
  @override
  final int? points;

  @override
  String toString() {
    return 'ParentActivityItem(type: $type, at: $at, courseTitle: $courseTitle, lessonTitle: $lessonTitle, assignmentTitle: $assignmentTitle, score: $score, points: $points)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParentActivityItemImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.at, at) || other.at == at) &&
            (identical(other.courseTitle, courseTitle) ||
                other.courseTitle == courseTitle) &&
            (identical(other.lessonTitle, lessonTitle) ||
                other.lessonTitle == lessonTitle) &&
            (identical(other.assignmentTitle, assignmentTitle) ||
                other.assignmentTitle == assignmentTitle) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.points, points) || other.points == points));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    at,
    courseTitle,
    lessonTitle,
    assignmentTitle,
    score,
    points,
  );

  /// Create a copy of ParentActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParentActivityItemImplCopyWith<_$ParentActivityItemImpl> get copyWith =>
      __$$ParentActivityItemImplCopyWithImpl<_$ParentActivityItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ParentActivityItemImplToJson(this);
  }
}

abstract class _ParentActivityItem implements ParentActivityItem {
  const factory _ParentActivityItem({
    required final String type,
    required final DateTime at,
    required final String courseTitle,
    required final String lessonTitle,
    final String? assignmentTitle,
    final int? score,
    final int? points,
  }) = _$ParentActivityItemImpl;

  factory _ParentActivityItem.fromJson(Map<String, dynamic> json) =
      _$ParentActivityItemImpl.fromJson;

  @override
  String get type;
  @override
  DateTime get at;
  @override
  String get courseTitle;
  @override
  String get lessonTitle;
  @override
  String? get assignmentTitle;
  @override
  int? get score;
  @override
  int? get points;

  /// Create a copy of ParentActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParentActivityItemImplCopyWith<_$ParentActivityItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ParentActivitySummary _$ParentActivitySummaryFromJson(
  Map<String, dynamic> json,
) {
  return _ParentActivitySummary.fromJson(json);
}

/// @nodoc
mixin _$ParentActivitySummary {
  ParentChildBrief get child => throw _privateConstructorUsedError;
  List<ParentActivityItem> get items => throw _privateConstructorUsedError;

  /// Serializes this ParentActivitySummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParentActivitySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParentActivitySummaryCopyWith<ParentActivitySummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParentActivitySummaryCopyWith<$Res> {
  factory $ParentActivitySummaryCopyWith(
    ParentActivitySummary value,
    $Res Function(ParentActivitySummary) then,
  ) = _$ParentActivitySummaryCopyWithImpl<$Res, ParentActivitySummary>;
  @useResult
  $Res call({ParentChildBrief child, List<ParentActivityItem> items});

  $ParentChildBriefCopyWith<$Res> get child;
}

/// @nodoc
class _$ParentActivitySummaryCopyWithImpl<
  $Res,
  $Val extends ParentActivitySummary
>
    implements $ParentActivitySummaryCopyWith<$Res> {
  _$ParentActivitySummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParentActivitySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? child = null, Object? items = null}) {
    return _then(
      _value.copyWith(
            child: null == child
                ? _value.child
                : child // ignore: cast_nullable_to_non_nullable
                      as ParentChildBrief,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<ParentActivityItem>,
          )
          as $Val,
    );
  }

  /// Create a copy of ParentActivitySummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ParentChildBriefCopyWith<$Res> get child {
    return $ParentChildBriefCopyWith<$Res>(_value.child, (value) {
      return _then(_value.copyWith(child: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ParentActivitySummaryImplCopyWith<$Res>
    implements $ParentActivitySummaryCopyWith<$Res> {
  factory _$$ParentActivitySummaryImplCopyWith(
    _$ParentActivitySummaryImpl value,
    $Res Function(_$ParentActivitySummaryImpl) then,
  ) = __$$ParentActivitySummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ParentChildBrief child, List<ParentActivityItem> items});

  @override
  $ParentChildBriefCopyWith<$Res> get child;
}

/// @nodoc
class __$$ParentActivitySummaryImplCopyWithImpl<$Res>
    extends
        _$ParentActivitySummaryCopyWithImpl<$Res, _$ParentActivitySummaryImpl>
    implements _$$ParentActivitySummaryImplCopyWith<$Res> {
  __$$ParentActivitySummaryImplCopyWithImpl(
    _$ParentActivitySummaryImpl _value,
    $Res Function(_$ParentActivitySummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParentActivitySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? child = null, Object? items = null}) {
    return _then(
      _$ParentActivitySummaryImpl(
        child: null == child
            ? _value.child
            : child // ignore: cast_nullable_to_non_nullable
                  as ParentChildBrief,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<ParentActivityItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ParentActivitySummaryImpl implements _ParentActivitySummary {
  const _$ParentActivitySummaryImpl({
    required this.child,
    final List<ParentActivityItem> items = const [],
  }) : _items = items;

  factory _$ParentActivitySummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParentActivitySummaryImplFromJson(json);

  @override
  final ParentChildBrief child;
  final List<ParentActivityItem> _items;
  @override
  @JsonKey()
  List<ParentActivityItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'ParentActivitySummary(child: $child, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParentActivitySummaryImpl &&
            (identical(other.child, child) || other.child == child) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    child,
    const DeepCollectionEquality().hash(_items),
  );

  /// Create a copy of ParentActivitySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParentActivitySummaryImplCopyWith<_$ParentActivitySummaryImpl>
  get copyWith =>
      __$$ParentActivitySummaryImplCopyWithImpl<_$ParentActivitySummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ParentActivitySummaryImplToJson(this);
  }
}

abstract class _ParentActivitySummary implements ParentActivitySummary {
  const factory _ParentActivitySummary({
    required final ParentChildBrief child,
    final List<ParentActivityItem> items,
  }) = _$ParentActivitySummaryImpl;

  factory _ParentActivitySummary.fromJson(Map<String, dynamic> json) =
      _$ParentActivitySummaryImpl.fromJson;

  @override
  ParentChildBrief get child;
  @override
  List<ParentActivityItem> get items;

  /// Create a copy of ParentActivitySummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParentActivitySummaryImplCopyWith<_$ParentActivitySummaryImpl>
  get copyWith => throw _privateConstructorUsedError;
}
