import '../../../core/l10n/app_strings.dart';
import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';

/// Maps a real [ApiException] from /auth/register or /auth/login (exact
/// strings from backend/internal/auth/service.go's `validationError(...)`
/// calls and `toAPIError`'s Conflict/Unauthorized branches) to a localized
/// message. Anything not recognized falls back to the server's own message
/// rather than a made-up generic string, so nothing is ever silently wrong.
String authErrorText(AppStrings t, ApiException e) {
  if (e.statusCode == 401) return t('auth.errInvalidCredentials');
  if (e.statusCode == 409) {
    if (e.message.contains('Email')) return t('auth.errEmailTaken');
    if (e.message.contains('Phone')) return t('auth.errPhoneTaken');
  }
  if (e.statusCode == 400) {
    if (e.message.contains('email or a phone')) return t('auth.errNeedEmailOrPhone');
    if (e.message.contains('Password must be')) return t('auth.errPasswordShort');
    if (e.message.contains('First name')) return t('auth.errFirstNameRequired');
  }
  if (e.code == 'NETWORK_ERROR' || e.code == 'TIMEOUT') return apiErrorText(t, e);
  if (e.message.isNotEmpty && e.message != 'unknown_error') return e.message;
  return t('auth.errGeneric');
}
