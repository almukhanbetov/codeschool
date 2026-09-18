// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'academy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AcademyCourseCard _$AcademyCourseCardFromJson(Map<String, dynamic> json) {
  return _AcademyCourseCard.fromJson(json);
}

/// @nodoc
mixin _$AcademyCourseCard {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String? get shortDescription => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get difficulty => throw _privateConstructorUsedError;
  String get audience => throw _privateConstructorUsedError;
  int get totalLessons => throw _privateConstructorUsedError;
  bool get enrolled => throw _privateConstructorUsedError;

  /// Serializes this AcademyCourseCard to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AcademyCourseCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AcademyCourseCardCopyWith<AcademyCourseCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AcademyCourseCardCopyWith<$Res> {
  factory $AcademyCourseCardCopyWith(
    AcademyCourseCard value,
    $Res Function(AcademyCourseCard) then,
  ) = _$AcademyCourseCardCopyWithImpl<$Res, AcademyCourseCard>;
  @useResult
  $Res call({
    int id,
    String title,
    String slug,
    String? shortDescription,
    String? description,
    String? imageUrl,
    String? difficulty,
    String audience,
    int totalLessons,
    bool enrolled,
  });
}

/// @nodoc
class _$AcademyCourseCardCopyWithImpl<$Res, $Val extends AcademyCourseCard>
    implements $AcademyCourseCardCopyWith<$Res> {
  _$AcademyCourseCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AcademyCourseCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? slug = null,
    Object? shortDescription = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? difficulty = freezed,
    Object? audience = null,
    Object? totalLessons = null,
    Object? enrolled = null,
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
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            difficulty: freezed == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as String?,
            audience: null == audience
                ? _value.audience
                : audience // ignore: cast_nullable_to_non_nullable
                      as String,
            totalLessons: null == totalLessons
                ? _value.totalLessons
                : totalLessons // ignore: cast_nullable_to_non_nullable
                      as int,
            enrolled: null == enrolled
                ? _value.enrolled
                : enrolled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AcademyCourseCardImplCopyWith<$Res>
    implements $AcademyCourseCardCopyWith<$Res> {
  factory _$$AcademyCourseCardImplCopyWith(
    _$AcademyCourseCardImpl value,
    $Res Function(_$AcademyCourseCardImpl) then,
  ) = __$$AcademyCourseCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    String slug,
    String? shortDescription,
    String? description,
    String? imageUrl,
    String? difficulty,
    String audience,
    int totalLessons,
    bool enrolled,
  });
}

