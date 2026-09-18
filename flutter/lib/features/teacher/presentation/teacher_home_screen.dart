import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/models/teacher.dart';
import '../../../shared/models/user.dart';
import '../application/teacher_providers.dart';

/// The real teacher cabinet (brief §1, Stage 35G) — every number comes from
/// `GET /teacher/dashboard`, nothing computed client-side.
class TeacherHomeScreen extends ConsumerWidget {
  const TeacherHomeScreen({super.key, required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final dashAsync = ref.watch(teacherDashboardProvider);

    return dashAsync.when(
      loading: () => const LoadingView(),
      error: (err, _) => ErrorView(
        message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
        onRetry: () => ref.invalidate(teacherDashboardProvider),
      ),
      data: (dash) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(teacherDashboardProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              t('home.teacher.welcome'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            _StatsGrid(dash: dash, t: t),
            const SizedBox(height: 24),
            _QuickLink(
              icon: LucideIcons.users,
              label: t('home.teacher.myGroups'),
              onTap: () => context.push(AppRoutes.teacherGroups),
            ),
            _QuickLink(
              icon: LucideIcons.clipboardCheck,
              label: t('teacher.submissions.title'),
              badge: dash.pendingSubmissions > 0 ? dash.pendingSubmissions : null,
              onTap: () => context.push(AppRoutes.teacherSubmissions),
            ),
            _QuickLink(
              icon: LucideIcons.graduationCap,
              label: t('home.teacher.academy'),
              onTap: () => context.push(AppRoutes.teacherAcademy),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.dash, required this.t});
  final TeacherDashboard dash;
  final dynamic t;

  @override
  Widget build(BuildContext context) {
    final items = [
      (t('teacher.dashboard.groups'), dash.groupsCount, LucideIcons.users),
      (t('teacher.dashboard.students'), dash.studentsCount, LucideIcons.userRound),
      (t('teacher.dashboard.pending'), dash.pendingSubmissions, LucideIcons.clock),
      (t('teacher.dashboard.reviewed'), dash.reviewedSubmissions, LucideIcons.circleCheck),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: items
          .map(
            (e) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(e.$3, color: Theme.of(context).colorScheme.primary),
                    const Spacer(),
                    Text('${e.$2}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    Text(e.$1, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({required this.icon, required this.label, required this.onTap, this.badge});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label),
        trailing: badge != null
            ? Badge(label: Text('$badge'), child: const Icon(Icons.chevron_right))
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
