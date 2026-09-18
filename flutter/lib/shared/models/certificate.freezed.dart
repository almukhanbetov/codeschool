// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'certificate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CertificateCourseRef _$CertificateCourseRefFromJson(Map<String, dynamic> json) {
  return _CertificateCourseRef.fromJson(json);
}

/// @nodoc
mixin _$CertificateCourseRef {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;

  /// Serializes this CertificateCourseRef to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CertificateCourseRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CertificateCourseRefCopyWith<CertificateCourseRef> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CertificateCourseRefCopyWith<$Res> {
  factory $CertificateCourseRefCopyWith(
    CertificateCourseRef value,
    $Res Function(CertificateCourseRef) then,
  ) = _$CertificateCourseRefCopyWithImpl<$Res, CertificateCourseRef>;
  @useResult
  $Res call({int id, String title});
}

/// @nodoc
class _$CertificateCourseRefCopyWithImpl<
  $Res,
  $Val extends CertificateCourseRef
>
    implements $CertificateCourseRefCopyWith<$Res> {
  _$CertificateCourseRefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CertificateCourseRef
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
abstract class _$$CertificateCourseRefImplCopyWith<$Res>
    implements $CertificateCourseRefCopyWith<$Res> {
  factory _$$CertificateCourseRefImplCopyWith(
    _$CertificateCourseRefImpl value,
    $Res Function(_$CertificateCourseRefImpl) then,
  ) = __$$CertificateCourseRefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String title});
}

