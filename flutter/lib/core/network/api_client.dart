import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_env.dart';
import '../storage/secure_token_storage.dart';
import 'api_exception.dart';

/// Fires whenever the session is conclusively lost (refresh failed / logout)
/// so the UI layer (router redirect) can react without ApiClient depending
/// on Riverpod or navigation directly.
typedef SessionExpiredCallback = void Function();

/// Central Dio-based API client — the *only* place in the app that talks
/// HTTP. Screens/repositories never construct their own Dio instance, so
/// timeouts, auth headers, refresh-on-401 and error mapping are handled in
/// exactly one place (Stage 35 brief §2: "централизованный API client").
class ApiClient {
  ApiClient({required this.env, required this.tokenStorage, this.onSessionExpired}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
        validateStatus: (_) => true, // we classify status codes ourselves below
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null && options.extra['auth'] != false) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          handler.next(options);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: false, // request bodies can contain passwords — never logged
          responseBody: false,
          logPrint: (obj) => debugPrint('[dio] $obj'),
        ),
      );
    }
  }

  final AppEnv env;
  final SecureTokenStorage tokenStorage;
  final SessionExpiredCallback? onSessionExpired;

  late final Dio _dio;
  String? _accessToken;
  Completer<bool>? _refreshInFlight;

  String? get accessToken => _accessToken;

  void setAccessToken(String? token) => _accessToken = token;

  /// Attempts to restore a session on cold start using the persisted
  /// refresh token (Stage 35 brief §4: "восстановление сессии после
  /// перезапуска"). Returns true if a fresh access token was obtained.
  Future<bool> restoreSession() async {
    final refreshToken = await tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;
    return _refresh(refreshToken);
  }

  Future<bool> _refresh(String refreshToken) async {
    if (_refreshInFlight != null) return _refreshInFlight!.future;
    final completer = Completer<bool>();
    _refreshInFlight = completer;
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(extra: {'auth': false}),
      );
      if (response.statusCode == 200) {
        final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
        _accessToken = data['accessToken'] as String;
        final newRefresh = _extractRefreshTokenCookie(response);
        if (newRefresh != null) await tokenStorage.saveRefreshToken(newRefresh);
        completer.complete(true);
        return true;
      }
      await _clearSession();
      completer.complete(false);
      return false;
    } catch (_) {
      await _clearSession();
      completer.complete(false);
      return false;
    } finally {
      _refreshInFlight = null;
    }
  }

  /// Public wrapper around [_clearSession] for explicit user-initiated
  /// logout (as opposed to the internal 401/refresh-failure path).
  Future<void> clearSession() => _clearSession();

  Future<void> _clearSession() async {
    _accessToken = null;
    await tokenStorage.clear();
    onSessionExpired?.call();
  }

  /// The backend sets the refresh token only via `Set-Cookie` (never in the
  /// JSON body — see SecureTokenStorage's doc comment for why). Dio exposes
  /// raw response headers, so we parse just the `refresh_token=<value>` pair
  /// ourselves; the HttpOnly/Secure/SameSite/Path attributes are meaningless
  /// outside a browser cookie jar and are discarded.
  String? _extractRefreshTokenCookie(Response response) {
    final setCookieHeaders = response.headers['set-cookie'];
    if (setCookieHeaders == null) return null;
    for (final header in setCookieHeaders) {
      final match = RegExp(r'refresh_token=([^;]+)').firstMatch(header);
      if (match != null) return match.group(1);
    }
    return null;
  }

  Future<ApiResult<T>> request<T>(
    String method,
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool auth = true,
    T Function(dynamic json)? decode,
  }) async {
    try {
      var response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method, extra: {'auth': auth}),
      );

      if (response.statusCode == 401 && auth) {
        final refreshToken = await tokenStorage.readRefreshToken();
        final refreshed = refreshToken != null && await _refresh(refreshToken);
        if (refreshed) {
          response = await _dio.request(
            path,
            data: data,
            queryParameters: queryParameters,
            options: Options(method: method, extra: {'auth': auth}),
          );
        }
      }

      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300) {
        final body = response.data;
        final payload = body is Map<String, dynamic> ? body['data'] : body;
        if (response.headers['set-cookie'] != null && path == '/auth/login') {
          final refresh = _extractRefreshTokenCookie(response);
          if (refresh != null) await tokenStorage.saveRefreshToken(refresh);
        }
        return ApiResult.ok(decode != null ? decode(payload) : payload as T, meta: (body is Map<String, dynamic>) ? body['meta'] as Map<String, dynamic>? : null);
      }

      if (status == 401) {
        await _clearSession();
      }
      return ApiResult.err(ApiException.fromResponseBody(status, response.data as Map<String, dynamic>?));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return ApiResult.err(ApiException.timeout());
      }
      return ApiResult.err(ApiException.network());
    }
  }

  Future<ApiResult<T>> get<T>(String path, {Map<String, dynamic>? query, T Function(dynamic)? decode, bool auth = true}) =>
      request('GET', path, queryParameters: query, decode: decode, auth: auth);

  Future<ApiResult<T>> post<T>(String path, {Map<String, dynamic>? data, T Function(dynamic)? decode, bool auth = true}) =>
      request('POST', path, data: data, decode: decode, auth: auth);

  Future<ApiResult<T>> put<T>(String path, {Map<String, dynamic>? data, T Function(dynamic)? decode, bool auth = true}) =>
      request('PUT', path, data: data, decode: decode, auth: auth);

  Future<ApiResult<T>> patch<T>(String path, {Map<String, dynamic>? data, T Function(dynamic)? decode, bool auth = true}) =>
      request('PATCH', path, data: data, decode: decode, auth: auth);

  Future<ApiResult<T>> delete<T>(String path, {Map<String, dynamic>? data, T Function(dynamic)? decode, bool auth = true}) =>
      request('DELETE', path, data: data, decode: decode, auth: auth);

  /// Raw Dio access for the one case that isn't JSON: downloading a
  /// certificate PDF (progress/certificates feature).
  Dio get raw => _dio;
}

/// A simple ok/err result so screens branch on outcome instead of catching
/// exceptions everywhere (loading/error/empty states, brief §3).
sealed class ApiResult<T> {
  const ApiResult();
  factory ApiResult.ok(T data, {Map<String, dynamic>? meta}) = ApiOk<T>;
  factory ApiResult.err(ApiException error) = ApiErr<T>;
}

class ApiOk<T> extends ApiResult<T> {
  const ApiOk(this.data, {this.meta});
  final T data;
  final Map<String, dynamic>? meta;
}

class ApiErr<T> extends ApiResult<T> {
  const ApiErr(this.error);
  final ApiException error;
}
