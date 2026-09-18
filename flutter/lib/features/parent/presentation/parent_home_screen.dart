import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/models/parent.dart';
import '../../../shared/models/user.dart';
import '../application/parent_providers.dart';

/// The real parent cabinet (brief §2, Stage 35G) — GET /parent/children.
/// Only the parent's own linked children ever appear here; the backend's
/// own JWT-derived parent id is the access boundary (brief §2 "родитель
/// должен видеть только собственных привязанных детей"), never a
/// client-supplied filter.
class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key, required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final childrenAsync = ref.watch(parentChildrenProvider);

    return childrenAsync.when(
      loading: () => const LoadingView(),
      error: (err, _) => ErrorView(
        message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
        onRetry: () => ref.invalidate(parentChildrenProvider),
      ),
      data: (children) {
        if (children.isEmpty) {
          return EmptyView(message: t('parent.children.empty'), icon: LucideIcons.users);
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(parentChildrenProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                t('home.parent.welcome'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Text(t('parent.children.title'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              for (final c in children) _ChildCard(item: c, t: t),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(LucideIcons.info, size: 16, color: Theme.of(context).colorScheme.outline),
                      const SizedBox(width: 8),
                      Expanded(child: Text(t('parent.readOnlyNotice'), style: Theme.of(context).textTheme.bodySmall)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.item, required this.t});
  final ParentChildListItem item;
  final dynamic t;

  @override
  Widget build(BuildContext context) {
    final name = '${item.child.firstName} ${item.child.lastName ?? ''}'.trim();
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push(AppRoutes.parentChildDetailPath(item.child.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(child: Text(item.child.firstName.isNotEmpty ? item.child.firstName[0].toUpperCase() : '?')),
                  const SizedBox(width: 12),
                  Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700))),
                  Text('${item.overallProgressPercent}%', style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(value: item.overallProgressPercent / 100, minHeight: 6),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('${item.coursesCount} ${t('parent.children.courses')}', style: Theme.of(context).textTheme.bodySmall),
                  if (item.pendingReview > 0) ...[
                    const SizedBox(width: 10),
                    Chip(label: Text('${item.pendingReview} ${t('parent.children.pendingReview')}'), visualDensity: VisualDensity.compact),
                  ],
                  if (item.needsWork > 0) ...[
                    const SizedBox(width: 10),
                    Chip(
                      label: Text('${item.needsWork} ${t('parent.children.needsWork')}'),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Theme.of(context).colorScheme.errorContainer,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
