// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certificate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CertificateCourseRefImpl _$$CertificateCourseRefImplFromJson(
  Map<String, dynamic> json,
) => _$CertificateCourseRefImpl(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
);

Map<String, dynamic> _$$CertificateCourseRefImplToJson(
  _$CertificateCourseRefImpl instance,
) => <String, dynamic>{'id': instance.id, 'title': instance.title};

_$CertificateImpl _$$CertificateImplFromJson(Map<String, dynamic> json) =>
    _$CertificateImpl(
      id: (json['id'] as num).toInt(),
      certificateNumber: json['certificateNumber'] as String,
      verificationCode: json['verificationCode'] as String,
      course: CertificateCourseRef.fromJson(
        json['course'] as Map<String, dynamic>,
      ),
      learnerName: json['learnerName'] as String,
      issuedAt: DateTime.parse(json['issuedAt'] as String),
      completedAt: DateTime.parse(json['completedAt'] as String),
      status: json['status'] as String,
      verifyUrl: json['verifyUrl'] as String,
    );

Map<String, dynamic> _$$CertificateImplToJson(_$CertificateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'certificateNumber': instance.certificateNumber,
      'verificationCode': instance.verificationCode,
      'course': instance.course,
      'learnerName': instance.learnerName,
      'issuedAt': instance.issuedAt.toIso8601String(),
      'completedAt': instance.completedAt.toIso8601String(),
      'status': instance.status,
      'verifyUrl': instance.verifyUrl,
    };
