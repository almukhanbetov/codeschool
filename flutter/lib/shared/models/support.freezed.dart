// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'support.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SupportThreadAbout _$SupportThreadAboutFromJson(Map<String, dynamic> json) {
  return _SupportThreadAbout.fromJson(json);
}

/// @nodoc
mixin _$SupportThreadAbout {
  String get studentName => throw _privateConstructorUsedError;
  String? get courseTitle => throw _privateConstructorUsedError;
  String? get lessonTitle => throw _privateConstructorUsedError;
  String? get assignmentName => throw _privateConstructorUsedError;

  /// Serializes this SupportThreadAbout to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SupportThreadAbout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SupportThreadAboutCopyWith<SupportThreadAbout> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SupportThreadAboutCopyWith<$Res> {
  factory $SupportThreadAboutCopyWith(
    SupportThreadAbout value,
    $Res Function(SupportThreadAbout) then,
  ) = _$SupportThreadAboutCopyWithImpl<$Res, SupportThreadAbout>;
  @useResult
  $Res call({
    String studentName,
    String? courseTitle,
    String? lessonTitle,
    String? assignmentName,
  });
}

/// @nodoc
class _$SupportThreadAboutCopyWithImpl<$Res, $Val extends SupportThreadAbout>
    implements $SupportThreadAboutCopyWith<$Res> {
  _$SupportThreadAboutCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SupportThreadAbout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentName = null,
    Object? courseTitle = freezed,
    Object? lessonTitle = freezed,
    Object? assignmentName = freezed,
  }) {
    return _then(
      _value.copyWith(
            studentName: null == studentName
                ? _value.studentName
                : studentName // ignore: cast_nullable_to_non_nullable
                      as String,
            courseTitle: freezed == courseTitle
                ? _value.courseTitle
                : courseTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            lessonTitle: freezed == lessonTitle
                ? _value.lessonTitle
                : lessonTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignmentName: freezed == assignmentName
                ? _value.assignmentName
                : assignmentName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SupportThreadAboutImplCopyWith<$Res>
    implements $SupportThreadAboutCopyWith<$Res> {
  factory _$$SupportThreadAboutImplCopyWith(
    _$SupportThreadAboutImpl value,
    $Res Function(_$SupportThreadAboutImpl) then,
  ) = __$$SupportThreadAboutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String studentName,
    String? courseTitle,
    String? lessonTitle,
    String? assignmentName,
  });
}

/// @nodoc
class __$$SupportThreadAboutImplCopyWithImpl<$Res>
    extends _$SupportThreadAboutCopyWithImpl<$Res, _$SupportThreadAboutImpl>
    implements _$$SupportThreadAboutImplCopyWith<$Res> {
  __$$SupportThreadAboutImplCopyWithImpl(
    _$SupportThreadAboutImpl _value,
    $Res Function(_$SupportThreadAboutImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SupportThreadAbout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentName = null,
    Object? courseTitle = freezed,
    Object? lessonTitle = freezed,
    Object? assignmentName = freezed,
  }) {
    return _then(
      _$SupportThreadAboutImpl(
        studentName: null == studentName
            ? _value.studentName
            : studentName // ignore: cast_nullable_to_non_nullable
                  as String,
        courseTitle: freezed == courseTitle
            ? _value.courseTitle
            : courseTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        lessonTitle: freezed == lessonTitle
            ? _value.lessonTitle
            : lessonTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignmentName: freezed == assignmentName
            ? _value.assignmentName
            : assignmentName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SupportThreadAboutImpl implements _SupportThreadAbout {
  const _$SupportThreadAboutImpl({
    required this.studentName,
    this.courseTitle,
    this.lessonTitle,
    this.assignmentName,
  });

  factory _$SupportThreadAboutImpl.fromJson(Map<String, dynamic> json) =>
      _$$SupportThreadAboutImplFromJson(json);

  @override
  final String studentName;
  @override
  final String? courseTitle;
  @override
  final String? lessonTitle;
  @override
  final String? assignmentName;

  @override
  String toString() {
    return 'SupportThreadAbout(studentName: $studentName, courseTitle: $courseTitle, lessonTitle: $lessonTitle, assignmentName: $assignmentName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupportThreadAboutImpl &&
            (identical(other.studentName, studentName) ||
                other.studentName == studentName) &&
            (identical(other.courseTitle, courseTitle) ||
                other.courseTitle == courseTitle) &&
            (identical(other.lessonTitle, lessonTitle) ||
                other.lessonTitle == lessonTitle) &&
            (identical(other.assignmentName, assignmentName) ||
                other.assignmentName == assignmentName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    studentName,
    courseTitle,
    lessonTitle,
    assignmentName,
  );

  /// Create a copy of SupportThreadAbout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SupportThreadAboutImplCopyWith<_$SupportThreadAboutImpl> get copyWith =>
      __$$SupportThreadAboutImplCopyWithImpl<_$SupportThreadAboutImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SupportThreadAboutImplToJson(this);
  }
}

abstract class _SupportThreadAbout implements SupportThreadAbout {
  const factory _SupportThreadAbout({
    required final String studentName,
    final String? courseTitle,
    final String? lessonTitle,
    final String? assignmentName,
  }) = _$SupportThreadAboutImpl;

  factory _SupportThreadAbout.fromJson(Map<String, dynamic> json) =
      _$SupportThreadAboutImpl.fromJson;

  @override
  String get studentName;
  @override
  String? get courseTitle;
  @override
  String? get lessonTitle;
  @override
  String? get assignmentName;

  /// Create a copy of SupportThreadAbout
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SupportThreadAboutImplCopyWith<_$SupportThreadAboutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SupportThreadListItem _$SupportThreadListItemFromJson(
  Map<String, dynamic> json,
) {
  return _SupportThreadListItem.fromJson(json);
}

/// @nodoc
mixin _$SupportThreadListItem {
  int get id => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get priority => throw _privateConstructorUsedError;
  SupportThreadAbout get about => throw _privateConstructorUsedError;
  String get lastMessagePreview => throw _privateConstructorUsedError;
  DateTime get lastMessageAt => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;
  bool get assignedToStaff => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SupportThreadListItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SupportThreadListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SupportThreadListItemCopyWith<SupportThreadListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SupportThreadListItemCopyWith<$Res> {
  factory $SupportThreadListItemCopyWith(
    SupportThreadListItem value,
    $Res Function(SupportThreadListItem) then,
  ) = _$SupportThreadListItemCopyWithImpl<$Res, SupportThreadListItem>;
  @useResult
  $Res call({
    int id,
    String subject,
    String category,
    String status,
    String priority,
    SupportThreadAbout about,
    String lastMessagePreview,
    DateTime lastMessageAt,
    int unreadCount,
    bool assignedToStaff,
    DateTime createdAt,
  });

  $SupportThreadAboutCopyWith<$Res> get about;
}

/// @nodoc
class _$SupportThreadListItemCopyWithImpl<
  $Res,
  $Val extends SupportThreadListItem
>
    implements $SupportThreadListItemCopyWith<$Res> {
  _$SupportThreadListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SupportThreadListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subject = null,
    Object? category = null,
    Object? status = null,
    Object? priority = null,
    Object? about = null,
    Object? lastMessagePreview = null,
    Object? lastMessageAt = null,
    Object? unreadCount = null,
    Object? assignedToStaff = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            subject: null == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as String,
            about: null == about
                ? _value.about
                : about // ignore: cast_nullable_to_non_nullable
                      as SupportThreadAbout,
            lastMessagePreview: null == lastMessagePreview
                ? _value.lastMessagePreview
                : lastMessagePreview // ignore: cast_nullable_to_non_nullable
                      as String,
            lastMessageAt: null == lastMessageAt
                ? _value.lastMessageAt
                : lastMessageAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            unreadCount: null == unreadCount
                ? _value.unreadCount
                : unreadCount // ignore: cast_nullable_to_non_nullable
                      as int,
            assignedToStaff: null == assignedToStaff
                ? _value.assignedToStaff
                : assignedToStaff // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }

  /// Create a copy of SupportThreadListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SupportThreadAboutCopyWith<$Res> get about {
    return $SupportThreadAboutCopyWith<$Res>(_value.about, (value) {
      return _then(_value.copyWith(about: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SupportThreadListItemImplCopyWith<$Res>
    implements $SupportThreadListItemCopyWith<$Res> {
  factory _$$SupportThreadListItemImplCopyWith(
    _$SupportThreadListItemImpl value,
    $Res Function(_$SupportThreadListItemImpl) then,
  ) = __$$SupportThreadListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String subject,
    String category,
    String status,
    String priority,
    SupportThreadAbout about,
    String lastMessagePreview,
    DateTime lastMessageAt,
    int unreadCount,
    bool assignedToStaff,
    DateTime createdAt,
  });

  @override
  $SupportThreadAboutCopyWith<$Res> get about;
}

/// @nodoc
class __$$SupportThreadListItemImplCopyWithImpl<$Res>
    extends
        _$SupportThreadListItemCopyWithImpl<$Res, _$SupportThreadListItemImpl>
    implements _$$SupportThreadListItemImplCopyWith<$Res> {
  __$$SupportThreadListItemImplCopyWithImpl(
    _$SupportThreadListItemImpl _value,
    $Res Function(_$SupportThreadListItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SupportThreadListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subject = null,
    Object? category = null,
    Object? status = null,
    Object? priority = null,
    Object? about = null,
    Object? lastMessagePreview = null,
    Object? lastMessageAt = null,
    Object? unreadCount = null,
    Object? assignedToStaff = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$SupportThreadListItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        subject: null == subject
            ? _value.subject
            : subject // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as String,
        about: null == about
            ? _value.about
            : about // ignore: cast_nullable_to_non_nullable
                  as SupportThreadAbout,
        lastMessagePreview: null == lastMessagePreview
            ? _value.lastMessagePreview
            : lastMessagePreview // ignore: cast_nullable_to_non_nullable
                  as String,
        lastMessageAt: null == lastMessageAt
            ? _value.lastMessageAt
            : lastMessageAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        unreadCount: null == unreadCount
            ? _value.unreadCount
            : unreadCount // ignore: cast_nullable_to_non_nullable
                  as int,
        assignedToStaff: null == assignedToStaff
            ? _value.assignedToStaff
            : assignedToStaff // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SupportThreadListItemImpl implements _SupportThreadListItem {
  const _$SupportThreadListItemImpl({
    required this.id,
    required this.subject,
    required this.category,
    required this.status,
    required this.priority,
    required this.about,
    required this.lastMessagePreview,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.assignedToStaff,
    required this.createdAt,
  });

  factory _$SupportThreadListItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$SupportThreadListItemImplFromJson(json);

  @override
  final int id;
  @override
  final String subject;
  @override
  final String category;
  @override
  final String status;
  @override
  final String priority;
  @override
  final SupportThreadAbout about;
  @override
  final String lastMessagePreview;
  @override
  final DateTime lastMessageAt;
  @override
  final int unreadCount;
  @override
  final bool assignedToStaff;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'SupportThreadListItem(id: $id, subject: $subject, category: $category, status: $status, priority: $priority, about: $about, lastMessagePreview: $lastMessagePreview, lastMessageAt: $lastMessageAt, unreadCount: $unreadCount, assignedToStaff: $assignedToStaff, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupportThreadListItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.about, about) || other.about == about) &&
            (identical(other.lastMessagePreview, lastMessagePreview) ||
                other.lastMessagePreview == lastMessagePreview) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.assignedToStaff, assignedToStaff) ||
                other.assignedToStaff == assignedToStaff) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    subject,
    category,
    status,
    priority,
    about,
    lastMessagePreview,
    lastMessageAt,
    unreadCount,
    assignedToStaff,
    createdAt,
  );

  /// Create a copy of SupportThreadListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SupportThreadListItemImplCopyWith<_$SupportThreadListItemImpl>
  get copyWith =>
      __$$SupportThreadListItemImplCopyWithImpl<_$SupportThreadListItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SupportThreadListItemImplToJson(this);
  }
}

abstract class _SupportThreadListItem implements SupportThreadListItem {
  const factory _SupportThreadListItem({
    required final int id,
    required final String subject,
    required final String category,
    required final String status,
    required final String priority,
    required final SupportThreadAbout about,
    required final String lastMessagePreview,
    required final DateTime lastMessageAt,
    required final int unreadCount,
    required final bool assignedToStaff,
    required final DateTime createdAt,
  }) = _$SupportThreadListItemImpl;

  factory _SupportThreadListItem.fromJson(Map<String, dynamic> json) =
      _$SupportThreadListItemImpl.fromJson;

  @override
  int get id;
  @override
  String get subject;
  @override
  String get category;
  @override
  String get status;
  @override
  String get priority;
  @override
  SupportThreadAbout get about;
  @override
  String get lastMessagePreview;
  @override
  DateTime get lastMessageAt;
  @override
  int get unreadCount;
  @override
  bool get assignedToStaff;
  @override
  DateTime get createdAt;

  /// Create a copy of SupportThreadListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SupportThreadListItemImplCopyWith<_$SupportThreadListItemImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SupportThreadDetail _$SupportThreadDetailFromJson(Map<String, dynamic> json) {
  return _SupportThreadDetail.fromJson(json);
}

/// @nodoc
mixin _$SupportThreadDetail {
  int get id => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get priority => throw _privateConstructorUsedError;
  SupportThreadAbout get about => throw _privateConstructorUsedError;
  String get lastMessagePreview => throw _privateConstructorUsedError;
  DateTime get lastMessageAt => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;
  bool get assignedToStaff => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isParentThread => throw _privateConstructorUsedError;

  /// Serializes this SupportThreadDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SupportThreadDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SupportThreadDetailCopyWith<SupportThreadDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SupportThreadDetailCopyWith<$Res> {
  factory $SupportThreadDetailCopyWith(
    SupportThreadDetail value,
    $Res Function(SupportThreadDetail) then,
  ) = _$SupportThreadDetailCopyWithImpl<$Res, SupportThreadDetail>;
  @useResult
  $Res call({
    int id,
    String subject,
    String category,
    String status,
    String priority,
    SupportThreadAbout about,
    String lastMessagePreview,
    DateTime lastMessageAt,
    int unreadCount,
    bool assignedToStaff,
    DateTime createdAt,
    bool isParentThread,
  });

  $SupportThreadAboutCopyWith<$Res> get about;
}

/// @nodoc
class _$SupportThreadDetailCopyWithImpl<$Res, $Val extends SupportThreadDetail>
    implements $SupportThreadDetailCopyWith<$Res> {
  _$SupportThreadDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SupportThreadDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subject = null,
    Object? category = null,
    Object? status = null,
    Object? priority = null,
    Object? about = null,
    Object? lastMessagePreview = null,
    Object? lastMessageAt = null,
    Object? unreadCount = null,
    Object? assignedToStaff = null,
    Object? createdAt = null,
    Object? isParentThread = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            subject: null == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as String,
            about: null == about
                ? _value.about
                : about // ignore: cast_nullable_to_non_nullable
                      as SupportThreadAbout,
            lastMessagePreview: null == lastMessagePreview
                ? _value.lastMessagePreview
                : lastMessagePreview // ignore: cast_nullable_to_non_nullable
                      as String,
            lastMessageAt: null == lastMessageAt
                ? _value.lastMessageAt
                : lastMessageAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            unreadCount: null == unreadCount
                ? _value.unreadCount
                : unreadCount // ignore: cast_nullable_to_non_nullable
                      as int,
            assignedToStaff: null == assignedToStaff
                ? _value.assignedToStaff
                : assignedToStaff // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isParentThread: null == isParentThread
                ? _value.isParentThread
                : isParentThread // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of SupportThreadDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SupportThreadAboutCopyWith<$Res> get about {
    return $SupportThreadAboutCopyWith<$Res>(_value.about, (value) {
      return _then(_value.copyWith(about: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SupportThreadDetailImplCopyWith<$Res>
    implements $SupportThreadDetailCopyWith<$Res> {
  factory _$$SupportThreadDetailImplCopyWith(
    _$SupportThreadDetailImpl value,
    $Res Function(_$SupportThreadDetailImpl) then,
  ) = __$$SupportThreadDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String subject,
    String category,
    String status,
    String priority,
    SupportThreadAbout about,
    String lastMessagePreview,
    DateTime lastMessageAt,
    int unreadCount,
    bool assignedToStaff,
    DateTime createdAt,
    bool isParentThread,
  });

  @override
  $SupportThreadAboutCopyWith<$Res> get about;
}

/// @nodoc
class __$$SupportThreadDetailImplCopyWithImpl<$Res>
    extends _$SupportThreadDetailCopyWithImpl<$Res, _$SupportThreadDetailImpl>
    implements _$$SupportThreadDetailImplCopyWith<$Res> {
  __$$SupportThreadDetailImplCopyWithImpl(
    _$SupportThreadDetailImpl _value,
    $Res Function(_$SupportThreadDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SupportThreadDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subject = null,
    Object? category = null,
    Object? status = null,
    Object? priority = null,
    Object? about = null,
    Object? lastMessagePreview = null,
    Object? lastMessageAt = null,
    Object? unreadCount = null,
    Object? assignedToStaff = null,
    Object? createdAt = null,
    Object? isParentThread = null,
  }) {
    return _then(
      _$SupportThreadDetailImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        subject: null == subject
            ? _value.subject
            : subject // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as String,
        about: null == about
            ? _value.about
            : about // ignore: cast_nullable_to_non_nullable
                  as SupportThreadAbout,
        lastMessagePreview: null == lastMessagePreview
            ? _value.lastMessagePreview
            : lastMessagePreview // ignore: cast_nullable_to_non_nullable
                  as String,
        lastMessageAt: null == lastMessageAt
            ? _value.lastMessageAt
            : lastMessageAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        unreadCount: null == unreadCount
            ? _value.unreadCount
            : unreadCount // ignore: cast_nullable_to_non_nullable
                  as int,
        assignedToStaff: null == assignedToStaff
            ? _value.assignedToStaff
            : assignedToStaff // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isParentThread: null == isParentThread
            ? _value.isParentThread
            : isParentThread // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SupportThreadDetailImpl implements _SupportThreadDetail {
  const _$SupportThreadDetailImpl({
    required this.id,
    required this.subject,
    required this.category,
    required this.status,
    required this.priority,
    required this.about,
    required this.lastMessagePreview,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.assignedToStaff,
    required this.createdAt,
    required this.isParentThread,
  });

  factory _$SupportThreadDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$SupportThreadDetailImplFromJson(json);

  @override
  final int id;
  @override
  final String subject;
  @override
  final String category;
  @override
  final String status;
  @override
  final String priority;
  @override
  final SupportThreadAbout about;
  @override
  final String lastMessagePreview;
  @override
  final DateTime lastMessageAt;
  @override
  final int unreadCount;
  @override
  final bool assignedToStaff;
  @override
  final DateTime createdAt;
  @override
  final bool isParentThread;

  @override
  String toString() {
    return 'SupportThreadDetail(id: $id, subject: $subject, category: $category, status: $status, priority: $priority, about: $about, lastMessagePreview: $lastMessagePreview, lastMessageAt: $lastMessageAt, unreadCount: $unreadCount, assignedToStaff: $assignedToStaff, createdAt: $createdAt, isParentThread: $isParentThread)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupportThreadDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.about, about) || other.about == about) &&
            (identical(other.lastMessagePreview, lastMessagePreview) ||
                other.lastMessagePreview == lastMessagePreview) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.assignedToStaff, assignedToStaff) ||
                other.assignedToStaff == assignedToStaff) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isParentThread, isParentThread) ||
                other.isParentThread == isParentThread));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    subject,
    category,
    status,
    priority,
    about,
    lastMessagePreview,
    lastMessageAt,
    unreadCount,
    assignedToStaff,
    createdAt,
    isParentThread,
  );

  /// Create a copy of SupportThreadDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SupportThreadDetailImplCopyWith<_$SupportThreadDetailImpl> get copyWith =>
      __$$SupportThreadDetailImplCopyWithImpl<_$SupportThreadDetailImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SupportThreadDetailImplToJson(this);
  }
}

abstract class _SupportThreadDetail implements SupportThreadDetail {
  const factory _SupportThreadDetail({
    required final int id,
    required final String subject,
    required final String category,
    required final String status,
    required final String priority,
    required final SupportThreadAbout about,
    required final String lastMessagePreview,
    required final DateTime lastMessageAt,
    required final int unreadCount,
    required final bool assignedToStaff,
    required final DateTime createdAt,
    required final bool isParentThread,
  }) = _$SupportThreadDetailImpl;

  factory _SupportThreadDetail.fromJson(Map<String, dynamic> json) =
      _$SupportThreadDetailImpl.fromJson;

  @override
  int get id;
  @override
  String get subject;
  @override
  String get category;
  @override
  String get status;
  @override
  String get priority;
  @override
  SupportThreadAbout get about;
  @override
  String get lastMessagePreview;
  @override
  DateTime get lastMessageAt;
  @override
  int get unreadCount;
  @override
  bool get assignedToStaff;
  @override
  DateTime get createdAt;
  @override
  bool get isParentThread;

  /// Create a copy of SupportThreadDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SupportThreadDetailImplCopyWith<_$SupportThreadDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SupportMessage _$SupportMessageFromJson(Map<String, dynamic> json) {
  return _SupportMessage.fromJson(json);
}

/// @nodoc
mixin _$SupportMessage {
  int get id => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  String get messageType => throw _privateConstructorUsedError;
  String get senderRole => throw _privateConstructorUsedError;
  String get senderName => throw _privateConstructorUsedError;
  bool get mine => throw _privateConstructorUsedError;
  bool get isInternal => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get editedAt => throw _privateConstructorUsedError;

  /// Serializes this SupportMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SupportMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SupportMessageCopyWith<SupportMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SupportMessageCopyWith<$Res> {
  factory $SupportMessageCopyWith(
    SupportMessage value,
    $Res Function(SupportMessage) then,
  ) = _$SupportMessageCopyWithImpl<$Res, SupportMessage>;
  @useResult
  $Res call({
    int id,
    String body,
    String messageType,
    String senderRole,
    String senderName,
    bool mine,
    bool isInternal,
    DateTime createdAt,
    DateTime? editedAt,
  });
}

/// @nodoc
class _$SupportMessageCopyWithImpl<$Res, $Val extends SupportMessage>
    implements $SupportMessageCopyWith<$Res> {
  _$SupportMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SupportMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? body = null,
    Object? messageType = null,
    Object? senderRole = null,
    Object? senderName = null,
    Object? mine = null,
    Object? isInternal = null,
    Object? createdAt = null,
    Object? editedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            messageType: null == messageType
                ? _value.messageType
                : messageType // ignore: cast_nullable_to_non_nullable
                      as String,
            senderRole: null == senderRole
                ? _value.senderRole
                : senderRole // ignore: cast_nullable_to_non_nullable
                      as String,
            senderName: null == senderName
                ? _value.senderName
                : senderName // ignore: cast_nullable_to_non_nullable
                      as String,
            mine: null == mine
                ? _value.mine
                : mine // ignore: cast_nullable_to_non_nullable
                      as bool,
            isInternal: null == isInternal
                ? _value.isInternal
                : isInternal // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            editedAt: freezed == editedAt
                ? _value.editedAt
                : editedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SupportMessageImplCopyWith<$Res>
    implements $SupportMessageCopyWith<$Res> {
  factory _$$SupportMessageImplCopyWith(
    _$SupportMessageImpl value,
    $Res Function(_$SupportMessageImpl) then,
  ) = __$$SupportMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String body,
    String messageType,
    String senderRole,
    String senderName,
    bool mine,
    bool isInternal,
    DateTime createdAt,
    DateTime? editedAt,
  });
}

/// @nodoc
class __$$SupportMessageImplCopyWithImpl<$Res>
    extends _$SupportMessageCopyWithImpl<$Res, _$SupportMessageImpl>
    implements _$$SupportMessageImplCopyWith<$Res> {
  __$$SupportMessageImplCopyWithImpl(
    _$SupportMessageImpl _value,
    $Res Function(_$SupportMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SupportMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? body = null,
    Object? messageType = null,
    Object? senderRole = null,
    Object? senderName = null,
    Object? mine = null,
    Object? isInternal = null,
    Object? createdAt = null,
    Object? editedAt = freezed,
  }) {
    return _then(
      _$SupportMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        messageType: null == messageType
            ? _value.messageType
            : messageType // ignore: cast_nullable_to_non_nullable
                  as String,
        senderRole: null == senderRole
            ? _value.senderRole
            : senderRole // ignore: cast_nullable_to_non_nullable
                  as String,
        senderName: null == senderName
            ? _value.senderName
            : senderName // ignore: cast_nullable_to_non_nullable
                  as String,
        mine: null == mine
            ? _value.mine
            : mine // ignore: cast_nullable_to_non_nullable
                  as bool,
        isInternal: null == isInternal
            ? _value.isInternal
            : isInternal // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        editedAt: freezed == editedAt
            ? _value.editedAt
            : editedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SupportMessageImpl implements _SupportMessage {
  const _$SupportMessageImpl({
    required this.id,
    required this.body,
    required this.messageType,
    required this.senderRole,
    required this.senderName,
    required this.mine,
    required this.isInternal,
    required this.createdAt,
    this.editedAt,
  });

  factory _$SupportMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$SupportMessageImplFromJson(json);

  @override
  final int id;
  @override
  final String body;
  @override
  final String messageType;
  @override
  final String senderRole;
  @override
  final String senderName;
  @override
  final bool mine;
  @override
  final bool isInternal;
  @override
  final DateTime createdAt;
  @override
  final DateTime? editedAt;

  @override
  String toString() {
    return 'SupportMessage(id: $id, body: $body, messageType: $messageType, senderRole: $senderRole, senderName: $senderName, mine: $mine, isInternal: $isInternal, createdAt: $createdAt, editedAt: $editedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupportMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.messageType, messageType) ||
                other.messageType == messageType) &&
            (identical(other.senderRole, senderRole) ||
                other.senderRole == senderRole) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.mine, mine) || other.mine == mine) &&
            (identical(other.isInternal, isInternal) ||
                other.isInternal == isInternal) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.editedAt, editedAt) ||
                other.editedAt == editedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    body,
    messageType,
    senderRole,
    senderName,
    mine,
    isInternal,
    createdAt,
    editedAt,
  );

  /// Create a copy of SupportMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SupportMessageImplCopyWith<_$SupportMessageImpl> get copyWith =>
      __$$SupportMessageImplCopyWithImpl<_$SupportMessageImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SupportMessageImplToJson(this);
  }
}

abstract class _SupportMessage implements SupportMessage {
  const factory _SupportMessage({
    required final int id,
    required final String body,
    required final String messageType,
    required final String senderRole,
    required final String senderName,
    required final bool mine,
    required final bool isInternal,
    required final DateTime createdAt,
    final DateTime? editedAt,
  }) = _$SupportMessageImpl;

  factory _SupportMessage.fromJson(Map<String, dynamic> json) =
      _$SupportMessageImpl.fromJson;

  @override
  int get id;
  @override
  String get body;
  @override
  String get messageType;
  @override
  String get senderRole;
  @override
  String get senderName;
  @override
  bool get mine;
  @override
  bool get isInternal;
  @override
  DateTime get createdAt;
  @override
  DateTime? get editedAt;

  /// Create a copy of SupportMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SupportMessageImplCopyWith<_$SupportMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SupportUnreadCount _$SupportUnreadCountFromJson(Map<String, dynamic> json) {
  return _SupportUnreadCount.fromJson(json);
}

/// @nodoc
mixin _$SupportUnreadCount {
  int get threads => throw _privateConstructorUsedError;
  int get messages => throw _privateConstructorUsedError;

  /// Serializes this SupportUnreadCount to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SupportUnreadCount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SupportUnreadCountCopyWith<SupportUnreadCount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SupportUnreadCountCopyWith<$Res> {
  factory $SupportUnreadCountCopyWith(
    SupportUnreadCount value,
    $Res Function(SupportUnreadCount) then,
  ) = _$SupportUnreadCountCopyWithImpl<$Res, SupportUnreadCount>;
  @useResult
  $Res call({int threads, int messages});
}

/// @nodoc
class _$SupportUnreadCountCopyWithImpl<$Res, $Val extends SupportUnreadCount>
    implements $SupportUnreadCountCopyWith<$Res> {
  _$SupportUnreadCountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SupportUnreadCount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? threads = null, Object? messages = null}) {
    return _then(
      _value.copyWith(
            threads: null == threads
                ? _value.threads
                : threads // ignore: cast_nullable_to_non_nullable
                      as int,
            messages: null == messages
                ? _value.messages
                : messages // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SupportUnreadCountImplCopyWith<$Res>
    implements $SupportUnreadCountCopyWith<$Res> {
  factory _$$SupportUnreadCountImplCopyWith(
    _$SupportUnreadCountImpl value,
    $Res Function(_$SupportUnreadCountImpl) then,
  ) = __$$SupportUnreadCountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int threads, int messages});
}

/// @nodoc
class __$$SupportUnreadCountImplCopyWithImpl<$Res>
    extends _$SupportUnreadCountCopyWithImpl<$Res, _$SupportUnreadCountImpl>
    implements _$$SupportUnreadCountImplCopyWith<$Res> {
  __$$SupportUnreadCountImplCopyWithImpl(
    _$SupportUnreadCountImpl _value,
    $Res Function(_$SupportUnreadCountImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SupportUnreadCount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? threads = null, Object? messages = null}) {
    return _then(
      _$SupportUnreadCountImpl(
        threads: null == threads
            ? _value.threads
            : threads // ignore: cast_nullable_to_non_nullable
                  as int,
        messages: null == messages
            ? _value.messages
            : messages // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SupportUnreadCountImpl implements _SupportUnreadCount {
  const _$SupportUnreadCountImpl({
    required this.threads,
    required this.messages,
  });

  factory _$SupportUnreadCountImpl.fromJson(Map<String, dynamic> json) =>
      _$$SupportUnreadCountImplFromJson(json);

  @override
  final int threads;
  @override
  final int messages;

  @override
  String toString() {
    return 'SupportUnreadCount(threads: $threads, messages: $messages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupportUnreadCountImpl &&
            (identical(other.threads, threads) || other.threads == threads) &&
            (identical(other.messages, messages) ||
                other.messages == messages));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, threads, messages);

  /// Create a copy of SupportUnreadCount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SupportUnreadCountImplCopyWith<_$SupportUnreadCountImpl> get copyWith =>
      __$$SupportUnreadCountImplCopyWithImpl<_$SupportUnreadCountImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SupportUnreadCountImplToJson(this);
  }
}

abstract class _SupportUnreadCount implements SupportUnreadCount {
  const factory _SupportUnreadCount({
    required final int threads,
    required final int messages,
  }) = _$SupportUnreadCountImpl;

  factory _SupportUnreadCount.fromJson(Map<String, dynamic> json) =
      _$SupportUnreadCountImpl.fromJson;

  @override
  int get threads;
  @override
  int get messages;

  /// Create a copy of SupportUnreadCount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SupportUnreadCountImplCopyWith<_$SupportUnreadCountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
