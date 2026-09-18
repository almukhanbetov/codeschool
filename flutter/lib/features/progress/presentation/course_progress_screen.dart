import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/models/lesson.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/presentation/lesson_type_icon.dart';
import '../application/progress_providers.dart';
import 'certificate_cta.dart';

/// Catalog -> Course -> **Progress**: общий прогресс, прогресс по модулям,
/// продолжение с последнего доступного урока, история заданий и результаты
/// квизов, сертификат по завершении. Источник истины — исключительно
/// backend (`GET /me/courses/:id/progress`, `GET /courses/:id/content`,
/// история заданий/квизов через реальные существующие эндпоинты) — ничего
/// не считается «официальным прогрессом» только на клиенте.
class CourseProgressScreen extends ConsumerWidget {
  const CourseProgressScreen({super.key, required this.courseId});
  final int courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final progressAsync = ref.watch(courseProgressProvider(courseId));
    final contentAsync = ref.watch(courseContentProvider(courseId));

    return Scaffold(
      appBar: AppBar(title: Text(t('progress.courseProgress'))),
      body: progressAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
          onRetry: () => ref.invalidate(courseProgressProvider(courseId)),
        ),
        data: (progress) {
          if (progress == null) {
            return EmptyView(message: t('progress.notEnrolledYet'), icon: LucideIcons.lock);
          }
          return contentAsync.when(
            loading: () => const LoadingView(),
            error: (err, _) => ErrorView(
              message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
              onRetry: () => ref.invalidate(courseContentProvider(courseId)),
            ),
            data: (content) {
              final modules = [...content.modules]..sort((a, b) => a.position.compareTo(b.position));
              final statusByLesson = {for (final l in progress.lessons) l.lessonId: l.status};

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(courseProgressProvider(courseId));
                  ref.invalidate(continueLearningTargetProvider(courseId));
                  ref.invalidate(courseAssignmentHistoryProvider(courseId));
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(progress.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(value: progress.progressPercent / 100, minHeight: 10),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${t('progress.completedLessons')}: ${progress.completedLessons}/${progress.totalLessons} (${progress.progressPercent}%)',
                    ),
                    const SizedBox(height: 20),
                    _ContinueSection(courseId: courseId),
                    const SizedBox(height: 20),
                    if (progress.enrollmentStatus == 'completed') ...[
                      CertificateCta(courseId: courseId),
                      const SizedBox(height: 20),
                    ],
                    Text(t('progress.modules'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    ...modules.map((m) => _ModuleProgressTile(module: m, statusByLesson: statusByLesson)),
                    const SizedBox(height: 20),
                    Text(t('progress.submissionsHistory'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _HistorySection(courseId: courseId),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ContinueSection extends ConsumerWidget {
  const _ContinueSection({required this.courseId});
  final int courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final targetAsync = ref.watch(continueLearningTargetProvider(courseId));

    return targetAsync.when(
      loading: () => const SizedBox(height: 52, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (_, _) => const SizedBox.shrink(),
      data: (target) {
        if (target == null) {
          return Row(
            children: [
              Icon(LucideIcons.partyPopper, color: Theme.of(context).colorScheme.tertiary),
              const SizedBox(width: 8),
              Text(t('progress.courseCompleted'), style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          );
        }
        return ElevatedButton.icon(
          onPressed: () => context.push(AppRoutes.lessonDetailPath(courseId, target.moduleId, target.lessonId)),
          icon: const Icon(LucideIcons.play),
          label: Text('${t('home.student.continueLearning')}: ${target.lessonTitle}', overflow: TextOverflow.ellipsis),
        );
      },
    );
  }
}

class _ModuleProgressTile extends StatelessWidget {
  const _ModuleProgressTile({required this.module, required this.statusByLesson});
  final CourseModule module;
  final Map<int, String> statusByLesson;

  @override
  Widget build(BuildContext context) {
    final total = module.lessons.length;
    final completed = module.lessons.where((l) => statusByLesson[l.id] == 'completed').length;
    final fraction = total == 0 ? 0.0 : completed / total;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${module.position}. ${module.title}', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: fraction, minHeight: 6),
            ),
            const SizedBox(height: 6),
            Text('$completed/$total', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _HistorySection extends ConsumerWidget {
  const _HistorySection({required this.courseId});
  final int courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final historyAsync = ref.watch(courseAssignmentHistoryProvider(courseId));

    return historyAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => Text(t('progress.noHistory'), style: Theme.of(context).textTheme.bodySmall),
      data: (entries) {
        if (entries.isEmpty) {
          return Text(t('progress.noHistory'), style: Theme.of(context).textTheme.bodySmall);
        }
        return Column(children: entries.map((e) => _HistoryTile(entry: e)).toList());
      },
    );
  }
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({required this.entry});
  final AssignmentHistoryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final scheme = Theme.of(context).colorScheme;

    if (entry.quizHistory != null) {
      final h = entry.quizHistory!;
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Icon(lessonTypeIcon('quiz')),
          title: Text(entry.assignment.title),
          subtitle: Text('${t('quiz.yourScore')}: ${h.bestScore ?? 0}/${h.bestMaxScore ?? 0} (${h.bestPercent ?? 0}%)'),
          trailing: Icon(
            h.passed ? LucideIcons.circleCheck : LucideIcons.circleX,
            color: h.passed ? scheme.tertiary : scheme.error,
          ),
        ),
      );
    }

    final submission = entry.submission!;
    final (label, color) = switch (submission.status) {
      'passed' => (t('assignment.statusPassed'), scheme.tertiary),
      'failed' => (t('assignment.statusFailed'), scheme.error),
      'submitted' || 'checking' => (t('assignment.statusSubmitted'), scheme.primary),
      _ => (t('assignment.statusDraft'), scheme.outline),
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(lessonTypeIcon(entry.assignment.assignmentType)),
        title: Text(entry.assignment.title),
        subtitle: submission.score != null ? Text('${t('assignment.score')}: ${submission.score}/${entry.assignment.points}') : null,
        trailing: Text(label, style: TextStyle(color: color, fontSize: 12)),
      ),
    );
  }
}
