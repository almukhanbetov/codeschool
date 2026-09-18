import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/state_views.dart';
import '../application/catalog_providers.dart';
import 'course_card.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final coursesAsync = ref.watch(filteredCoursesProvider);
    final ageFilter = ref.watch(catalogAgeFilterProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t('catalog.title'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => ref.read(catalogSearchProvider.notifier).setQuery(v),
              decoration: InputDecoration(
                hintText: t('catalog.search'),
                prefixIcon: const Icon(LucideIcons.search),
                isDense: true,
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: AgeRange.options.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final range = AgeRange.options[i];
                final selected = range == ageFilter;
                return ChoiceChip(
                  label: Text(t(range.labelKey)),
                  selected: selected,
                  onSelected: (_) => ref.read(catalogAgeFilterProvider.notifier).setRange(range),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: coursesAsync.when(
              loading: () => const LoadingView(),
              error: (err, _) => ErrorView(
                message: err is ApiException ? apiErrorText(t, err) : t('catalog.loadError'),
                onRetry: () => ref.invalidate(coursesProvider),
              ),
              data: (courses) {
                if (courses.isEmpty) {
                  return EmptyView(message: t('catalog.empty'), icon: LucideIcons.bookOpen);
                }
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(coursesProvider.future),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: courses.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final course = courses[i];
                      return CourseCard(
                        course: course,
                        onTap: () => context.push(AppRoutes.courseDetailPath(course.id)),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
