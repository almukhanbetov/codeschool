// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'course_content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CourseContent _$CourseContentFromJson(Map<String, dynamic> json) {
  return _CourseContent.fromJson(json);
}

/// @nodoc
mixin _$CourseContent {
  Course get course => throw _privateConstructorUsedError;
  List<CourseModule> get modules => throw _privateConstructorUsedError;

  /// Serializes this CourseContent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CourseContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CourseContentCopyWith<CourseContent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CourseContentCopyWith<$Res> {
  factory $CourseContentCopyWith(
    CourseContent value,
    $Res Function(CourseContent) then,
  ) = _$CourseContentCopyWithImpl<$Res, CourseContent>;
  @useResult
  $Res call({Course course, List<CourseModule> modules});

  $CourseCopyWith<$Res> get course;
}

/// @nodoc
class _$CourseContentCopyWithImpl<$Res, $Val extends CourseContent>
    implements $CourseContentCopyWith<$Res> {
  _$CourseContentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CourseContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? course = null, Object? modules = null}) {
    return _then(
      _value.copyWith(
            course: null == course
                ? _value.course
                : course // ignore: cast_nullable_to_non_nullable
                      as Course,
            modules: null == modules
                ? _value.modules
                : modules // ignore: cast_nullable_to_non_nullable
                      as List<CourseModule>,
          )
          as $Val,
    );
  }

  /// Create a copy of CourseContent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CourseCopyWith<$Res> get course {
    return $CourseCopyWith<$Res>(_value.course, (value) {
      return _then(_value.copyWith(course: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CourseContentImplCopyWith<$Res>
    implements $CourseContentCopyWith<$Res> {
  factory _$$CourseContentImplCopyWith(
    _$CourseContentImpl value,
    $Res Function(_$CourseContentImpl) then,
  ) = __$$CourseContentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Course course, List<CourseModule> modules});

  @override
  $CourseCopyWith<$Res> get course;
}

/// @nodoc
class __$$CourseContentImplCopyWithImpl<$Res>
    extends _$CourseContentCopyWithImpl<$Res, _$CourseContentImpl>
    implements _$$CourseContentImplCopyWith<$Res> {
  __$$CourseContentImplCopyWithImpl(
    _$CourseContentImpl _value,
    $Res Function(_$CourseContentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CourseContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? course = null, Object? modules = null}) {
    return _then(
      _$CourseContentImpl(
        course: null == course
            ? _value.course
            : course // ignore: cast_nullable_to_non_nullable
                  as Course,
        modules: null == modules
            ? _value._modules
            : modules // ignore: cast_nullable_to_non_nullable
                  as List<CourseModule>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CourseContentImpl implements _CourseContent {
  const _$CourseContentImpl({
    required this.course,
    final List<CourseModule> modules = const [],
  }) : _modules = modules;

  factory _$CourseContentImpl.fromJson(Map<String, dynamic> json) =>
      _$$CourseContentImplFromJson(json);

  @override
  final Course course;
  final List<CourseModule> _modules;
  @override
  @JsonKey()
  List<CourseModule> get modules {
    if (_modules is EqualUnmodifiableListView) return _modules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_modules);
  }

  @override
  String toString() {
    return 'CourseContent(course: $course, modules: $modules)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CourseContentImpl &&
            (identical(other.course, course) || other.course == course) &&
            const DeepCollectionEquality().equals(other._modules, _modules));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    course,
    const DeepCollectionEquality().hash(_modules),
  );

  /// Create a copy of CourseContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CourseContentImplCopyWith<_$CourseContentImpl> get copyWith =>
      __$$CourseContentImplCopyWithImpl<_$CourseContentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CourseContentImplToJson(this);
  }
}

abstract class _CourseContent implements CourseContent {
  const factory _CourseContent({
    required final Course course,
    final List<CourseModule> modules,
  }) = _$CourseContentImpl;

  factory _CourseContent.fromJson(Map<String, dynamic> json) =
      _$CourseContentImpl.fromJson;

  @override
  Course get course;
  @override
  List<CourseModule> get modules;

  /// Create a copy of CourseContent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CourseContentImplCopyWith<_$CourseContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
