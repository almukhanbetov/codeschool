/// Mirrors the backend's `httpx` error envelope: `{"error":{"code","message"}}`
/// (backend/internal/httpx/response.go). Every screen renders `message`
/// directly — never a raw stack trace or Dio internals.
class ApiException implements Exception {
  const ApiException({required this.statusCode, required this.code, required this.message});

  final int statusCode;
  final String code;
  final String message;

  factory ApiException.network() =>
      const ApiException(statusCode: 0, code: 'NETWORK_ERROR', message: 'network_error');

  factory ApiException.timeout() =>
      const ApiException(statusCode: 0, code: 'TIMEOUT', message: 'timeout_error');

  factory ApiException.fromResponseBody(int statusCode, Map<String, dynamic>? body) {
    final err = body?['error'];
    if (err is Map<String, dynamic>) {
      return ApiException(
        statusCode: statusCode,
        code: (err['code'] as String?) ?? 'UNKNOWN',
        message: (err['message'] as String?) ?? 'unknown_error',
      );
    }
    return ApiException(statusCode: statusCode, code: 'UNKNOWN', message: 'unknown_error');
  }

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;

  @override
  String toString() => 'ApiException($statusCode, $code, $message)';
}
