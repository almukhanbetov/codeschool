import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_env.dart';
import '../l10n/app_locale.dart';
import '../l10n/app_strings.dart';
import '../network/api_client.dart';
import '../storage/app_prefs.dart';
import '../storage/secure_token_storage.dart';

/// [SharedPreferences] is resolved once in `main()` and injected via
/// `ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(...)])`
/// — every other provider below can stay synchronous.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

final appPrefsProvider = Provider<AppPrefs>((ref) => AppPrefs(ref.watch(sharedPreferencesProvider)));

final appEnvProvider = Provider<AppEnv>((ref) => AppEnv.resolve());

final secureTokenStorageProvider = Provider<SecureTokenStorage>((ref) => SecureTokenStorage());

/// Bumped whenever the session is forcibly cleared (refresh failure) so
/// [authStateProvider] (features/auth) can react and the router can redirect
/// to /login — ApiClient itself has no notion of Riverpod or navigation.
final sessionExpiredTickProvider = StateProvider<int>((ref) => 0);

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(
    env: ref.watch(appEnvProvider),
    tokenStorage: ref.watch(secureTokenStorageProvider),
    onSessionExpired: () => ref.read(sessionExpiredTickProvider.notifier).state++,
  );
  return client;
});

class LocaleNotifier extends Notifier<AppLocale> {
  @override
  AppLocale build() {
    final saved = ref.read(appPrefsProvider).locale;
    return saved != null ? AppLocale.fromCode(saved) : AppLocale.ru;
  }

  void setLocale(AppLocale locale) {
    state = locale;
    ref.read(appPrefsProvider).setLocale(locale.code);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, AppLocale>(LocaleNotifier.new);

final appStringsProvider = Provider<AppStrings>((ref) => AppStrings(ref.watch(localeProvider)));

enum AppThemeMode { light, dark, system }

class ThemeModeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() {
    final saved = ref.read(appPrefsProvider).themeMode;
    return switch (saved) {
      'light' => AppThemeMode.light,
      'dark' => AppThemeMode.dark,
      _ => AppThemeMode.system,
    };
  }

  void setMode(AppThemeMode mode) {
    state = mode;
    ref.read(appPrefsProvider).setThemeMode(mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, AppThemeMode>(ThemeModeNotifier.new);
