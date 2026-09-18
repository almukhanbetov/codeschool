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

/// GET /teacher/submissions?status= — the review queue (brief §1
/// "Работы на проверке"). Real statuses from the `submissions` table CHECK
/// constraint only: submitted, checking, passed, failed.
class TeacherSubmissionsScreen extends ConsumerWidget {
  const TeacherSubmissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final filter = ref.watch(submissionQueueFilterProvider);
    final resultAsync = ref.watch(teacherSubmissionsProvider);

    final tabs = <(String?, String)>[
      (null, t('teacher.submissions.filterAll')),
      ('submitted', t('teacher.submissions.filterSubmitted')),
      ('checking', t('teacher.submissions.filterChecking')),
      ('passed', t('teacher.submissions.filterPassed')),
      ('failed', t('teacher.submissions.filterFailed')),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(t('teacher.submissions.title'))),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final (status, label) = tabs[i];
                final selected = filter.status == status;
                return ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) => ref.read(submissionQueueFilterProvider.notifier).setStatus(status),
                );
              },
            ),
          ),
          Expanded(
            child: resultAsync.when(
              loading: () => const LoadingView(),
              error: (err, _) => ErrorView(
                message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
                onRetry: () => ref.invalidate(teacherSubmissionsProvider),
              ),
              data: (result) {
                if (result.items.isEmpty) {
                  return EmptyView(message: t('teacher.submissions.empty'), icon: LucideIcons.clipboardCheck);
                }
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(teacherSubmissionsProvider.future),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: result.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _SubmissionTile(item: result.items[i]),
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

class _SubmissionTile extends StatelessWidget {
  const _SubmissionTile({required this.item});
  final TeacherSubmissionListItem item;

  @override
  Widget build(BuildContext context) {
    final name = '${item.student.firstName} ${item.student.lastName ?? ''}'.trim();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.teacherSubmissionDetailPath(item.id)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(child: Text(item.student.firstName.isNotEmpty ? item.student.firstName[0].toUpperCase() : '?')),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.assignment.title, style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('$name · ${item.course.title}', style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Chip(label: Text(item.status), visualDensity: VisualDensity.compact),
            ],
          ),
        ),
      ),
    );
  }
}