/// @nodoc
class __$$AcademyCourseCardImplCopyWithImpl<$Res>
    extends _$AcademyCourseCardCopyWithImpl<$Res, _$AcademyCourseCardImpl>
    implements _$$AcademyCourseCardImplCopyWith<$Res> {
  __$$AcademyCourseCardImplCopyWithImpl(
    _$AcademyCourseCardImpl _value,
    $Res Function(_$AcademyCourseCardImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AcademyCourseCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? slug = null,
    Object? shortDescription = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? difficulty = freezed,
    Object? audience = null,
    Object? totalLessons = null,
    Object? enrolled = null,
  }) {
    return _then(
      _$AcademyCourseCardImpl(
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
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        difficulty: freezed == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as String?,
        audience: null == audience
            ? _value.audience
            : audience // ignore: cast_nullable_to_non_nullable
                  as String,
        totalLessons: null == totalLessons
            ? _value.totalLessons
            : totalLessons // ignore: cast_nullable_to_non_nullable
                  as int,
        enrolled: null == enrolled
            ? _value.enrolled
            : enrolled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AcademyCourseCardImpl implements _AcademyCourseCard {
  const _$AcademyCourseCardImpl({
    required this.id,
    required this.title,
    required this.slug,
    this.shortDescription,
    this.description,
    this.imageUrl,
    this.difficulty,
    required this.audience,
    required this.totalLessons,
    required this.enrolled,
  });

  factory _$AcademyCourseCardImpl.fromJson(Map<String, dynamic> json) =>
      _$$AcademyCourseCardImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String slug;
  @override
  final String? shortDescription;
  @override
  final String? description;
  @override
  final String? imageUrl;
  @override
  final String? difficulty;
  @override
  final String audience;
  @override
  final int totalLessons;
  @override
  final bool enrolled;

  @override
  String toString() {
    return 'AcademyCourseCard(id: $id, title: $title, slug: $slug, shortDescription: $shortDescription, description: $description, imageUrl: $imageUrl, difficulty: $difficulty, audience: $audience, totalLessons: $totalLessons, enrolled: $enrolled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AcademyCourseCardImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.shortDescription, shortDescription) ||
                other.shortDescription == shortDescription) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.audience, audience) ||
                other.audience == audience) &&
            (identical(other.totalLessons, totalLessons) ||
                other.totalLessons == totalLessons) &&
            (identical(other.enrolled, enrolled) ||
                other.enrolled == enrolled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    slug,
    shortDescription,
    description,
    imageUrl,
    difficulty,
    audience,
    totalLessons,
    enrolled,
  );

  /// Create a copy of AcademyCourseCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AcademyCourseCardImplCopyWith<_$AcademyCourseCardImpl> get copyWith =>
      __$$AcademyCourseCardImplCopyWithImpl<_$AcademyCourseCardImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AcademyCourseCardImplToJson(this);
  }
}

abstract class _AcademyCourseCard implements AcademyCourseCard {
  const factory _AcademyCourseCard({
    required final int id,
    required final String title,
    required final String slug,
    final String? shortDescription,
    final String? description,
    final String? imageUrl,
    final String? difficulty,
    required final String audience,
    required final int totalLessons,
    required final bool enrolled,
  }) = _$AcademyCourseCardImpl;

  factory _AcademyCourseCard.fromJson(Map<String, dynamic> json) =
      _$AcademyCourseCardImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String get slug;
  @override
  String? get shortDescription;
  @override
  String? get description;
  @override
  String? get imageUrl;
  @override
  String? get difficulty;
  @override
  String get audience;
  @override
  int get totalLessons;
  @override
  bool get enrolled;

  /// Create a copy of AcademyCourseCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AcademyCourseCardImplCopyWith<_$AcademyCourseCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AcademyMyCourse _$AcademyMyCourseFromJson(Map<String, dynamic> json) {
  return _AcademyMyCourse.fromJson(json);
}

/// @nodoc
mixin _$AcademyMyCourse {
  int get courseId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String? get shortDescription => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get difficulty => throw _privateConstructorUsedError;
  String get enrollmentStatus => throw _privateConstructorUsedError;
  DateTime get enrolledAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  int get completedLessons => throw _privateConstructorUsedError;
  int get totalLessons => throw _privateConstructorUsedError;
  int get progressPercent => throw _privateConstructorUsedError;
  bool get courseCompleted => throw _privateConstructorUsedError;
  bool get certificateEligible => throw _privateConstructorUsedError;

  /// Serializes this AcademyMyCourse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AcademyMyCourse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AcademyMyCourseCopyWith<AcademyMyCourse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AcademyMyCourseCopyWith<$Res> {
  factory $AcademyMyCourseCopyWith(
    AcademyMyCourse value,
    $Res Function(AcademyMyCourse) then,
  ) = _$AcademyMyCourseCopyWithImpl<$Res, AcademyMyCourse>;
  @useResult
  $Res call({
    int courseId,
    String title,
    String slug,
    String? shortDescription,
    String? imageUrl,
    String? difficulty,
    String enrollmentStatus,
    DateTime enrolledAt,
    DateTime? completedAt,
    int completedLessons,
    int totalLessons,
    int progressPercent,
    bool courseCompleted,
    bool certificateEligible,
  });
}

/// @nodoc
class _$AcademyMyCourseCopyWithImpl<$Res, $Val extends AcademyMyCourse>
    implements $AcademyMyCourseCopyWith<$Res> {
  _$AcademyMyCourseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AcademyMyCourse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? courseId = null,
    Object? title = null,
    Object? slug = null,
    Object? shortDescription = freezed,
    Object? imageUrl = freezed,
    Object? difficulty = freezed,
    Object? enrollmentStatus = null,
    Object? enrolledAt = null,
    Object? completedAt = freezed,
    Object? completedLessons = null,
    Object? totalLessons = null,
    Object? progressPercent = null,
    Object? courseCompleted = null,
    Object? certificateEligible = null,
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
            difficulty: freezed == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as String?,
            enrollmentStatus: null == enrollmentStatus
                ? _value.enrollmentStatus
                : enrollmentStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            enrolledAt: null == enrolledAt
                ? _value.enrolledAt
                : enrolledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
            courseCompleted: null == courseCompleted
                ? _value.courseCompleted
                : courseCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            certificateEligible: null == certificateEligible
                ? _value.certificateEligible
                : certificateEligible // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AcademyMyCourseImplCopyWith<$Res>
    implements $AcademyMyCourseCopyWith<$Res> {
  factory _$$AcademyMyCourseImplCopyWith(
    _$AcademyMyCourseImpl value,
    $Res Function(_$AcademyMyCourseImpl) then,
  ) = __$$AcademyMyCourseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int courseId,
    String title,
    String slug,
    String? shortDescription,
    String? imageUrl,
    String? difficulty,
    String enrollmentStatus,
    DateTime enrolledAt,
    DateTime? completedAt,
    int completedLessons,
    int totalLessons,
    int progressPercent,
    bool courseCompleted,
    bool certificateEligible,
  });
}

