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
import '../application/teacher_providers.dart';

/// GET /teacher/groups/:id + GET /teacher/groups/:id/students (brief §1 —
/// "Список учеников").
class TeacherGroupDetailScreen extends ConsumerWidget {
  const TeacherGroupDetailScreen({super.key, required this.groupId});
  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final detailAsync = ref.watch(teacherGroupDetailProvider(groupId));

    return Scaffold(
      appBar: AppBar(title: Text(detailAsync.valueOrNull?.title ?? t('teacher.groups.title'))),
      body: detailAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
          onRetry: () => ref.invalidate(teacherGroupDetailProvider(groupId)),
        ),
        data: (detail) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(teacherGroupDetailProvider(groupId));
            ref.invalidate(teacherGroupStudentsProvider(groupId));
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _GroupInfoCard(detail: detail, t: t),
              const SizedBox(height: 20),
              Text(t('teacher.group.students'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _StudentsList(groupId: groupId, t: t),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupInfoCard extends StatelessWidget {
  const _GroupInfoCard({required this.detail, required this.t});
  final TeacherGroupDetail detail;
  final dynamic t;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(detail.course.title, style: Theme.of(context).textTheme.titleMedium)),
                Chip(label: Text(detail.status), visualDensity: VisualDensity.compact),
              ],
            ),
            if (detail.description != null) ...[
              const SizedBox(height: 8),
              Text(detail.description!, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Text(t('teacher.group.avgProgress'), style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                Text('${detail.avgProgressPercent}%', style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: detail.avgProgressPercent / 100, minHeight: 6),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentsList extends ConsumerWidget {
  const _StudentsList({required this.groupId, required this.t});
  final int groupId;
  final dynamic t;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(teacherGroupStudentsProvider(groupId));
    return studentsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (err, _) => ErrorView(
        message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
        onRetry: () => ref.invalidate(teacherGroupStudentsProvider(groupId)),
      ),
      data: (students) {
        if (students.isEmpty) {
          return EmptyView(message: t('teacher.groups.empty'), icon: LucideIcons.userRound);
        }
        return Column(
          children: students.map((s) => _StudentTile(groupId: groupId, item: s)).toList(),
        );
      },
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({required this.groupId, required this.item});
  final int groupId;
  final TeacherGroupStudentItem item;

  @override
  Widget build(BuildContext context) {
    final name = '${item.student.firstName} ${item.student.lastName ?? ''}'.trim();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(child: Text(item.student.firstName.isNotEmpty ? item.student.firstName[0].toUpperCase() : '?')),
        title: Text(name),
        subtitle: Text('${item.progress.progressPercent}% · ${item.progress.completedLessons}/${item.progress.totalLessons}'),
        trailing: item.pendingSubmissions > 0
            ? Badge(label: Text('${item.pendingSubmissions}'), child: const Icon(Icons.chevron_right))
            : const Icon(Icons.chevron_right),
        onTap: () => context.push(AppRoutes.teacherStudentDetailPath(groupId, item.student.id)),
      ),
    );
  }
}
