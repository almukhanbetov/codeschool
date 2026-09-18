import 'app_locale.dart';
import 'translations_en.dart';
import 'translations_kz.dart';
import 'translations_ru.dart';

/// Flat dotted-key translation lookup — the mobile equivalent of the web's
/// `data/translations.ts` `Record<Language, Translations>` tree, but as a
/// simple `Map<String,String>` per locale rather than a huge nested class
/// tree: same content shape (RU/KZ/EN, grouped by feature prefix like
/// `auth.*`, `lesson.*`, `quiz.*`), far less boilerplate to keep growing as
/// screens are added. Access via `t('auth.showPassword')` or the `AppStrings`
/// object handed down by [L10n] (see core/l10n/l10n_scope.dart).
class AppStrings {
  const AppStrings(this.locale);
  final AppLocale locale;

  static const Map<AppLocale, Map<String, String>> _all = {
    AppLocale.ru: translationsRu,
    AppLocale.kz: translationsKz,
    AppLocale.en: translationsEn,
  };

  /// Falls back to the RU string, then to the raw key, so a missing
  /// translation is visibly wrong (the key itself) rather than a blank —
  /// same "never silently empty" principle as the web app.
  String call(String key, [Map<String, String>? params]) {
    var value = _all[locale]?[key] ?? _all[AppLocale.ru]?[key] ?? key;
    if (params != null) {
      for (final entry in params.entries) {
        value = value.replaceAll('{${entry.key}}', entry.value);
      }
    }
    return value;
  }
}
