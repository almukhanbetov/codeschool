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
import '../application/parent_providers.dart';

/// GET /parent/children/:id — one child's courses (brief §2 "Прогресс
/// каждого ребёнка"). The backend rejects a child id the calling parent
/// doesn't own (RBAC, see [ParentRepository]), so an id-substitution
/// attempt surfaces here as a normal error/empty state, never other
/// people's data.
class ChildOverviewScreen extends ConsumerWidget {
  const ChildOverviewScreen({super.key, required this.childId});
  final int childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final overviewAsync = ref.watch(childOverviewProvider(childId));

    return Scaffold(
      appBar: AppBar(
        title: Text(overviewAsync.valueOrNull?.child.firstName ?? ''),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.activity),
            tooltip: t('parent.overview.activity'),
            onPressed: () => context.push(AppRoutes.parentChildActivityPath(childId)),
          ),
        ],
      ),
      body: overviewAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
          onRetry: () => ref.invalidate(childOverviewProvider(childId)),
        ),
        data: (overview) {
          return RefreshIndicator(
            onRefresh: () => ref.refresh(childOverviewProvider(childId).future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(t('parent.overview.courses'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                if (overview.courses.isEmpty)
                  EmptyView(message: t('common.emptyGeneric'), icon: LucideIcons.bookOpen)
                else
                  for (final c in overview.courses) _CourseCard(childId: childId, item: c),
                const SizedBox(height: 20),
                _CertificatesUnavailableCard(t: t),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.childId, required this.item});
  final int childId;
  final ParentChildCourseProgress item;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => context.push(AppRoutes.parentChildCourseDetailPath(childId, item.course.id)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(item.course.title, style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Chip(label: Text(item.enrollmentStatus), visualDensity: VisualDensity.compact),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(value: item.progress.progressPercent / 100, minHeight: 6),
              ),
              const SizedBox(height: 6),
              Text('${item.progress.progressPercent}% · ${item.progress.completedLessons}/${item.progress.totalLessons}', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _CertificatesUnavailableCard extends StatelessWidget {
  const _CertificatesUnavailableCard({required this.t});
  final dynamic t;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(LucideIcons.award, color: Theme.of(context).colorScheme.outline),
            const SizedBox(width: 10),
            Expanded(child: Text(t('parent.certificatesUnavailable'), style: Theme.of(context).textTheme.bodySmall)),
          ],
        ),
      ),
    );
  }
}
