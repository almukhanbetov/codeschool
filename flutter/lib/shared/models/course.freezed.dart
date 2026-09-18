// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'course.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Course _$CourseFromJson(Map<String, dynamic> json) {
  return _Course.fromJson(json);
}

/// @nodoc
mixin _$Course {
  int get id => throw _privateConstructorUsedError;
  int get levelId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get shortDescription => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  int? get ageFrom => throw _privateConstructorUsedError;
  int? get ageTo => throw _privateConstructorUsedError;
  int? get durationLessons => throw _privateConstructorUsedError;
  int? get projectsCount => throw _privateConstructorUsedError;
  String? get difficulty => throw _privateConstructorUsedError;
  String get audience => throw _privateConstructorUsedError;

  /// Serializes this Course to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CourseCopyWith<Course> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CourseCopyWith<$Res> {
  factory $CourseCopyWith(Course value, $Res Function(Course) then) =
      _$CourseCopyWithImpl<$Res, Course>;
  @useResult
  $Res call({
    int id,
    int levelId,
    String title,
    String slug,
    String? description,
    String? shortDescription,
    String? imageUrl,
    int? ageFrom,
    int? ageTo,
    int? durationLessons,
    int? projectsCount,
    String? difficulty,
    String audience,
  });
}

/// @nodoc
class _$CourseCopyWithImpl<$Res, $Val extends Course>
    implements $CourseCopyWith<$Res> {
  _$CourseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? levelId = null,
    Object? title = null,
    Object? slug = null,
    Object? description = freezed,
    Object? shortDescription = freezed,
    Object? imageUrl = freezed,
    Object? ageFrom = freezed,
    Object? ageTo = freezed,
    Object? durationLessons = freezed,
    Object? projectsCount = freezed,
    Object? difficulty = freezed,
    Object? audience = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            levelId: null == levelId
                ? _value.levelId
                : levelId // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            slug: null == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            shortDescription: freezed == shortDescription
                ? _value.shortDescription
                : shortDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            ageFrom: freezed == ageFrom
                ? _value.ageFrom
                : ageFrom // ignore: cast_nullable_to_non_nullable
                      as int?,
            ageTo: freezed == ageTo
                ? _value.ageTo
                : ageTo // ignore: cast_nullable_to_non_nullable
                      as int?,
            durationLessons: freezed == durationLessons
                ? _value.durationLessons
                : durationLessons // ignore: cast_nullable_to_non_nullable
                      as int?,
            projectsCount: freezed == projectsCount
                ? _value.projectsCount
                : projectsCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            difficulty: freezed == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as String?,
            audience: null == audience
                ? _value.audience
                : audience // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CourseImplCopyWith<$Res> implements $CourseCopyWith<$Res> {
  factory _$$CourseImplCopyWith(
    _$CourseImpl value,
    $Res Function(_$CourseImpl) then,
  ) = __$$CourseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int levelId,
    String title,
    String slug,
    String? description,
    String? shortDescription,
    String? imageUrl,
    int? ageFrom,
    int? ageTo,
    int? durationLessons,
    int? projectsCount,
    String? difficulty,
    String audience,
  });
}

