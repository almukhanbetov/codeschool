import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive local preferences ONLY (selected language, theme mode).
/// Never used for tokens or passwords — see [SecureTokenStorage] for that.
class AppPrefs {
  AppPrefs(this._prefs);

  final SharedPreferences _prefs;

  static const _localeKey = 'app_locale';
  static const _themeModeKey = 'app_theme_mode';

  String? get locale => _prefs.getString(_localeKey);
  Future<void> setLocale(String code) => _prefs.setString(_localeKey, code);

  String? get themeMode => _prefs.getString(_themeModeKey);
  Future<void> setThemeMode(String mode) => _prefs.setString(_themeModeKey, mode);
}
