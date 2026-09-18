// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lesson.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Lesson _$LessonFromJson(Map<String, dynamic> json) {
  return _Lesson.fromJson(json);
}

/// @nodoc
mixin _$Lesson {
  int get id => throw _privateConstructorUsedError;
  int get moduleId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get slug => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  String? get videoUrl => throw _privateConstructorUsedError;
  String get lessonType => throw _privateConstructorUsedError;
  int get position => throw _privateConstructorUsedError;

  /// Serializes this Lesson to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LessonCopyWith<Lesson> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonCopyWith<$Res> {
  factory $LessonCopyWith(Lesson value, $Res Function(Lesson) then) =
      _$LessonCopyWithImpl<$Res, Lesson>;
  @useResult
  $Res call({
    int id,
    int moduleId,
    String title,
    String? slug,
    String? description,
    String? content,
    String? videoUrl,
    String lessonType,
    int position,
  });
}

/// @nodoc
class _$LessonCopyWithImpl<$Res, $Val extends Lesson>
    implements $LessonCopyWith<$Res> {
  _$LessonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? moduleId = null,
    Object? title = null,
    Object? slug = freezed,
    Object? description = freezed,
    Object? content = freezed,
    Object? videoUrl = freezed,
    Object? lessonType = null,
    Object? position = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            moduleId: null == moduleId
                ? _value.moduleId
                : moduleId // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            slug: freezed == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            content: freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String?,
            videoUrl: freezed == videoUrl
                ? _value.videoUrl
                : videoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            lessonType: null == lessonType
                ? _value.lessonType
                : lessonType // ignore: cast_nullable_to_non_nullable
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
abstract class _$$LessonImplCopyWith<$Res> implements $LessonCopyWith<$Res> {
  factory _$$LessonImplCopyWith(
    _$LessonImpl value,
    $Res Function(_$LessonImpl) then,
  ) = __$$LessonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int moduleId,
    String title,
    String? slug,
    String? description,
    String? content,
    String? videoUrl,
    String lessonType,
    int position,
  });
}

