import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../providers/core_providers.dart';

/// Light/dark toggle (brief §2 "Светлую и тёмную темы") — [themeModeProvider]
/// already drives `MaterialApp.theme`/`darkTheme` (see `app.dart`); this is
/// the first UI control that lets a user actually flip it, rather than only
/// following the OS setting.
class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key, this.color});
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final mode = ref.watch(themeModeProvider);
    final isDark = switch (mode) {
      AppThemeMode.dark => true,
      AppThemeMode.light => false,
      AppThemeMode.system => MediaQuery.platformBrightnessOf(context) == Brightness.dark,
    };

    return IconButton(
      tooltip: isDark ? t('common.themeLight') : t('common.themeDark'),
      icon: Icon(isDark ? LucideIcons.sun : LucideIcons.moon, color: color),
      onPressed: () => ref.read(themeModeProvider.notifier).setMode(isDark ? AppThemeMode.light : AppThemeMode.dark),
    );
  }
}
