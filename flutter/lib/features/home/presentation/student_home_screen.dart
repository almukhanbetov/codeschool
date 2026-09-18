import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/models/certificate.dart';
import '../../../shared/models/enrollment.dart';
import '../../../shared/models/progress.dart';
import '../../../shared/models/user.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../certificates/application/certificate_providers.dart';
import '../../progress/application/progress_providers.dart';

/// The real student cabinet (brief §2) — replaces the Stage 35C placeholder
/// welcome screen. Every number shown (percent, completed lessons,
/// certificates) comes from the backend (`GET /me/courses`, `GET
/// /me/progress`, `GET /me/certificates`) — nothing is computed or cached
/// only on the client, so it stays correct after logout/login (brief §1).
class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key, required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final coursesAsync = ref.watch(myCoursesProvider);

    return coursesAsync.when(
      loading: () => const LoadingView(),
      error: (err, _) => ErrorView(
        message: err is ApiException ? apiErrorText(t, err) : t('home.student.loadError'),
        onRetry: () => ref.invalidate(myCoursesProvider),
      ),
      data: (courses) {
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myCoursesProvider);
            ref.invalidate(myProgressListProvider);
            ref.invalidate(myCertificatesProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                t('home.student.welcome', {'name': user.firstName}),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              Text(t('home.student.myCourses'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (courses.isEmpty)
                _NoCoursesCard(t: t)
              else ...[
                _CourseList(courses: courses),
                const SizedBox(height: 12),
                _RecentAssignmentsSection(courses: courses),
              ],
              const SizedBox(height: 24),
              _CertificatesSection(t: t),
            ],
          ),
        );
      },
    );
  }
}

class _NoCoursesCard extends StatelessWidget {
  const _NoCoursesCard({required this.t});
  final dynamic t;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(LucideIcons.bookOpen, size: 36, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(t('home.student.noCourses'), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.catalog),
              icon: const Icon(LucideIcons.bookOpen),
              label: Text(t('home.student.browseCatalog')),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseList extends ConsumerWidget {
  const _CourseList({required this.courses});
  final List<MyCourseItem> courses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(myProgressListProvider);
    final progressByCourse = progressAsync.valueOrNull != null
        ? {for (final p in progressAsync.valueOrNull!) p.courseId: p}
        : <int, CourseProgress>{};

    return Column(
      children: courses.map((item) => _CourseCard(item: item, progress: progressByCourse[item.course.id])).toList(),
    );
  }
}

class _CourseCard extends ConsumerWidget {
  const _CourseCard({required this.item, required this.progress});
  final MyCourseItem item;
  final CourseProgress? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark ? AppColors.gradientDark : AppColors.gradientLight;
    final percent = progress?.progressPercent ?? 0;
    final completed = item.status == 'completed';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.courseProgressPath(item.course.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(LucideIcons.bookOpen, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(item.course.title, style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                  if (completed) Icon(LucideIcons.circleCheck, color: Theme.of(context).colorScheme.tertiary),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(value: percent / 100, minHeight: 8),
              ),
              const SizedBox(height: 6),
              Text('$percent% · ${item.course.durationLessons ?? '—'} ${t('catalog.lessons')}', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.courseProgressPath(item.course.id)),
                icon: const Icon(LucideIcons.play, size: 16),
                label: Text(t('home.student.continueCourse')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bounded to just the first in-progress course (not every enrolled course)
/// so the home screen doesn't fan out N assignment-history requests per
/// card — see `courseAssignmentHistoryProvider`'s own doc comment.
class _RecentAssignmentsSection extends ConsumerWidget {
  const _RecentAssignmentsSection({required this.courses});
  final List<MyCourseItem> courses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final progressAsync = ref.watch(myProgressListProvider);
    final progressList = progressAsync.valueOrNull;
    if (progressList == null) return const SizedBox.shrink();

    MyCourseItem? active;
    for (final c in courses) {
      CourseProgress? p;
      for (final entry in progressList) {
        if (entry.courseId == c.course.id) {
          p = entry;
          break;
        }
      }
      if (p != null && p.progressPercent > 0 && p.progressPercent < 100) {
        active = c;
        break;
      }
    }
    active ??= courses.isNotEmpty ? courses.first : null;
    if (active == null) return const SizedBox.shrink();

    final historyAsync = ref.watch(courseAssignmentHistoryProvider(active.course.id));
    return historyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (entries) {
        if (entries.isEmpty) return const SizedBox.shrink();
        final recent = entries.reversed.take(3).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(t('home.student.recentAssignments'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final e in recent)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  dense: true,
                  leading: const Icon(LucideIcons.fileCheck),
                  title: Text(e.assignment.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    e.quizHistory != null
                        ? '${e.quizHistory!.bestPercent ?? 0}%'
                        : (e.submission?.status ?? ''),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CertificatesSection extends ConsumerWidget {
  const _CertificatesSection({required this.t});
  final dynamic t;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certsAsync = ref.watch(myCertificatesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(t('home.student.certificates'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            TextButton(
              onPressed: () => context.push(AppRoutes.certificates),
              child: Text(t('home.student.viewAllCertificates')),
            ),
          ],
        ),
        certsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (_, _) => const SizedBox.shrink(),
          data: (certs) {
            if (certs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(t('certificates.empty'), style: Theme.of(context).textTheme.bodySmall),
              );
            }
            return Column(
              children: certs.take(3).map((c) => _CertificateTile(certificate: c)).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _CertificateTile extends StatelessWidget {
  const _CertificateTile({required this.certificate});
  final Certificate certificate;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(LucideIcons.award, color: Theme.of(context).colorScheme.primary),
        title: Text(certificate.course.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(certificate.certificateNumber),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(AppRoutes.certificateDetailPath(certificate.id)),
      ),
    );
  }
}