/// @nodoc
class __$$LessonImplCopyWithImpl<$Res>
    extends _$LessonCopyWithImpl<$Res, _$LessonImpl>
    implements _$$LessonImplCopyWith<$Res> {
  __$$LessonImplCopyWithImpl(
    _$LessonImpl _value,
    $Res Function(_$LessonImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? moduleId = null,
    Object? title = null,
    Object? slug = freezed,
    Object? description = freezed,
    Object? content = freezed,
    Object? videoUrl = freezed,
    Object? lessonType = null,
    Object? position = null,
  }) {
    return _then(
      _$LessonImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        moduleId: null == moduleId
            ? _value.moduleId
            : moduleId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        slug: freezed == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        content: freezed == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String?,
        videoUrl: freezed == videoUrl
            ? _value.videoUrl
            : videoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        lessonType: null == lessonType
            ? _value.lessonType
            : lessonType // ignore: cast_nullable_to_non_nullable
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
class _$LessonImpl implements _Lesson {
  const _$LessonImpl({
    required this.id,
    required this.moduleId,
    required this.title,
    this.slug,
    this.description,
    this.content,
    this.videoUrl,
    required this.lessonType,
    required this.position,
  });

  factory _$LessonImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonImplFromJson(json);

  @override
  final int id;
  @override
  final int moduleId;
  @override
  final String title;
  @override
  final String? slug;
  @override
  final String? description;
  @override
  final String? content;
  @override
  final String? videoUrl;
  @override
  final String lessonType;
  @override
  final int position;

  @override
  String toString() {
    return 'Lesson(id: $id, moduleId: $moduleId, title: $title, slug: $slug, description: $description, content: $content, videoUrl: $videoUrl, lessonType: $lessonType, position: $position)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.moduleId, moduleId) ||
                other.moduleId == moduleId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            (identical(other.lessonType, lessonType) ||
                other.lessonType == lessonType) &&
            (identical(other.position, position) ||
                other.position == position));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    moduleId,
    title,
    slug,
    description,
    content,
    videoUrl,
    lessonType,
    position,
  );

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonImplCopyWith<_$LessonImpl> get copyWith =>
      __$$LessonImplCopyWithImpl<_$LessonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonImplToJson(this);
  }
}

abstract class _Lesson implements Lesson {
  const factory _Lesson({
    required final int id,
    required final int moduleId,
    required final String title,
    final String? slug,
    final String? description,
    final String? content,
    final String? videoUrl,
    required final String lessonType,
    required final int position,
  }) = _$LessonImpl;

  factory _Lesson.fromJson(Map<String, dynamic> json) = _$LessonImpl.fromJson;

  @override
  int get id;
  @override
  int get moduleId;
  @override
  String get title;
  @override
  String? get slug;
  @override
  String? get description;
  @override
  String? get content;
  @override
  String? get videoUrl;
  @override
  String get lessonType;
  @override
  int get position;

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LessonImplCopyWith<_$LessonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CourseModule _$CourseModuleFromJson(Map<String, dynamic> json) {
  return _CourseModule.fromJson(json);
}

/// @nodoc
mixin _$CourseModule {
  int get id => throw _privateConstructorUsedError;
  int get courseId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get position => throw _privateConstructorUsedError;
  List<Lesson> get lessons => throw _privateConstructorUsedError;

  /// Serializes this CourseModule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CourseModule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CourseModuleCopyWith<CourseModule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CourseModuleCopyWith<$Res> {
  factory $CourseModuleCopyWith(
    CourseModule value,
    $Res Function(CourseModule) then,
  ) = _$CourseModuleCopyWithImpl<$Res, CourseModule>;
  @useResult
  $Res call({
    int id,
    int courseId,
    String title,
    String? description,
    int position,
    List<Lesson> lessons,
  });
}

/// @nodoc
class _$CourseModuleCopyWithImpl<$Res, $Val extends CourseModule>
    implements $CourseModuleCopyWith<$Res> {
  _$CourseModuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CourseModule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? courseId = null,
    Object? title = null,
    Object? description = freezed,
    Object? position = null,
    Object? lessons = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            courseId: null == courseId
                ? _value.courseId
                : courseId // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as int,
            lessons: null == lessons
                ? _value.lessons
                : lessons // ignore: cast_nullable_to_non_nullable
                      as List<Lesson>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CourseModuleImplCopyWith<$Res>
    implements $CourseModuleCopyWith<$Res> {
  factory _$$CourseModuleImplCopyWith(
    _$CourseModuleImpl value,
    $Res Function(_$CourseModuleImpl) then,
  ) = __$$CourseModuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int courseId,
    String title,
    String? description,
    int position,
    List<Lesson> lessons,
  });
}

/// @nodoc
class __$$CourseModuleImplCopyWithImpl<$Res>
    extends _$CourseModuleCopyWithImpl<$Res, _$CourseModuleImpl>
    implements _$$CourseModuleImplCopyWith<$Res> {
  __$$CourseModuleImplCopyWithImpl(
    _$CourseModuleImpl _value,
    $Res Function(_$CourseModuleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CourseModule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? courseId = null,
    Object? title = null,
    Object? description = freezed,
    Object? position = null,
    Object? lessons = null,
  }) {
    return _then(
      _$CourseModuleImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        courseId: null == courseId
            ? _value.courseId
            : courseId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as int,
        lessons: null == lessons
            ? _value._lessons
            : lessons // ignore: cast_nullable_to_non_nullable
                  as List<Lesson>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CourseModuleImpl implements _CourseModule {
  const _$CourseModuleImpl({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.position,
    final List<Lesson> lessons = const [],
  }) : _lessons = lessons;

  factory _$CourseModuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$CourseModuleImplFromJson(json);

  @override
  final int id;
  @override
  final int courseId;
  @override
  final String title;
  @override
  final String? description;
  @override
  final int position;
  final List<Lesson> _lessons;
  @override
  @JsonKey()
  List<Lesson> get lessons {
    if (_lessons is EqualUnmodifiableListView) return _lessons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lessons);
  }

  @override
  String toString() {
    return 'CourseModule(id: $id, courseId: $courseId, title: $title, description: $description, position: $position, lessons: $lessons)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CourseModuleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.courseId, courseId) ||
                other.courseId == courseId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.position, position) ||
                other.position == position) &&
            const DeepCollectionEquality().equals(other._lessons, _lessons));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    courseId,
    title,
    description,
    position,
    const DeepCollectionEquality().hash(_lessons),
  );

  /// Create a copy of CourseModule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CourseModuleImplCopyWith<_$CourseModuleImpl> get copyWith =>
      __$$CourseModuleImplCopyWithImpl<_$CourseModuleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CourseModuleImplToJson(this);
  }
}

abstract class _CourseModule implements CourseModule {
  const factory _CourseModule({
    required final int id,
    required final int courseId,
    required final String title,
    final String? description,
    required final int position,
    final List<Lesson> lessons,
  }) = _$CourseModuleImpl;

  factory _CourseModule.fromJson(Map<String, dynamic> json) =
      _$CourseModuleImpl.fromJson;

  @override
  int get id;
  @override
  int get courseId;
  @override
  String get title;
  @override
  String? get description;
  @override
  int get position;
  @override
  List<Lesson> get lessons;

  /// Create a copy of CourseModule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CourseModuleImplCopyWith<_$CourseModuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
