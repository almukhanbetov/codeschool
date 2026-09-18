import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../l10n/app_locale.dart';
import '../providers/core_providers.dart';

/// RU/KZ/EN switcher (brief §2 "Переключение RU/KZ/EN") — [localeProvider]
/// already drives every screen's strings and persists via [AppPrefs]; this
/// is just the first UI control that lets a user actually change it.
class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key, this.color});
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final current = ref.watch(localeProvider);

    return PopupMenuButton<AppLocale>(
      tooltip: t('common.language'),
      initialValue: current,
      onSelected: (locale) => ref.read(localeProvider.notifier).setLocale(locale),
      itemBuilder: (context) => [
        for (final locale in AppLocale.values)
          PopupMenuItem(value: locale, child: Text(locale.label)),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.languages, size: 18, color: color),
            const SizedBox(width: 4),
            Text(current.code.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
