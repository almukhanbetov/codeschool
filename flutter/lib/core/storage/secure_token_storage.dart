import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the refresh token on-device, backed by Android Keystore /
/// iOS Keychain via `flutter_secure_storage` — never plain SharedPreferences,
/// never written to any log.
///
/// ## Why this shape, not "copy the browser's cookie behavior"
/// The web client never sees the refresh token at all: the backend sets it
/// as an `HttpOnly` cookie (`backend/internal/auth/handler.go:setRefreshCookie`),
/// which only a browser's cookie jar can hold — Dio/Flutter has no such jar
/// by default, and building one to *imitate* HttpOnly cookie storage would
/// just move the same secret into a differently-shaped file on disk for no
/// real security benefit on a device that has no other origin to protect
/// against (there is no "other website" that could exfiltrate a cookie the
/// way XSS could in a browser).
///
/// Instead, the mobile client uses the *documented, already-existing*
/// non-browser path in the same handler
/// (`readRefreshToken`: "prefers the HttpOnly cookie, falling back to a
/// refreshToken field in the JSON body for non-browser clients"): on
/// login/refresh, [ApiClient] reads the raw `Set-Cookie` response header,
/// extracts just the `refresh_token=<value>` pair (ignoring the
/// browser-only `HttpOnly`/`Secure`/`SameSite`/`Path` attributes, which mean
/// nothing to a non-browser HTTP client), and this class stores that raw
/// value in the OS-encrypted keystore. `/auth/refresh` and `/auth/logout`
/// then send it back explicitly as `{"refreshToken": "..."}` in the request
/// body — the exact fallback the backend already supports for `curl`/tests.
///
/// The access token is deliberately NOT persisted here (mirrors the web
/// client's `let accessToken` in-memory-only pattern) — it lives only in
/// [ApiClient]'s memory for the life of the process and is re-obtained via
/// a refresh call on cold start (session restore, §4 of the Stage 35 brief).
class SecureTokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  final FlutterSecureStorage _storage;
  static const _refreshTokenKey = 'refresh_token';

  Future<void> saveRefreshToken(String token) => _storage.write(key: _refreshTokenKey, value: token);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> clear() => _storage.delete(key: _refreshTokenKey);
}
