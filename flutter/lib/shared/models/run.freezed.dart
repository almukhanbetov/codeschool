// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'run.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RunResult _$RunResultFromJson(Map<String, dynamic> json) {
  return _RunResult.fromJson(json);
}

/// @nodoc
mixin _$RunResult {
  int get runId => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get stdout => throw _privateConstructorUsedError;
  String get stderr => throw _privateConstructorUsedError;
  int? get exitCode => throw _privateConstructorUsedError;
  bool get timedOut => throw _privateConstructorUsedError;
  bool get truncated => throw _privateConstructorUsedError;
  int? get durationMs => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this RunResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RunResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RunResultCopyWith<RunResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RunResultCopyWith<$Res> {
  factory $RunResultCopyWith(RunResult value, $Res Function(RunResult) then) =
      _$RunResultCopyWithImpl<$Res, RunResult>;
  @useResult
  $Res call({
    int runId,
    String language,
    String status,
    String stdout,
    String stderr,
    int? exitCode,
    bool timedOut,
    bool truncated,
    int? durationMs,
    DateTime createdAt,
  });
}

/// @nodoc
class _$RunResultCopyWithImpl<$Res, $Val extends RunResult>
    implements $RunResultCopyWith<$Res> {
  _$RunResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RunResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? runId = null,
    Object? language = null,
    Object? status = null,
    Object? stdout = null,
    Object? stderr = null,
    Object? exitCode = freezed,
    Object? timedOut = null,
    Object? truncated = null,
    Object? durationMs = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            runId: null == runId
                ? _value.runId
                : runId // ignore: cast_nullable_to_non_nullable
                      as int,
            language: null == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            stdout: null == stdout
                ? _value.stdout
                : stdout // ignore: cast_nullable_to_non_nullable
                      as String,
            stderr: null == stderr
                ? _value.stderr
                : stderr // ignore: cast_nullable_to_non_nullable
                      as String,
            exitCode: freezed == exitCode
                ? _value.exitCode
                : exitCode // ignore: cast_nullable_to_non_nullable
                      as int?,
            timedOut: null == timedOut
                ? _value.timedOut
                : timedOut // ignore: cast_nullable_to_non_nullable
                      as bool,
            truncated: null == truncated
                ? _value.truncated
                : truncated // ignore: cast_nullable_to_non_nullable
                      as bool,
            durationMs: freezed == durationMs
                ? _value.durationMs
                : durationMs // ignore: cast_nullable_to_non_nullable
                      as int?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RunResultImplCopyWith<$Res>
    implements $RunResultCopyWith<$Res> {
  factory _$$RunResultImplCopyWith(
    _$RunResultImpl value,
    $Res Function(_$RunResultImpl) then,
  ) = __$$RunResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int runId,
    String language,
    String status,
    String stdout,
    String stderr,
    int? exitCode,
    bool timedOut,
    bool truncated,
    int? durationMs,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$RunResultImplCopyWithImpl<$Res>
    extends _$RunResultCopyWithImpl<$Res, _$RunResultImpl>
    implements _$$RunResultImplCopyWith<$Res> {
  __$$RunResultImplCopyWithImpl(
    _$RunResultImpl _value,
    $Res Function(_$RunResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RunResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? runId = null,
    Object? language = null,
    Object? status = null,
    Object? stdout = null,
    Object? stderr = null,
    Object? exitCode = freezed,
    Object? timedOut = null,
    Object? truncated = null,
    Object? durationMs = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$RunResultImpl(
        runId: null == runId
            ? _value.runId
            : runId // ignore: cast_nullable_to_non_nullable
                  as int,
        language: null == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        stdout: null == stdout
            ? _value.stdout
            : stdout // ignore: cast_nullable_to_non_nullable
                  as String,
        stderr: null == stderr
            ? _value.stderr
            : stderr // ignore: cast_nullable_to_non_nullable
                  as String,
        exitCode: freezed == exitCode
            ? _value.exitCode
            : exitCode // ignore: cast_nullable_to_non_nullable
                  as int?,
        timedOut: null == timedOut
            ? _value.timedOut
            : timedOut // ignore: cast_nullable_to_non_nullable
                  as bool,
        truncated: null == truncated
            ? _value.truncated
            : truncated // ignore: cast_nullable_to_non_nullable
                  as bool,
        durationMs: freezed == durationMs
            ? _value.durationMs
            : durationMs // ignore: cast_nullable_to_non_nullable
                  as int?,
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
class _$RunResultImpl implements _RunResult {
  const _$RunResultImpl({
    required this.runId,
    required this.language,
    required this.status,
    required this.stdout,
    required this.stderr,
    this.exitCode,
    required this.timedOut,
    required this.truncated,
    this.durationMs,
    required this.createdAt,
  });

  factory _$RunResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$RunResultImplFromJson(json);

  @override
  final int runId;
  @override
  final String language;
  @override
  final String status;
  @override
  final String stdout;
  @override
  final String stderr;
  @override
  final int? exitCode;
  @override
  final bool timedOut;
  @override
  final bool truncated;
  @override
  final int? durationMs;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'RunResult(runId: $runId, language: $language, status: $status, stdout: $stdout, stderr: $stderr, exitCode: $exitCode, timedOut: $timedOut, truncated: $truncated, durationMs: $durationMs, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RunResultImpl &&
            (identical(other.runId, runId) || other.runId == runId) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.stdout, stdout) || other.stdout == stdout) &&
            (identical(other.stderr, stderr) || other.stderr == stderr) &&
            (identical(other.exitCode, exitCode) ||
                other.exitCode == exitCode) &&
            (identical(other.timedOut, timedOut) ||
                other.timedOut == timedOut) &&
            (identical(other.truncated, truncated) ||
                other.truncated == truncated) &&
            (identical(other.durationMs, durationMs) ||
                other.durationMs == durationMs) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    runId,
    language,
    status,
    stdout,
    stderr,
    exitCode,
    timedOut,
    truncated,
    durationMs,
    createdAt,
  );

  /// Create a copy of RunResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RunResultImplCopyWith<_$RunResultImpl> get copyWith =>
      __$$RunResultImplCopyWithImpl<_$RunResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RunResultImplToJson(this);
  }
}

abstract class _RunResult implements RunResult {
  const factory _RunResult({
    required final int runId,
    required final String language,
    required final String status,
    required final String stdout,
    required final String stderr,
    final int? exitCode,
    required final bool timedOut,
    required final bool truncated,
    final int? durationMs,
    required final DateTime createdAt,
  }) = _$RunResultImpl;

  factory _RunResult.fromJson(Map<String, dynamic> json) =
      _$RunResultImpl.fromJson;

  @override
  int get runId;
  @override
  String get language;
  @override
  String get status;
  @override
  String get stdout;
  @override
  String get stderr;
  @override
  int? get exitCode;
  @override
  bool get timedOut;
  @override
  bool get truncated;
  @override
  int? get durationMs;
  @override
  DateTime get createdAt;

  /// Create a copy of RunResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RunResultImplCopyWith<_$RunResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RunHistoryItem _$RunHistoryItemFromJson(Map<String, dynamic> json) {
  return _RunHistoryItem.fromJson(json);
}

/// @nodoc
mixin _$RunHistoryItem {
  int get runId => throw _privateConstructorUsedError;
  String get kind => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int? get exitCode => throw _privateConstructorUsedError;
  int? get durationMs => throw _privateConstructorUsedError;
  String get stdout => throw _privateConstructorUsedError;
  String get stderr => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this RunHistoryItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RunHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RunHistoryItemCopyWith<RunHistoryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RunHistoryItemCopyWith<$Res> {
  factory $RunHistoryItemCopyWith(
    RunHistoryItem value,
    $Res Function(RunHistoryItem) then,
  ) = _$RunHistoryItemCopyWithImpl<$Res, RunHistoryItem>;
  @useResult
  $Res call({
    int runId,
    String kind,
    String status,
    int? exitCode,
    int? durationMs,
    String stdout,
    String stderr,
    DateTime createdAt,
  });
}

/// @nodoc
class _$RunHistoryItemCopyWithImpl<$Res, $Val extends RunHistoryItem>
    implements $RunHistoryItemCopyWith<$Res> {
  _$RunHistoryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RunHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? runId = null,
    Object? kind = null,
    Object? status = null,
    Object? exitCode = freezed,
    Object? durationMs = freezed,
    Object? stdout = null,
    Object? stderr = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            runId: null == runId
                ? _value.runId
                : runId // ignore: cast_nullable_to_non_nullable
                      as int,
            kind: null == kind
                ? _value.kind
                : kind // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            exitCode: freezed == exitCode
                ? _value.exitCode
                : exitCode // ignore: cast_nullable_to_non_nullable
                      as int?,
            durationMs: freezed == durationMs
                ? _value.durationMs
                : durationMs // ignore: cast_nullable_to_non_nullable
                      as int?,
            stdout: null == stdout
                ? _value.stdout
                : stdout // ignore: cast_nullable_to_non_nullable
                      as String,
            stderr: null == stderr
                ? _value.stderr
                : stderr // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RunHistoryItemImplCopyWith<$Res>
    implements $RunHistoryItemCopyWith<$Res> {
  factory _$$RunHistoryItemImplCopyWith(
    _$RunHistoryItemImpl value,
    $Res Function(_$RunHistoryItemImpl) then,
  ) = __$$RunHistoryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int runId,
    String kind,
    String status,
    int? exitCode,
    int? durationMs,
    String stdout,
    String stderr,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$RunHistoryItemImplCopyWithImpl<$Res>
    extends _$RunHistoryItemCopyWithImpl<$Res, _$RunHistoryItemImpl>
    implements _$$RunHistoryItemImplCopyWith<$Res> {
  __$$RunHistoryItemImplCopyWithImpl(
    _$RunHistoryItemImpl _value,
    $Res Function(_$RunHistoryItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RunHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? runId = null,
    Object? kind = null,
    Object? status = null,
    Object? exitCode = freezed,
    Object? durationMs = freezed,
    Object? stdout = null,
    Object? stderr = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$RunHistoryItemImpl(
        runId: null == runId
            ? _value.runId
            : runId // ignore: cast_nullable_to_non_nullable
                  as int,
        kind: null == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        exitCode: freezed == exitCode
            ? _value.exitCode
            : exitCode // ignore: cast_nullable_to_non_nullable
                  as int?,
        durationMs: freezed == durationMs
            ? _value.durationMs
            : durationMs // ignore: cast_nullable_to_non_nullable
                  as int?,
        stdout: null == stdout
            ? _value.stdout
            : stdout // ignore: cast_nullable_to_non_nullable
                  as String,
        stderr: null == stderr
            ? _value.stderr
            : stderr // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$RunHistoryItemImpl implements _RunHistoryItem {
  const _$RunHistoryItemImpl({
    required this.runId,
    required this.kind,
    required this.status,
    this.exitCode,
    this.durationMs,
    required this.stdout,
    required this.stderr,
    required this.createdAt,
  });

  factory _$RunHistoryItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$RunHistoryItemImplFromJson(json);

  @override
  final int runId;
  @override
  final String kind;
  @override
  final String status;
  @override
  final int? exitCode;
  @override
  final int? durationMs;
  @override
  final String stdout;
  @override
  final String stderr;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'RunHistoryItem(runId: $runId, kind: $kind, status: $status, exitCode: $exitCode, durationMs: $durationMs, stdout: $stdout, stderr: $stderr, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RunHistoryItemImpl &&
            (identical(other.runId, runId) || other.runId == runId) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.exitCode, exitCode) ||
                other.exitCode == exitCode) &&
            (identical(other.durationMs, durationMs) ||
                other.durationMs == durationMs) &&
            (identical(other.stdout, stdout) || other.stdout == stdout) &&
            (identical(other.stderr, stderr) || other.stderr == stderr) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    runId,
    kind,
    status,
    exitCode,
    durationMs,
    stdout,
    stderr,
    createdAt,
  );

  /// Create a copy of RunHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RunHistoryItemImplCopyWith<_$RunHistoryItemImpl> get copyWith =>
      __$$RunHistoryItemImplCopyWithImpl<_$RunHistoryItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RunHistoryItemImplToJson(this);
  }
}

abstract class _RunHistoryItem implements RunHistoryItem {
  const factory _RunHistoryItem({
    required final int runId,
    required final String kind,
    required final String status,
    final int? exitCode,
    final int? durationMs,
    required final String stdout,
    required final String stderr,
    required final DateTime createdAt,
  }) = _$RunHistoryItemImpl;

  factory _RunHistoryItem.fromJson(Map<String, dynamic> json) =
      _$RunHistoryItemImpl.fromJson;

  @override
  int get runId;
  @override
  String get kind;
  @override
  String get status;
  @override
  int? get exitCode;
  @override
  int? get durationMs;
  @override
  String get stdout;
  @override
  String get stderr;
  @override
  DateTime get createdAt;

  /// Create a copy of RunHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RunHistoryItemImplCopyWith<_$RunHistoryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VisibleTest _$VisibleTestFromJson(Map<String, dynamic> json) {
  return _VisibleTest.fromJson(json);
}

/// @nodoc
mixin _$VisibleTest {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get stdin => throw _privateConstructorUsedError;
  String get expectedStdout => throw _privateConstructorUsedError;

  /// Serializes this VisibleTest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VisibleTest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VisibleTestCopyWith<VisibleTest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VisibleTestCopyWith<$Res> {
  factory $VisibleTestCopyWith(
    VisibleTest value,
    $Res Function(VisibleTest) then,
  ) = _$VisibleTestCopyWithImpl<$Res, VisibleTest>;
  @useResult
  $Res call({int id, String name, String stdin, String expectedStdout});
}

/// @nodoc
class _$VisibleTestCopyWithImpl<$Res, $Val extends VisibleTest>
    implements $VisibleTestCopyWith<$Res> {
  _$VisibleTestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VisibleTest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? stdin = null,
    Object? expectedStdout = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            stdin: null == stdin
                ? _value.stdin
                : stdin // ignore: cast_nullable_to_non_nullable
                      as String,
            expectedStdout: null == expectedStdout
                ? _value.expectedStdout
                : expectedStdout // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VisibleTestImplCopyWith<$Res>
    implements $VisibleTestCopyWith<$Res> {
  factory _$$VisibleTestImplCopyWith(
    _$VisibleTestImpl value,
    $Res Function(_$VisibleTestImpl) then,
  ) = __$$VisibleTestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, String stdin, String expectedStdout});
}

/// @nodoc
class __$$VisibleTestImplCopyWithImpl<$Res>
    extends _$VisibleTestCopyWithImpl<$Res, _$VisibleTestImpl>
    implements _$$VisibleTestImplCopyWith<$Res> {
  __$$VisibleTestImplCopyWithImpl(
    _$VisibleTestImpl _value,
    $Res Function(_$VisibleTestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VisibleTest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? stdin = null,
    Object? expectedStdout = null,
  }) {
    return _then(
      _$VisibleTestImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        stdin: null == stdin
            ? _value.stdin
            : stdin // ignore: cast_nullable_to_non_nullable
                  as String,
        expectedStdout: null == expectedStdout
            ? _value.expectedStdout
            : expectedStdout // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VisibleTestImpl implements _VisibleTest {
  const _$VisibleTestImpl({
    required this.id,
    required this.name,
    required this.stdin,
    required this.expectedStdout,
  });

  factory _$VisibleTestImpl.fromJson(Map<String, dynamic> json) =>
      _$$VisibleTestImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String stdin;
  @override
  final String expectedStdout;

  @override
  String toString() {
    return 'VisibleTest(id: $id, name: $name, stdin: $stdin, expectedStdout: $expectedStdout)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VisibleTestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.stdin, stdin) || other.stdin == stdin) &&
            (identical(other.expectedStdout, expectedStdout) ||
                other.expectedStdout == expectedStdout));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, stdin, expectedStdout);

  /// Create a copy of VisibleTest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VisibleTestImplCopyWith<_$VisibleTestImpl> get copyWith =>
      __$$VisibleTestImplCopyWithImpl<_$VisibleTestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VisibleTestImplToJson(this);
  }
}

abstract class _VisibleTest implements VisibleTest {
  const factory _VisibleTest({
    required final int id,
    required final String name,
    required final String stdin,
    required final String expectedStdout,
  }) = _$VisibleTestImpl;

  factory _VisibleTest.fromJson(Map<String, dynamic> json) =
      _$VisibleTestImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get stdin;
  @override
  String get expectedStdout;

  /// Create a copy of VisibleTest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VisibleTestImplCopyWith<_$VisibleTestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TestsResponse _$TestsResponseFromJson(Map<String, dynamic> json) {
  return _TestsResponse.fromJson(json);
}

/// @nodoc
mixin _$TestsResponse {
  bool get hasTests => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  List<VisibleTest> get visible => throw _privateConstructorUsedError;

  /// Serializes this TestsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TestsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TestsResponseCopyWith<TestsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestsResponseCopyWith<$Res> {
  factory $TestsResponseCopyWith(
    TestsResponse value,
    $Res Function(TestsResponse) then,
  ) = _$TestsResponseCopyWithImpl<$Res, TestsResponse>;
  @useResult
  $Res call({bool hasTests, int total, List<VisibleTest> visible});
}

/// @nodoc
class _$TestsResponseCopyWithImpl<$Res, $Val extends TestsResponse>
    implements $TestsResponseCopyWith<$Res> {
  _$TestsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TestsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hasTests = null,
    Object? total = null,
    Object? visible = null,
  }) {
    return _then(
      _value.copyWith(
            hasTests: null == hasTests
                ? _value.hasTests
                : hasTests // ignore: cast_nullable_to_non_nullable
                      as bool,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            visible: null == visible
                ? _value.visible
                : visible // ignore: cast_nullable_to_non_nullable
                      as List<VisibleTest>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TestsResponseImplCopyWith<$Res>
    implements $TestsResponseCopyWith<$Res> {
  factory _$$TestsResponseImplCopyWith(
    _$TestsResponseImpl value,
    $Res Function(_$TestsResponseImpl) then,
  ) = __$$TestsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool hasTests, int total, List<VisibleTest> visible});
}

/// @nodoc
class __$$TestsResponseImplCopyWithImpl<$Res>
    extends _$TestsResponseCopyWithImpl<$Res, _$TestsResponseImpl>
    implements _$$TestsResponseImplCopyWith<$Res> {
  __$$TestsResponseImplCopyWithImpl(
    _$TestsResponseImpl _value,
    $Res Function(_$TestsResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TestsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hasTests = null,
    Object? total = null,
    Object? visible = null,
  }) {
    return _then(
      _$TestsResponseImpl(
        hasTests: null == hasTests
            ? _value.hasTests
            : hasTests // ignore: cast_nullable_to_non_nullable
                  as bool,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        visible: null == visible
            ? _value._visible
            : visible // ignore: cast_nullable_to_non_nullable
                  as List<VisibleTest>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TestsResponseImpl implements _TestsResponse {
  const _$TestsResponseImpl({
    required this.hasTests,
    required this.total,
    final List<VisibleTest> visible = const [],
  }) : _visible = visible;

  factory _$TestsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TestsResponseImplFromJson(json);

  @override
  final bool hasTests;
  @override
  final int total;
  final List<VisibleTest> _visible;
  @override
  @JsonKey()
  List<VisibleTest> get visible {
    if (_visible is EqualUnmodifiableListView) return _visible;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_visible);
  }

  @override
  String toString() {
    return 'TestsResponse(hasTests: $hasTests, total: $total, visible: $visible)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestsResponseImpl &&
            (identical(other.hasTests, hasTests) ||
                other.hasTests == hasTests) &&
            (identical(other.total, total) || other.total == total) &&
            const DeepCollectionEquality().equals(other._visible, _visible));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    hasTests,
    total,
    const DeepCollectionEquality().hash(_visible),
  );

  /// Create a copy of TestsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestsResponseImplCopyWith<_$TestsResponseImpl> get copyWith =>
      __$$TestsResponseImplCopyWithImpl<_$TestsResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TestsResponseImplToJson(this);
  }
}

abstract class _TestsResponse implements TestsResponse {
  const factory _TestsResponse({
    required final bool hasTests,
    required final int total,
    final List<VisibleTest> visible,
  }) = _$TestsResponseImpl;

  factory _TestsResponse.fromJson(Map<String, dynamic> json) =
      _$TestsResponseImpl.fromJson;

  @override
  bool get hasTests;
  @override
  int get total;
  @override
  List<VisibleTest> get visible;

  /// Create a copy of TestsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestsResponseImplCopyWith<_$TestsResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TestOutcome _$TestOutcomeFromJson(Map<String, dynamic> json) {
  return _TestOutcome.fromJson(json);
}

/// @nodoc
mixin _$TestOutcome {
  int get testId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get hidden => throw _privateConstructorUsedError;
  bool get passed => throw _privateConstructorUsedError;
  bool get timedOut => throw _privateConstructorUsedError;
  String? get stdin => throw _privateConstructorUsedError;
  String? get expected => throw _privateConstructorUsedError;
  String? get got => throw _privateConstructorUsedError;
  String? get stderr => throw _privateConstructorUsedError;

  /// Serializes this TestOutcome to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TestOutcome
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TestOutcomeCopyWith<TestOutcome> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestOutcomeCopyWith<$Res> {
  factory $TestOutcomeCopyWith(
    TestOutcome value,
    $Res Function(TestOutcome) then,
  ) = _$TestOutcomeCopyWithImpl<$Res, TestOutcome>;
  @useResult
  $Res call({
    int testId,
    String name,
    bool hidden,
    bool passed,
    bool timedOut,
    String? stdin,
    String? expected,
    String? got,
    String? stderr,
  });
}

/// @nodoc
class _$TestOutcomeCopyWithImpl<$Res, $Val extends TestOutcome>
    implements $TestOutcomeCopyWith<$Res> {
  _$TestOutcomeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TestOutcome
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? testId = null,
    Object? name = null,
    Object? hidden = null,
    Object? passed = null,
    Object? timedOut = null,
    Object? stdin = freezed,
    Object? expected = freezed,
    Object? got = freezed,
    Object? stderr = freezed,
  }) {
    return _then(
      _value.copyWith(
            testId: null == testId
                ? _value.testId
                : testId // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            hidden: null == hidden
                ? _value.hidden
                : hidden // ignore: cast_nullable_to_non_nullable
                      as bool,
            passed: null == passed
                ? _value.passed
                : passed // ignore: cast_nullable_to_non_nullable
                      as bool,
            timedOut: null == timedOut
                ? _value.timedOut
                : timedOut // ignore: cast_nullable_to_non_nullable
                      as bool,
            stdin: freezed == stdin
                ? _value.stdin
                : stdin // ignore: cast_nullable_to_non_nullable
                      as String?,
            expected: freezed == expected
                ? _value.expected
                : expected // ignore: cast_nullable_to_non_nullable
                      as String?,
            got: freezed == got
                ? _value.got
                : got // ignore: cast_nullable_to_non_nullable
                      as String?,
            stderr: freezed == stderr
                ? _value.stderr
                : stderr // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TestOutcomeImplCopyWith<$Res>
    implements $TestOutcomeCopyWith<$Res> {
  factory _$$TestOutcomeImplCopyWith(
    _$TestOutcomeImpl value,
    $Res Function(_$TestOutcomeImpl) then,
  ) = __$$TestOutcomeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int testId,
    String name,
    bool hidden,
    bool passed,
    bool timedOut,
    String? stdin,
    String? expected,
    String? got,
    String? stderr,
  });
}

/// @nodoc
class __$$TestOutcomeImplCopyWithImpl<$Res>
    extends _$TestOutcomeCopyWithImpl<$Res, _$TestOutcomeImpl>
    implements _$$TestOutcomeImplCopyWith<$Res> {
  __$$TestOutcomeImplCopyWithImpl(
    _$TestOutcomeImpl _value,
    $Res Function(_$TestOutcomeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TestOutcome
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? testId = null,
    Object? name = null,
    Object? hidden = null,
    Object? passed = null,
    Object? timedOut = null,
    Object? stdin = freezed,
    Object? expected = freezed,
    Object? got = freezed,
    Object? stderr = freezed,
  }) {
    return _then(
      _$TestOutcomeImpl(
        testId: null == testId
            ? _value.testId
            : testId // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        hidden: null == hidden
            ? _value.hidden
            : hidden // ignore: cast_nullable_to_non_nullable
                  as bool,
        passed: null == passed
            ? _value.passed
            : passed // ignore: cast_nullable_to_non_nullable
                  as bool,
        timedOut: null == timedOut
            ? _value.timedOut
            : timedOut // ignore: cast_nullable_to_non_nullable
                  as bool,
        stdin: freezed == stdin
            ? _value.stdin
            : stdin // ignore: cast_nullable_to_non_nullable
                  as String?,
        expected: freezed == expected
            ? _value.expected
            : expected // ignore: cast_nullable_to_non_nullable
                  as String?,
        got: freezed == got
            ? _value.got
            : got // ignore: cast_nullable_to_non_nullable
                  as String?,
        stderr: freezed == stderr
            ? _value.stderr
            : stderr // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TestOutcomeImpl implements _TestOutcome {
  const _$TestOutcomeImpl({
    required this.testId,
    required this.name,
    required this.hidden,
    required this.passed,
    required this.timedOut,
    this.stdin,
    this.expected,
    this.got,
    this.stderr,
  });

  factory _$TestOutcomeImpl.fromJson(Map<String, dynamic> json) =>
      _$$TestOutcomeImplFromJson(json);

  @override
  final int testId;
  @override
  final String name;
  @override
  final bool hidden;
  @override
  final bool passed;
  @override
  final bool timedOut;
  @override
  final String? stdin;
  @override
  final String? expected;
  @override
  final String? got;
  @override
  final String? stderr;

  @override
  String toString() {
    return 'TestOutcome(testId: $testId, name: $name, hidden: $hidden, passed: $passed, timedOut: $timedOut, stdin: $stdin, expected: $expected, got: $got, stderr: $stderr)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestOutcomeImpl &&
            (identical(other.testId, testId) || other.testId == testId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.hidden, hidden) || other.hidden == hidden) &&
            (identical(other.passed, passed) || other.passed == passed) &&
            (identical(other.timedOut, timedOut) ||
                other.timedOut == timedOut) &&
            (identical(other.stdin, stdin) || other.stdin == stdin) &&
            (identical(other.expected, expected) ||
                other.expected == expected) &&
            (identical(other.got, got) || other.got == got) &&
            (identical(other.stderr, stderr) || other.stderr == stderr));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    testId,
    name,
    hidden,
    passed,
    timedOut,
    stdin,
    expected,
    got,
    stderr,
  );

  /// Create a copy of TestOutcome
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestOutcomeImplCopyWith<_$TestOutcomeImpl> get copyWith =>
      __$$TestOutcomeImplCopyWithImpl<_$TestOutcomeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TestOutcomeImplToJson(this);
  }
}

abstract class _TestOutcome implements TestOutcome {
  const factory _TestOutcome({
    required final int testId,
    required final String name,
    required final bool hidden,
    required final bool passed,
    required final bool timedOut,
    final String? stdin,
    final String? expected,
    final String? got,
    final String? stderr,
  }) = _$TestOutcomeImpl;

  factory _TestOutcome.fromJson(Map<String, dynamic> json) =
      _$TestOutcomeImpl.fromJson;

  @override
  int get testId;
  @override
  String get name;
  @override
  bool get hidden;
  @override
  bool get passed;
  @override
  bool get timedOut;
  @override
  String? get stdin;
  @override
  String? get expected;
  @override
  String? get got;
  @override
  String? get stderr;

  /// Create a copy of TestOutcome
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestOutcomeImplCopyWith<_$TestOutcomeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GradeResult _$GradeResultFromJson(Map<String, dynamic> json) {
  return _GradeResult.fromJson(json);
}

/// @nodoc
mixin _$GradeResult {
  int get submissionId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  bool get passed => throw _privateConstructorUsedError;
  int? get score => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  int get percent => throw _privateConstructorUsedError;
  int get testsPassed => throw _privateConstructorUsedError;
  int get testsTotal => throw _privateConstructorUsedError;
  String get feedback => throw _privateConstructorUsedError;
  List<TestOutcome> get outcomes => throw _privateConstructorUsedError;

  /// Serializes this GradeResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GradeResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GradeResultCopyWith<GradeResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GradeResultCopyWith<$Res> {
  factory $GradeResultCopyWith(
    GradeResult value,
    $Res Function(GradeResult) then,
  ) = _$GradeResultCopyWithImpl<$Res, GradeResult>;
  @useResult
  $Res call({
    int submissionId,
    String status,
    bool passed,
    int? score,
    int points,
    int percent,
    int testsPassed,
    int testsTotal,
    String feedback,
    List<TestOutcome> outcomes,
  });
}

/// @nodoc
class _$GradeResultCopyWithImpl<$Res, $Val extends GradeResult>
    implements $GradeResultCopyWith<$Res> {
  _$GradeResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GradeResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? submissionId = null,
    Object? status = null,
    Object? passed = null,
    Object? score = freezed,
    Object? points = null,
    Object? percent = null,
    Object? testsPassed = null,
    Object? testsTotal = null,
    Object? feedback = null,
    Object? outcomes = null,
  }) {
    return _then(
      _value.copyWith(
            submissionId: null == submissionId
                ? _value.submissionId
                : submissionId // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            passed: null == passed
                ? _value.passed
                : passed // ignore: cast_nullable_to_non_nullable
                      as bool,
            score: freezed == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int?,
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as int,
            percent: null == percent
                ? _value.percent
                : percent // ignore: cast_nullable_to_non_nullable
                      as int,
            testsPassed: null == testsPassed
                ? _value.testsPassed
                : testsPassed // ignore: cast_nullable_to_non_nullable
                      as int,
            testsTotal: null == testsTotal
                ? _value.testsTotal
                : testsTotal // ignore: cast_nullable_to_non_nullable
                      as int,
            feedback: null == feedback
                ? _value.feedback
                : feedback // ignore: cast_nullable_to_non_nullable
                      as String,
            outcomes: null == outcomes
                ? _value.outcomes
                : outcomes // ignore: cast_nullable_to_non_nullable
                      as List<TestOutcome>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GradeResultImplCopyWith<$Res>
    implements $GradeResultCopyWith<$Res> {
  factory _$$GradeResultImplCopyWith(
    _$GradeResultImpl value,
    $Res Function(_$GradeResultImpl) then,
  ) = __$$GradeResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int submissionId,
    String status,
    bool passed,
    int? score,
    int points,
    int percent,
    int testsPassed,
    int testsTotal,
    String feedback,
    List<TestOutcome> outcomes,
  });
}

/// @nodoc
class __$$GradeResultImplCopyWithImpl<$Res>
    extends _$GradeResultCopyWithImpl<$Res, _$GradeResultImpl>
    implements _$$GradeResultImplCopyWith<$Res> {
  __$$GradeResultImplCopyWithImpl(
    _$GradeResultImpl _value,
    $Res Function(_$GradeResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GradeResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? submissionId = null,
    Object? status = null,
    Object? passed = null,
    Object? score = freezed,
    Object? points = null,
    Object? percent = null,
    Object? testsPassed = null,
    Object? testsTotal = null,
    Object? feedback = null,
    Object? outcomes = null,
  }) {
    return _then(
      _$GradeResultImpl(
        submissionId: null == submissionId
            ? _value.submissionId
            : submissionId // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        passed: null == passed
            ? _value.passed
            : passed // ignore: cast_nullable_to_non_nullable
                  as bool,
        score: freezed == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int?,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
        percent: null == percent
            ? _value.percent
            : percent // ignore: cast_nullable_to_non_nullable
                  as int,
        testsPassed: null == testsPassed
            ? _value.testsPassed
            : testsPassed // ignore: cast_nullable_to_non_nullable
                  as int,
        testsTotal: null == testsTotal
            ? _value.testsTotal
            : testsTotal // ignore: cast_nullable_to_non_nullable
                  as int,
        feedback: null == feedback
            ? _value.feedback
            : feedback // ignore: cast_nullable_to_non_nullable
                  as String,
        outcomes: null == outcomes
            ? _value._outcomes
            : outcomes // ignore: cast_nullable_to_non_nullable
                  as List<TestOutcome>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GradeResultImpl implements _GradeResult {
  const _$GradeResultImpl({
    required this.submissionId,
    required this.status,
    required this.passed,
    this.score,
    required this.points,
    required this.percent,
    required this.testsPassed,
    required this.testsTotal,
    required this.feedback,
    final List<TestOutcome> outcomes = const [],
  }) : _outcomes = outcomes;

  factory _$GradeResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$GradeResultImplFromJson(json);

  @override
  final int submissionId;
  @override
  final String status;
  @override
  final bool passed;
  @override
  final int? score;
  @override
  final int points;
  @override
  final int percent;
  @override
  final int testsPassed;
  @override
  final int testsTotal;
  @override
  final String feedback;
  final List<TestOutcome> _outcomes;
  @override
  @JsonKey()
  List<TestOutcome> get outcomes {
    if (_outcomes is EqualUnmodifiableListView) return _outcomes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_outcomes);
  }

  @override
  String toString() {
    return 'GradeResult(submissionId: $submissionId, status: $status, passed: $passed, score: $score, points: $points, percent: $percent, testsPassed: $testsPassed, testsTotal: $testsTotal, feedback: $feedback, outcomes: $outcomes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GradeResultImpl &&
            (identical(other.submissionId, submissionId) ||
                other.submissionId == submissionId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.passed, passed) || other.passed == passed) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.percent, percent) || other.percent == percent) &&
            (identical(other.testsPassed, testsPassed) ||
                other.testsPassed == testsPassed) &&
            (identical(other.testsTotal, testsTotal) ||
                other.testsTotal == testsTotal) &&
            (identical(other.feedback, feedback) ||
                other.feedback == feedback) &&
            const DeepCollectionEquality().equals(other._outcomes, _outcomes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    submissionId,
    status,
    passed,
    score,
    points,
    percent,
    testsPassed,
    testsTotal,
    feedback,
    const DeepCollectionEquality().hash(_outcomes),
  );

  /// Create a copy of GradeResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GradeResultImplCopyWith<_$GradeResultImpl> get copyWith =>
      __$$GradeResultImplCopyWithImpl<_$GradeResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GradeResultImplToJson(this);
  }
}

abstract class _GradeResult implements GradeResult {
  const factory _GradeResult({
    required final int submissionId,
    required final String status,
    required final bool passed,
    final int? score,
    required final int points,
    required final int percent,
    required final int testsPassed,
    required final int testsTotal,
    required final String feedback,
    final List<TestOutcome> outcomes,
  }) = _$GradeResultImpl;

  factory _GradeResult.fromJson(Map<String, dynamic> json) =
      _$GradeResultImpl.fromJson;

  @override
  int get submissionId;
  @override
  String get status;
  @override
  bool get passed;
  @override
  int? get score;
  @override
  int get points;
  @override
  int get percent;
  @override
  int get testsPassed;
  @override
  int get testsTotal;
  @override
  String get feedback;
  @override
  List<TestOutcome> get outcomes;

  /// Create a copy of GradeResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GradeResultImplCopyWith<_$GradeResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
