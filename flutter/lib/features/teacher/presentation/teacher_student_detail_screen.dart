import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/models/teacher.dart';
import '../application/teacher_providers.dart';

/// GET /teacher/groups/:id/students/:studentId — lessons, submissions and
/// quiz results for one student (brief §1 — "Просмотр решения ученика" is
/// the individual submission list here; the code/answer view itself lives
/// in [TeacherSubmissionDetailScreen]).
class TeacherStudentDetailScreen extends ConsumerWidget {
  const TeacherStudentDetailScreen({super.key, required this.groupId, required this.studentId});
  final int groupId;
  final int studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final key = (groupId, studentId);
    final detailAsync = ref.watch(teacherStudentDetailProvider(key));

    return Scaffold(
      appBar: AppBar(title: Text(detailAsync.valueOrNull?.student.firstName ?? '')),
      body: detailAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
          onRetry: () => ref.invalidate(teacherStudentDetailProvider(key)),
        ),
        data: (detail) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(teacherStudentDetailProvider(key)),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Header(detail: detail),
              const SizedBox(height: 20),
              _Section(title: t('teacher.student.lessons'), icon: LucideIcons.bookOpen, children: [
                for (final l in detail.lessons)
                  ListTile(
                    dense: true,
                    leading: Icon(l.status == 'completed' ? LucideIcons.circleCheck : LucideIcons.circle, size: 18),
                    title: Text(l.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(l.status),
                  ),
                if (detail.lessons.isEmpty) EmptyView(message: t('common.emptyGeneric')),
              ]),
              const SizedBox(height: 16),
              _Section(title: t('teacher.student.submissions'), icon: LucideIcons.fileCheck, children: [
                for (final s in detail.submissions)
                  ListTile(
                    dense: true,
                    title: Text(s.assignmentTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(s.lessonTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(s.status.isEmpty ? '—' : (s.score != null ? '${s.score}/${s.points}' : s.status)),
                  ),
                if (detail.submissions.isEmpty) EmptyView(message: t('common.emptyGeneric')),
              ]),
              const SizedBox(height: 16),
              _Section(title: t('teacher.student.quizzes'), icon: LucideIcons.helpCircle, children: [
                for (final q in detail.quizResults)
                  ListTile(
                    dense: true,
                    leading: Icon(q.passed ? LucideIcons.circleCheck : LucideIcons.circleX, size: 18),
                    title: Text(q.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(q.bestPercent != null ? '${q.bestPercent}%' : '—'),
                  ),
                if (detail.quizResults.isEmpty) EmptyView(message: t('common.emptyGeneric')),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.detail});
  final TeacherStudentDetail detail;

  @override
  Widget build(BuildContext context) {
    final name = '${detail.student.firstName} ${detail.student.lastName ?? ''}'.trim();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              child: Text(detail.student.firstName.isNotEmpty ? detail.student.firstName[0].toUpperCase() : '?'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(detail.course.title, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Text('${detail.progress.progressPercent}% · ${detail.progress.completedLessons}/${detail.progress.totalLessons}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.icon, required this.children});
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        Card(child: Column(children: children)),
      ],
    );
  }
}
