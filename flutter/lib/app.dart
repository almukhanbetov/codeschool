import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/core_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class CodeschoolApp extends ConsumerWidget {
  const CodeschoolApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'CodeSchool.kz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: switch (themeMode) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.system => ThemeMode.system,
      },
      routerConfig: router,
      // Kazakh's ISO 639-1 code is 'kk'; AppLocale.kz keeps 'kz' internally
      // (matches the web app's URL/query-param convention) so it's mapped
      // here only for the platform Locale Flutter's own widgets consume.
      locale: Locale(locale.code == 'kz' ? 'kk' : locale.code),
      supportedLocales: const [Locale('ru'), Locale('kk'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // System text-scaling stays on (brief §3): no MediaQuery override here.
      builder: (context, child) => child ?? const SizedBox.shrink(),
    );
  }
}