/// @nodoc
class __$$AcademyMyCourseImplCopyWithImpl<$Res>
    extends _$AcademyMyCourseCopyWithImpl<$Res, _$AcademyMyCourseImpl>
    implements _$$AcademyMyCourseImplCopyWith<$Res> {
  __$$AcademyMyCourseImplCopyWithImpl(
    _$AcademyMyCourseImpl _value,
    $Res Function(_$AcademyMyCourseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AcademyMyCourse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? courseId = null,
    Object? title = null,
    Object? slug = null,
    Object? shortDescription = freezed,
    Object? imageUrl = freezed,
    Object? difficulty = freezed,
    Object? enrollmentStatus = null,
    Object? enrolledAt = null,
    Object? completedAt = freezed,
    Object? completedLessons = null,
    Object? totalLessons = null,
    Object? progressPercent = null,
    Object? courseCompleted = null,
    Object? certificateEligible = null,
  }) {
    return _then(
      _$AcademyMyCourseImpl(
        courseId: null == courseId
            ? _value.courseId
            : courseId // ignore: cast_nullable_to_non_nullable
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
        difficulty: freezed == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as String?,
        enrollmentStatus: null == enrollmentStatus
            ? _value.enrollmentStatus
            : enrollmentStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        enrolledAt: null == enrolledAt
            ? _value.enrolledAt
            : enrolledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
        courseCompleted: null == courseCompleted
            ? _value.courseCompleted
            : courseCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        certificateEligible: null == certificateEligible
            ? _value.certificateEligible
            : certificateEligible // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AcademyMyCourseImpl implements _AcademyMyCourse {
  const _$AcademyMyCourseImpl({
    required this.courseId,
    required this.title,
    required this.slug,
    this.shortDescription,
    this.imageUrl,
    this.difficulty,
    required this.enrollmentStatus,
    required this.enrolledAt,
    this.completedAt,
    required this.completedLessons,
    required this.totalLessons,
    required this.progressPercent,
    required this.courseCompleted,
    required this.certificateEligible,
  });

  factory _$AcademyMyCourseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AcademyMyCourseImplFromJson(json);

  @override
  final int courseId;
  @override
  final String title;
  @override
  final String slug;
  @override
  final String? shortDescription;
  @override
  final String? imageUrl;
  @override
  final String? difficulty;
  @override
  final String enrollmentStatus;
  @override
  final DateTime enrolledAt;
  @override
  final DateTime? completedAt;
  @override
  final int completedLessons;
  @override
  final int totalLessons;
  @override
  final int progressPercent;
  @override
  final bool courseCompleted;
  @override
  final bool certificateEligible;

  @override
  String toString() {
    return 'AcademyMyCourse(courseId: $courseId, title: $title, slug: $slug, shortDescription: $shortDescription, imageUrl: $imageUrl, difficulty: $difficulty, enrollmentStatus: $enrollmentStatus, enrolledAt: $enrolledAt, completedAt: $completedAt, completedLessons: $completedLessons, totalLessons: $totalLessons, progressPercent: $progressPercent, courseCompleted: $courseCompleted, certificateEligible: $certificateEligible)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AcademyMyCourseImpl &&
            (identical(other.courseId, courseId) ||
                other.courseId == courseId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.shortDescription, shortDescription) ||
                other.shortDescription == shortDescription) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.enrollmentStatus, enrollmentStatus) ||
                other.enrollmentStatus == enrollmentStatus) &&
            (identical(other.enrolledAt, enrolledAt) ||
                other.enrolledAt == enrolledAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.completedLessons, completedLessons) ||
                other.completedLessons == completedLessons) &&
            (identical(other.totalLessons, totalLessons) ||
                other.totalLessons == totalLessons) &&
            (identical(other.progressPercent, progressPercent) ||
                other.progressPercent == progressPercent) &&
            (identical(other.courseCompleted, courseCompleted) ||
                other.courseCompleted == courseCompleted) &&
            (identical(other.certificateEligible, certificateEligible) ||
                other.certificateEligible == certificateEligible));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    courseId,
    title,
    slug,
    shortDescription,
    imageUrl,
    difficulty,
    enrollmentStatus,
    enrolledAt,
    completedAt,
    completedLessons,
    totalLessons,
    progressPercent,
    courseCompleted,
    certificateEligible,
  );

  /// Create a copy of AcademyMyCourse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AcademyMyCourseImplCopyWith<_$AcademyMyCourseImpl> get copyWith =>
      __$$AcademyMyCourseImplCopyWithImpl<_$AcademyMyCourseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AcademyMyCourseImplToJson(this);
  }
}

