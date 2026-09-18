import '../../../core/network/api_client.dart';
import '../../../shared/models/app_role.dart';
import '../../../shared/models/user.dart';

/// Successful login/register/refresh result — mirrors
/// `backend/internal/auth/dto.go` `AccessResponse`.
class AuthSession {
  const AuthSession({required this.accessToken, required this.expiresIn, required this.user});
  final String accessToken;
  final int expiresIn;
  final AppUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        accessToken: json['accessToken'] as String,
        expiresIn: json['expiresIn'] as int,
        user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
      );
}

/// Talks to POST /auth/register, /auth/login, /auth/logout and GET /me —
/// exactly the routes registered in backend/internal/auth/routes.go and
/// backend/internal/users/routes.go. No client-side JWT handling: the
/// access token lives in [ApiClient], the refresh token in
/// [SecureTokenStorage] — this repository only shapes requests/responses.
class AuthRepository {
  AuthRepository(this._client);
  final ApiClient _client;

  /// [role] must be one of `users.PublicRoles` (student/teacher/parent) —
  /// admin accounts are never created via public registration.
  Future<ApiResult<AppUser>> register({
    String? email,
    String? phone,
    required String password,
    required String firstName,
    String? lastName,
    required AppRole role,
  }) {
    return _client.post<AppUser>(
      '/auth/register',
      auth: false,
      data: {
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'password': password,
        'firstName': firstName,
        if (lastName != null && lastName.isNotEmpty) 'lastName': lastName,
        'role': role.toJson(),
      },
      decode: (json) => AppUser.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Exactly one of [email] / [phone] identifies the account, matching
  /// `LoginRequest` — the login screen enforces this before calling in.
  Future<ApiResult<AuthSession>> login({String? email, String? phone, required String password}) {
    return _client.post<AuthSession>(
      '/auth/login',
      auth: false,
      data: {
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'password': password,
      },
      decode: (json) => AuthSession.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResult<void>> logout() => _client.post<void>('/auth/logout', decode: (_) {});

  Future<ApiResult<AppUser>> me() =>
      _client.get<AppUser>('/me', decode: (json) => AppUser.fromJson(json as Map<String, dynamic>));
}
