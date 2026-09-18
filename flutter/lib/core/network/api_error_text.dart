import '../l10n/app_strings.dart';
import 'api_exception.dart';

/// Generic (non-auth-specific) mapping from a real [ApiException] to a
/// localized message — used by every feature's error state instead of each
/// screen inventing its own copy. Falls back to the server's own message
/// when the status/code isn't one of the common cases, never to a made-up
/// string.
String apiErrorText(AppStrings t, ApiException e) {
  if (e.code == 'NETWORK_ERROR') return t('error.network');
  if (e.code == 'TIMEOUT') return t('error.timeout');
  if (e.isUnauthorized) return t('error.unauthorized');
  if (e.isForbidden) return t('error.forbidden');
  if (e.isNotFound) return t('error.notFound');
  if (e.message.isNotEmpty && e.message != 'unknown_error') return e.message;
  return t('error.unknown');
}