/// @nodoc
class __$$CourseImplCopyWithImpl<$Res>
    extends _$CourseCopyWithImpl<$Res, _$CourseImpl>
    implements _$$CourseImplCopyWith<$Res> {
  __$$CourseImplCopyWithImpl(
    _$CourseImpl _value,
    $Res Function(_$CourseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? levelId = null,
    Object? title = null,
    Object? slug = null,
    Object? description = freezed,
    Object? shortDescription = freezed,
    Object? imageUrl = freezed,
    Object? ageFrom = freezed,
    Object? ageTo = freezed,
    Object? durationLessons = freezed,
    Object? projectsCount = freezed,
    Object? difficulty = freezed,
    Object? audience = null,
  }) {
    return _then(
      _$CourseImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        levelId: null == levelId
            ? _value.levelId
            : levelId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        shortDescription: freezed == shortDescription
            ? _value.shortDescription
            : shortDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        ageFrom: freezed == ageFrom
            ? _value.ageFrom
            : ageFrom // ignore: cast_nullable_to_non_nullable
                  as int?,
        ageTo: freezed == ageTo
            ? _value.ageTo
            : ageTo // ignore: cast_nullable_to_non_nullable
                  as int?,
        durationLessons: freezed == durationLessons
            ? _value.durationLessons
            : durationLessons // ignore: cast_nullable_to_non_nullable
                  as int?,
        projectsCount: freezed == projectsCount
            ? _value.projectsCount
            : projectsCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        difficulty: freezed == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as String?,
        audience: null == audience
            ? _value.audience
            : audience // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CourseImpl implements _Course {
  const _$CourseImpl({
    required this.id,
    required this.levelId,
    required this.title,
    required this.slug,
    this.description,
    this.shortDescription,
    this.imageUrl,
    this.ageFrom,
    this.ageTo,
    this.durationLessons,
    this.projectsCount,
    this.difficulty,
    required this.audience,
  });

  factory _$CourseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CourseImplFromJson(json);

  @override
  final int id;
  @override
  final int levelId;
  @override
  final String title;
  @override
  final String slug;
  @override
  final String? description;
  @override
  final String? shortDescription;
  @override
  final String? imageUrl;
  @override
  final int? ageFrom;
  @override
  final int? ageTo;
  @override
  final int? durationLessons;
  @override
  final int? projectsCount;
  @override
  final String? difficulty;
  @override
  final String audience;

  @override
  String toString() {
    return 'Course(id: $id, levelId: $levelId, title: $title, slug: $slug, description: $description, shortDescription: $shortDescription, imageUrl: $imageUrl, ageFrom: $ageFrom, ageTo: $ageTo, durationLessons: $durationLessons, projectsCount: $projectsCount, difficulty: $difficulty, audience: $audience)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CourseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.levelId, levelId) || other.levelId == levelId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.shortDescription, shortDescription) ||
                other.shortDescription == shortDescription) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.ageFrom, ageFrom) || other.ageFrom == ageFrom) &&
            (identical(other.ageTo, ageTo) || other.ageTo == ageTo) &&
            (identical(other.durationLessons, durationLessons) ||
                other.durationLessons == durationLessons) &&
            (identical(other.projectsCount, projectsCount) ||
                other.projectsCount == projectsCount) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.audience, audience) ||
                other.audience == audience));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    levelId,
    title,
    slug,
    description,
    shortDescription,
    imageUrl,
    ageFrom,
    ageTo,
    durationLessons,
    projectsCount,
    difficulty,
    audience,
  );

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CourseImplCopyWith<_$CourseImpl> get copyWith =>
      __$$CourseImplCopyWithImpl<_$CourseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CourseImplToJson(this);
  }
}

abstract class _Course implements Course {
  const factory _Course({
    required final int id,
    required final int levelId,
    required final String title,
    required final String slug,
    final String? description,
    final String? shortDescription,
    final String? imageUrl,
    final int? ageFrom,
    final int? ageTo,
    final int? durationLessons,
    final int? projectsCount,
    final String? difficulty,
    required final String audience,
  }) = _$CourseImpl;

  factory _Course.fromJson(Map<String, dynamic> json) = _$CourseImpl.fromJson;

  @override
  int get id;
  @override
  int get levelId;
  @override
  String get title;
  @override
  String get slug;
  @override
  String? get description;
  @override
  String? get shortDescription;
  @override
  String? get imageUrl;
  @override
  int? get ageFrom;
  @override
  int? get ageTo;
  @override
  int? get durationLessons;
  @override
  int? get projectsCount;
  @override
  String? get difficulty;
  @override
  String get audience;

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CourseImplCopyWith<_$CourseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
