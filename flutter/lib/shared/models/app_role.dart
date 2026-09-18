/// Mirrors backend/internal/users/model.go — exactly 4 fixed roles, verified
/// against the real CHECK constraint (migration 00006), not invented.
enum AppRole {
  student,
  teacher,
  parent,
  admin;

  static AppRole fromJson(String value) => AppRole.values.firstWhere(
        (r) => r.name == value,
        orElse: () => AppRole.student,
      );

  String toJson() => name;
}
