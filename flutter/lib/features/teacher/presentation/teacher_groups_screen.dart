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

/// GET /teacher/groups — real groups only, never invented (brief §1).
class TeacherGroupsScreen extends ConsumerWidget {
  const TeacherGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final groupsAsync = ref.watch(teacherGroupsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t('teacher.groups.title'))),
      body: groupsAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
          onRetry: () => ref.invalidate(teacherGroupsProvider),
        ),
        data: (groups) {
          if (groups.isEmpty) {
            return EmptyView(message: t('teacher.groups.empty'), icon: LucideIcons.users);
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(teacherGroupsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _GroupCard(group: groups[i], t: t),
            ),
          );
        },
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group, required this.t});
  final TeacherGroupListItem group;
  final dynamic t;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.teacherGroupDetailPath(group.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(group.title, style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  Chip(label: Text(group.status), visualDensity: VisualDensity.compact),
                ],
              ),
              const SizedBox(height: 6),
              Text(group.course.title, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(LucideIcons.users, size: 16, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(width: 6),
                  Text('${group.studentCount} ${t('teacher.groups.students')}'),
                  const Spacer(),
                  Text('${group.avgProgressPercent}%', style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(value: group.avgProgressPercent / 100, minHeight: 6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
