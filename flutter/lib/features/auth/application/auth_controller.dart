import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/models/app_role.dart';
import '../../../shared/models/user.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(apiClientProvider)));

/// Single source of truth for "who is signed in": `null` = unauthenticated,
/// non-null = the current user. Loading/error states surface the cold-start
/// session restore (refresh token -> access token -> GET /me); a failed
/// login/register does NOT put this provider into an error state — it stays
/// `AsyncData(null)` and the screen shows the failure via the returned
/// [ApiResult] instead, so one bad login attempt can't look like "the whole
/// app's session is broken".
class AuthController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    // Reacts to session loss from anywhere else in the app (a 401 during an
    // unrelated request triggers ApiClient's onSessionExpired callback).
    ref.listen(sessionExpiredTickProvider, (prev, next) {
      if (prev != null && next != prev) state = const AsyncData(null);
    });

    final client = ref.watch(apiClientProvider);
    final restored = await client.restoreSession();
    if (!restored) return null;

    final meResult = await ref.read(authRepositoryProvider).me();
    return switch (meResult) {
      ApiOk(:final data) => data,
      ApiErr() => null,
    };
  }

  Future<ApiResult<AppUser>> login({String? email, String? phone, required String password}) async {
    final result = await ref.read(authRepositoryProvider).login(email: email, phone: phone, password: password);
    switch (result) {
      case ApiOk(:final data):
        ref.read(apiClientProvider).setAccessToken(data.accessToken);
        state = AsyncData(data.user);
        return ApiResult.ok(data.user);
      case ApiErr(:final error):
        return ApiResult.err(error);
    }
  }

  Future<ApiResult<AppUser>> register({
    String? email,
    String? phone,
    required String password,
    required String firstName,
    String? lastName,
    required AppRole role,
  }) async {
    final result = await ref.read(authRepositoryProvider).register(
          email: email,
          phone: phone,
          password: password,
          firstName: firstName,
          lastName: lastName,
          role: role,
        );
    if (result is! ApiOk<AppUser>) return result;
    // Registration doesn't log the user in (no tokens are issued by
    // POST /auth/register per the backend) — sign in right after so the
    // user doesn't have to re-enter their credentials.
    return login(email: email, phone: phone, password: password);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    await ref.read(apiClientProvider).clearSession();
    state = const AsyncData(null);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);