/// @nodoc
class __$$CertificateCourseRefImplCopyWithImpl<$Res>
    extends _$CertificateCourseRefCopyWithImpl<$Res, _$CertificateCourseRefImpl>
    implements _$$CertificateCourseRefImplCopyWith<$Res> {
  __$$CertificateCourseRefImplCopyWithImpl(
    _$CertificateCourseRefImpl _value,
    $Res Function(_$CertificateCourseRefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CertificateCourseRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? title = null}) {
    return _then(
      _$CertificateCourseRefImpl(
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
class _$CertificateCourseRefImpl implements _CertificateCourseRef {
  const _$CertificateCourseRefImpl({required this.id, required this.title});

  factory _$CertificateCourseRefImpl.fromJson(Map<String, dynamic> json) =>
      _$$CertificateCourseRefImplFromJson(json);

  @override
  final int id;
  @override
  final String title;

  @override
  String toString() {
    return 'CertificateCourseRef(id: $id, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CertificateCourseRefImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title);

  /// Create a copy of CertificateCourseRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CertificateCourseRefImplCopyWith<_$CertificateCourseRefImpl>
  get copyWith =>
      __$$CertificateCourseRefImplCopyWithImpl<_$CertificateCourseRefImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CertificateCourseRefImplToJson(this);
  }
}

abstract class _CertificateCourseRef implements CertificateCourseRef {
  const factory _CertificateCourseRef({
    required final int id,
    required final String title,
  }) = _$CertificateCourseRefImpl;

  factory _CertificateCourseRef.fromJson(Map<String, dynamic> json) =
      _$CertificateCourseRefImpl.fromJson;

  @override
  int get id;
  @override
  String get title;

  /// Create a copy of CertificateCourseRef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CertificateCourseRefImplCopyWith<_$CertificateCourseRefImpl>
  get copyWith => throw _privateConstructorUsedError;
}

Certificate _$CertificateFromJson(Map<String, dynamic> json) {
  return _Certificate.fromJson(json);
}

/// @nodoc
mixin _$Certificate {
  int get id => throw _privateConstructorUsedError;
  String get certificateNumber => throw _privateConstructorUsedError;
  String get verificationCode => throw _privateConstructorUsedError;
  CertificateCourseRef get course => throw _privateConstructorUsedError;
  String get learnerName => throw _privateConstructorUsedError;
  DateTime get issuedAt => throw _privateConstructorUsedError;
  DateTime get completedAt => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get verifyUrl => throw _privateConstructorUsedError;

  /// Serializes this Certificate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Certificate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CertificateCopyWith<Certificate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CertificateCopyWith<$Res> {
  factory $CertificateCopyWith(
    Certificate value,
    $Res Function(Certificate) then,
  ) = _$CertificateCopyWithImpl<$Res, Certificate>;
  @useResult
  $Res call({
    int id,
    String certificateNumber,
    String verificationCode,
    CertificateCourseRef course,
    String learnerName,
    DateTime issuedAt,
    DateTime completedAt,
    String status,
    String verifyUrl,
  });

  $CertificateCourseRefCopyWith<$Res> get course;
}

/// @nodoc
class _$CertificateCopyWithImpl<$Res, $Val extends Certificate>
    implements $CertificateCopyWith<$Res> {
  _$CertificateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Certificate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? certificateNumber = null,
    Object? verificationCode = null,
    Object? course = null,
    Object? learnerName = null,
    Object? issuedAt = null,
    Object? completedAt = null,
    Object? status = null,
    Object? verifyUrl = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            certificateNumber: null == certificateNumber
                ? _value.certificateNumber
                : certificateNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            verificationCode: null == verificationCode
                ? _value.verificationCode
                : verificationCode // ignore: cast_nullable_to_non_nullable
                      as String,
            course: null == course
                ? _value.course
                : course // ignore: cast_nullable_to_non_nullable
                      as CertificateCourseRef,
            learnerName: null == learnerName
                ? _value.learnerName
                : learnerName // ignore: cast_nullable_to_non_nullable
                      as String,
            issuedAt: null == issuedAt
                ? _value.issuedAt
                : issuedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            completedAt: null == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            verifyUrl: null == verifyUrl
                ? _value.verifyUrl
                : verifyUrl // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of Certificate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CertificateCourseRefCopyWith<$Res> get course {
    return $CertificateCourseRefCopyWith<$Res>(_value.course, (value) {
      return _then(_value.copyWith(course: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CertificateImplCopyWith<$Res>
    implements $CertificateCopyWith<$Res> {
  factory _$$CertificateImplCopyWith(
    _$CertificateImpl value,
    $Res Function(_$CertificateImpl) then,
  ) = __$$CertificateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String certificateNumber,
    String verificationCode,
    CertificateCourseRef course,
    String learnerName,
    DateTime issuedAt,
    DateTime completedAt,
    String status,
    String verifyUrl,
  });

  @override
  $CertificateCourseRefCopyWith<$Res> get course;
}

/// @nodoc
class __$$CertificateImplCopyWithImpl<$Res>
    extends _$CertificateCopyWithImpl<$Res, _$CertificateImpl>
    implements _$$CertificateImplCopyWith<$Res> {
  __$$CertificateImplCopyWithImpl(
    _$CertificateImpl _value,
    $Res Function(_$CertificateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Certificate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? certificateNumber = null,
    Object? verificationCode = null,
    Object? course = null,
    Object? learnerName = null,
    Object? issuedAt = null,
    Object? completedAt = null,
    Object? status = null,
    Object? verifyUrl = null,
  }) {
    return _then(
      _$CertificateImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        certificateNumber: null == certificateNumber
            ? _value.certificateNumber
            : certificateNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        verificationCode: null == verificationCode
            ? _value.verificationCode
            : verificationCode // ignore: cast_nullable_to_non_nullable
                  as String,
        course: null == course
            ? _value.course
            : course // ignore: cast_nullable_to_non_nullable
                  as CertificateCourseRef,
        learnerName: null == learnerName
            ? _value.learnerName
            : learnerName // ignore: cast_nullable_to_non_nullable
                  as String,
        issuedAt: null == issuedAt
            ? _value.issuedAt
            : issuedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        completedAt: null == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        verifyUrl: null == verifyUrl
            ? _value.verifyUrl
            : verifyUrl // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CertificateImpl implements _Certificate {
  const _$CertificateImpl({
    required this.id,
    required this.certificateNumber,
    required this.verificationCode,
    required this.course,
    required this.learnerName,
    required this.issuedAt,
    required this.completedAt,
    required this.status,
    required this.verifyUrl,
  });

  factory _$CertificateImpl.fromJson(Map<String, dynamic> json) =>
      _$$CertificateImplFromJson(json);

  @override
  final int id;
  @override
  final String certificateNumber;
  @override
  final String verificationCode;
  @override
  final CertificateCourseRef course;
  @override
  final String learnerName;
  @override
  final DateTime issuedAt;
  @override
  final DateTime completedAt;
  @override
  final String status;
  @override
  final String verifyUrl;

  @override
  String toString() {
    return 'Certificate(id: $id, certificateNumber: $certificateNumber, verificationCode: $verificationCode, course: $course, learnerName: $learnerName, issuedAt: $issuedAt, completedAt: $completedAt, status: $status, verifyUrl: $verifyUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CertificateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.certificateNumber, certificateNumber) ||
                other.certificateNumber == certificateNumber) &&
            (identical(other.verificationCode, verificationCode) ||
                other.verificationCode == verificationCode) &&
            (identical(other.course, course) || other.course == course) &&
            (identical(other.learnerName, learnerName) ||
                other.learnerName == learnerName) &&
            (identical(other.issuedAt, issuedAt) ||
                other.issuedAt == issuedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.verifyUrl, verifyUrl) ||
                other.verifyUrl == verifyUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    certificateNumber,
    verificationCode,
    course,
    learnerName,
    issuedAt,
    completedAt,
    status,
    verifyUrl,
  );

  /// Create a copy of Certificate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CertificateImplCopyWith<_$CertificateImpl> get copyWith =>
      __$$CertificateImplCopyWithImpl<_$CertificateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CertificateImplToJson(this);
  }
}

abstract class _Certificate implements Certificate {
  const factory _Certificate({
    required final int id,
    required final String certificateNumber,
    required final String verificationCode,
    required final CertificateCourseRef course,
    required final String learnerName,
    required final DateTime issuedAt,
    required final DateTime completedAt,
    required final String status,
    required final String verifyUrl,
  }) = _$CertificateImpl;

  factory _Certificate.fromJson(Map<String, dynamic> json) =
      _$CertificateImpl.fromJson;

  @override
  int get id;
  @override
  String get certificateNumber;
  @override
  String get verificationCode;
  @override
  CertificateCourseRef get course;
  @override
  String get learnerName;
  @override
  DateTime get issuedAt;
  @override
  DateTime get completedAt;
  @override
  String get status;
  @override
  String get verifyUrl;

  /// Create a copy of Certificate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CertificateImplCopyWith<_$CertificateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
