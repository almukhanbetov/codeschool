import 'package:freezed_annotation/freezed_annotation.dart';
import 'app_role.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Mirrors backend/internal/users/dto.go `Response` exactly — every field
/// name matches the real JSON tags, nothing invented.
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required int id,
    String? email,
    String? phone,
    required String firstName,
    String? lastName,
    required AppRole role,
    required bool isActive,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}

extension AppUserX on AppUser {
  String get displayName => lastName != null ? '$firstName $lastName' : firstName;
}
