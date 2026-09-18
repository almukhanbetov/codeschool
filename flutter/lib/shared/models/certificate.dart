import 'package:freezed_annotation/freezed_annotation.dart';

part 'certificate.freezed.dart';
part 'certificate.g.dart';

@freezed
abstract class CertificateCourseRef with _$CertificateCourseRef {
  const factory CertificateCourseRef({required int id, required String title}) = _CertificateCourseRef;
  factory CertificateCourseRef.fromJson(Map<String, dynamic> json) => _$CertificateCourseRefFromJson(json);
}

/// Mirrors backend/internal/certificates/dto.go response shape.
/// `status` is 'active' | 'revoked' (migration 00026 CHECK constraint).
@freezed
abstract class Certificate with _$Certificate {
  const factory Certificate({
    required int id,
    required String certificateNumber,
    required String verificationCode,
    required CertificateCourseRef course,
    required String learnerName,
    required DateTime issuedAt,
    required DateTime completedAt,
    required String status,
    required String verifyUrl,
  }) = _Certificate;
  factory Certificate.fromJson(Map<String, dynamic> json) => _$CertificateFromJson(json);
}