abstract class _AcademyMyCourse implements AcademyMyCourse {
  const factory _AcademyMyCourse({
    required final int courseId,
    required final String title,
    required final String slug,
    final String? shortDescription,
    final String? imageUrl,
    final String? difficulty,
    required final String enrollmentStatus,
    required final DateTime enrolledAt,
    final DateTime? completedAt,
    required final int completedLessons,
    required final int totalLessons,
    required final int progressPercent,
    required final bool courseCompleted,
    required final bool certificateEligible,
  }) = _$AcademyMyCourseImpl;

  factory _AcademyMyCourse.fromJson(Map<String, dynamic> json) =
      _$AcademyMyCourseImpl.fromJson;

  @override
  int get courseId;
  @override
  String get title;
  @override
  String get slug;
  @override
  String? get shortDescription;
  @override
  String? get imageUrl;
  @override
  String? get difficulty;
  @override
  String get enrollmentStatus;
  @override
  DateTime get enrolledAt;
  @override
  DateTime? get completedAt;
  @override
  int get completedLessons;
  @override
  int get totalLessons;
  @override
  int get progressPercent;
  @override
  bool get courseCompleted;
  @override
  bool get certificateEligible;

  /// Create a copy of AcademyMyCourse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AcademyMyCourseImplCopyWith<_$AcademyMyCourseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AcademyDashboard _$AcademyDashboardFromJson(Map<String, dynamic> json) {
  return _AcademyDashboard.fromJson(json);
}

/// @nodoc
mixin _$AcademyDashboard {
  int get coursesInProgress => throw _privateConstructorUsedError;
  int get coursesCompleted => throw _privateConstructorUsedError;
  int get totalCourses => throw _privateConstructorUsedError;
  int get overallPercent => throw _privateConstructorUsedError;
  List<AcademyMyCourse> get courses => throw _privateConstructorUsedError;

  /// Serializes this AcademyDashboard to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AcademyDashboard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AcademyDashboardCopyWith<AcademyDashboard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AcademyDashboardCopyWith<$Res> {
  factory $AcademyDashboardCopyWith(
    AcademyDashboard value,
    $Res Function(AcademyDashboard) then,
  ) = _$AcademyDashboardCopyWithImpl<$Res, AcademyDashboard>;
  @useResult
  $Res call({
    int coursesInProgress,
    int coursesCompleted,
    int totalCourses,
    int overallPercent,
    List<AcademyMyCourse> courses,
  });
}

