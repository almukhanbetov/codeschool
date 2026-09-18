enum AppLocale {
  ru('ru', 'Русский'),
  kz('kz', 'Қазақша'),
  en('en', 'English');

  const AppLocale(this.code, this.label);
  final String code;
  final String label;

  static AppLocale fromCode(String code) =>
      AppLocale.values.firstWhere((l) => l.code == code, orElse: () => AppLocale.ru);
}
