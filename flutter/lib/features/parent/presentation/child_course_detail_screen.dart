import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/models/parent.dart';
import '../application/parent_providers.dart';

/// GET /parent/children/:id/courses/:courseId (brief §2 "Результаты
/// заданий и квизов").
class ChildCourseDetailScreen extends ConsumerWidget {
  const ChildCourseDetailScreen({super.key, required this.childId, required this.courseId});
  final int childId;
  final int courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final key = (childId, courseId);
    final detailAsync = ref.watch(childCourseDetailProvider(key));

    return Scaffold(
      appBar: AppBar(title: Text(detailAsync.valueOrNull?.course.title ?? '')),
      body: detailAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
          onRetry: () => ref.invalidate(childCourseDetailProvider(key)),
        ),
        data: (detail) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(childCourseDetailProvider(key)),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(value: detail.progress.progressPercent / 100, minHeight: 8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('${detail.progress.progressPercent}%', style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 20),
              Text(t('parent.courseDetail.lessons'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Card(
                child: Column(
                  children: [
                    for (final l in detail.lessons)
                      ListTile(
                        dense: true,
                        leading: Icon(l.status == 'completed' ? LucideIcons.circleCheck : LucideIcons.circle, size: 18),
                        title: Text(l.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: Text(l.status),
                      ),
                    if (detail.lessons.isEmpty)
                      Padding(padding: const EdgeInsets.all(16), child: Text(t('common.emptyGeneric'))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(t('parent.courseDetail.assignments'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Card(
                child: Column(
                  children: [
                    for (final a in detail.assignments) _AssignmentTile(item: a),
                    if (detail.assignments.isEmpty)
                      Padding(padding: const EdgeInsets.all(16), child: Text(t('common.emptyGeneric'))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  const _AssignmentTile({required this.item});
  final ParentAssignmentFeedbackItem item;

  @override
  Widget build(BuildContext context) {
    final isQuiz = item.assignmentType == 'quiz';
    final trailing = isQuiz
        ? (item.quizBestPercent != null ? '${item.quizBestPercent}%' : '—')
        : (item.status.isEmpty ? '—' : (item.score != null ? '${item.score}/${item.points}' : item.status));
    return ListTile(
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: item.teacherFeedback != null && item.teacherFeedback!.isNotEmpty
          ? Text(item.teacherFeedback!, maxLines: 2, overflow: TextOverflow.ellipsis)
          : Text(item.lessonTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(trailing),
    );
  }
}