/// @nodoc
class _$AcademyDashboardCopyWithImpl<$Res, $Val extends AcademyDashboard>
    implements $AcademyDashboardCopyWith<$Res> {
  _$AcademyDashboardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AcademyDashboard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? coursesInProgress = null,
    Object? coursesCompleted = null,
    Object? totalCourses = null,
    Object? overallPercent = null,
    Object? courses = null,
  }) {
    return _then(
      _value.copyWith(
            coursesInProgress: null == coursesInProgress
                ? _value.coursesInProgress
                : coursesInProgress // ignore: cast_nullable_to_non_nullable
                      as int,
            coursesCompleted: null == coursesCompleted
                ? _value.coursesCompleted
                : coursesCompleted // ignore: cast_nullable_to_non_nullable
                      as int,
            totalCourses: null == totalCourses
                ? _value.totalCourses
                : totalCourses // ignore: cast_nullable_to_non_nullable
                      as int,
            overallPercent: null == overallPercent
                ? _value.overallPercent
                : overallPercent // ignore: cast_nullable_to_non_nullable
                      as int,
            courses: null == courses
                ? _value.courses
                : courses // ignore: cast_nullable_to_non_nullable
                      as List<AcademyMyCourse>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AcademyDashboardImplCopyWith<$Res>
    implements $AcademyDashboardCopyWith<$Res> {
  factory _$$AcademyDashboardImplCopyWith(
    _$AcademyDashboardImpl value,
    $Res Function(_$AcademyDashboardImpl) then,
  ) = __$$AcademyDashboardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int coursesInProgress,
    int coursesCompleted,
    int totalCourses,
    int overallPercent,
    List<AcademyMyCourse> courses,
  });
}

/// @nodoc
class __$$AcademyDashboardImplCopyWithImpl<$Res>
    extends _$AcademyDashboardCopyWithImpl<$Res, _$AcademyDashboardImpl>
    implements _$$AcademyDashboardImplCopyWith<$Res> {
  __$$AcademyDashboardImplCopyWithImpl(
    _$AcademyDashboardImpl _value,
    $Res Function(_$AcademyDashboardImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AcademyDashboard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? coursesInProgress = null,
    Object? coursesCompleted = null,
    Object? totalCourses = null,
    Object? overallPercent = null,
    Object? courses = null,
  }) {
    return _then(
      _$AcademyDashboardImpl(
        coursesInProgress: null == coursesInProgress
            ? _value.coursesInProgress
            : coursesInProgress // ignore: cast_nullable_to_non_nullable
                  as int,
        coursesCompleted: null == coursesCompleted
            ? _value.coursesCompleted
            : coursesCompleted // ignore: cast_nullable_to_non_nullable
                  as int,
        totalCourses: null == totalCourses
            ? _value.totalCourses
            : totalCourses // ignore: cast_nullable_to_non_nullable
                  as int,
        overallPercent: null == overallPercent
            ? _value.overallPercent
            : overallPercent // ignore: cast_nullable_to_non_nullable
                  as int,
        courses: null == courses
            ? _value._courses
            : courses // ignore: cast_nullable_to_non_nullable
                  as List<AcademyMyCourse>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AcademyDashboardImpl implements _AcademyDashboard {
  const _$AcademyDashboardImpl({
    required this.coursesInProgress,
    required this.coursesCompleted,
    required this.totalCourses,
    required this.overallPercent,
    final List<AcademyMyCourse> courses = const [],
  }) : _courses = courses;

  factory _$AcademyDashboardImpl.fromJson(Map<String, dynamic> json) =>
      _$$AcademyDashboardImplFromJson(json);

  @override
  final int coursesInProgress;
  @override
  final int coursesCompleted;
  @override
  final int totalCourses;
  @override
  final int overallPercent;
  final List<AcademyMyCourse> _courses;
  @override
  @JsonKey()
  List<AcademyMyCourse> get courses {
    if (_courses is EqualUnmodifiableListView) return _courses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_courses);
  }

  @override
  String toString() {
    return 'AcademyDashboard(coursesInProgress: $coursesInProgress, coursesCompleted: $coursesCompleted, totalCourses: $totalCourses, overallPercent: $overallPercent, courses: $courses)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AcademyDashboardImpl &&
            (identical(other.coursesInProgress, coursesInProgress) ||
                other.coursesInProgress == coursesInProgress) &&
            (identical(other.coursesCompleted, coursesCompleted) ||
                other.coursesCompleted == coursesCompleted) &&
            (identical(other.totalCourses, totalCourses) ||
                other.totalCourses == totalCourses) &&
            (identical(other.overallPercent, overallPercent) ||
                other.overallPercent == overallPercent) &&
            const DeepCollectionEquality().equals(other._courses, _courses));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    coursesInProgress,
    coursesCompleted,
    totalCourses,
    overallPercent,
    const DeepCollectionEquality().hash(_courses),
  );

  /// Create a copy of AcademyDashboard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AcademyDashboardImplCopyWith<_$AcademyDashboardImpl> get copyWith =>
      __$$AcademyDashboardImplCopyWithImpl<_$AcademyDashboardImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AcademyDashboardImplToJson(this);
  }
}

abstract class _AcademyDashboard implements AcademyDashboard {
  const factory _AcademyDashboard({
    required final int coursesInProgress,
    required final int coursesCompleted,
    required final int totalCourses,
    required final int overallPercent,
    final List<AcademyMyCourse> courses,
  }) = _$AcademyDashboardImpl;

  factory _AcademyDashboard.fromJson(Map<String, dynamic> json) =
      _$AcademyDashboardImpl.fromJson;

  @override
  int get coursesInProgress;
  @override
  int get coursesCompleted;
  @override
  int get totalCourses;
  @override
  int get overallPercent;
  @override
  List<AcademyMyCourse> get courses;

  /// Create a copy of AcademyDashboard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AcademyDashboardImplCopyWith<_$AcademyDashboardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
