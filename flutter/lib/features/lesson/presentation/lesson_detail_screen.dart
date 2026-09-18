import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/models/app_role.dart';
import '../../../shared/models/assignment.dart';
import '../../../shared/models/lesson.dart';
import '../../../shared/models/progress.dart';
import '../../../shared/models/user.dart';
import '../../assignment/application/assignment_providers.dart';
import '../../auth/application/auth_controller.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/presentation/lesson_type_icon.dart';
import '../../quiz/application/quiz_providers.dart';
import '../application/lesson_providers.dart';
import 'lesson_video_player.dart';
import 'safe_markdown.dart';

/// Catalog -> Course Details -> Module -> **Lesson**. Real lesson
/// (brief §1/§5): safe Markdown content, safe video, real assignments
/// (text/project inline, quiz/code as their own screens), lesson
/// start/complete against the real progress API, and prev/next navigation
/// within the module.
class LessonDetailScreen extends ConsumerStatefulWidget {
  const LessonDetailScreen({super.key, required this.courseId, required this.moduleId, required this.lessonId});
  final int courseId;
  final int moduleId;
  final int lessonId;

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  bool _startedThisSession = false;
  bool _completing = false;

  void _maybeStartLesson(AppUser? user) {
    if (_startedThisSession) return;
    if (user == null || user.role != AppRole.student) return;
    _startedThisSession = true;
    // Best-effort, fire-and-forget — the backend call itself is idempotent
    // (progress/service.go `StartLesson`); a failure here just means the
    // "started" timestamp isn't recorded a moment sooner, nothing blocks on it.
    // ignore: discarded_futures
    ref.read(lessonRepositoryProvider).startLesson(widget.lessonId);
  }

  Future<void> _completeLesson() async {
    final t = ref.read(appStringsProvider);
    setState(() => _completing = true);
    final result = await ref.read(lessonRepositoryProvider).completeLesson(widget.lessonId);
    if (!mounted) return;
    setState(() => _completing = false);
    ref.invalidate(courseProgressProvider(widget.courseId));
    switch (result) {
      case ApiOk(:final data):
        final message = data.enrollmentCompleted
            ? '${t('lesson.completed')} 🎉 ${t('lesson.courseCompleted')}'
            : t('lesson.completed');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      case ApiErr(:final error):
        final message = error.statusCode == 409 ? t('lesson.completeHint') : apiErrorText(t, error);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appStringsProvider);
    final lessonAsync = ref.watch(lessonByIdProvider(widget.lessonId));
    final contentAsync = ref.watch(courseContentProvider(widget.courseId));
    // Watched (not just read) so a start-lesson attempt is retried on the
    // next build once auth resolves, instead of silently no-op-ing forever
    // if this screen's data happens to resolve before auth does.
    final user = ref.watch(authControllerProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(t('lesson.detailsTitle'))),
      body: lessonAsync.when(
        loading: () => LoadingView(label: t('lesson.loading')),
        error: (err, _) => ErrorView(
          message: err is ApiException ? apiErrorText(t, err) : t('lesson.loadError'),
          onRetry: () => ref.invalidate(lessonByIdProvider(widget.lessonId)),
        ),
        data: (lesson) {
          _maybeStartLesson(user);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Icon(lessonTypeIcon(lesson.lessonType)),
                  const SizedBox(width: 8),
                  Text(t('lesson.type.${lesson.lessonType}'), style: Theme.of(context).textTheme.labelLarge),
                  const Spacer(),
                  _LessonProgressBadge(courseId: widget.courseId, lessonId: widget.lessonId),
                ],
              ),
              const SizedBox(height: 8),
              Text(lesson.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              if (lesson.description != null) ...[
                const SizedBox(height: 6),
                Text(lesson.description!, style: Theme.of(context).textTheme.bodyMedium),
              ],
              if (lesson.videoUrl != null) ...[
                const SizedBox(height: 16),
                LessonVideoPlayer(videoUrl: lesson.videoUrl!),
              ],
              if (lesson.content != null && lesson.content!.isNotEmpty) ...[
                const SizedBox(height: 16),
                SafeMarkdown(text: lesson.content!),
              ],
              const SizedBox(height: 16),
              Text(t('lesson.assignment'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _AssignmentsSection(lessonId: widget.lessonId),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _completing ? null : _completeLesson,
                icon: const Icon(LucideIcons.circleCheck),
                label: Text(_completing ? t('lesson.completing') : t('lesson.complete')),
              ),
              const SizedBox(height: 24),
              contentAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (content) => _PrevNextRow(courseId: widget.courseId, moduleId: widget.moduleId, lessonId: widget.lessonId, modules: content.modules),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LessonProgressBadge extends ConsumerWidget {
  const _LessonProgressBadge({required this.courseId, required this.lessonId});
  final int courseId;
  final int lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(courseProgressProvider(courseId));
    return progressAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (progress) {
        if (progress == null) return const SizedBox.shrink();
        LessonProgress? lp;
        for (final l in progress.lessons) {
          if (l.lessonId == lessonId) {
            lp = l;
            break;
          }
        }
        if (lp == null || lp.status == 'not_started') return const SizedBox.shrink();
        final isDone = lp.status == 'completed';
        return Icon(
          isDone ? LucideIcons.circleCheck : LucideIcons.circleDot,
          size: 18,
          color: isDone ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
        );
      },
    );
  }
}

class _AssignmentsSection extends ConsumerWidget {
  const _AssignmentsSection({required this.lessonId});
  final int lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final assignmentsAsync = ref.watch(lessonAssignmentsProvider(lessonId));

    return assignmentsAsync.when(
      loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (err, _) => Text(err is ApiException ? apiErrorText(t, err) : t('error.unknown')),
      data: (assignments) {
        if (assignments.isEmpty) return Text(t('lesson.noAssignment'), style: Theme.of(context).textTheme.bodySmall);
        return Column(children: assignments.map((a) => _AssignmentCard(assignment: a)).toList());
      },
    );
  }
}

class _AssignmentCard extends ConsumerWidget {
  const _AssignmentCard({required this.assignment});
  final Assignment assignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(lessonTypeIcon(assignment.assignmentType)),
        title: Text(assignment.title),
        subtitle: Text('${assignment.points} ${t('assignment.points')}'),
        trailing: assignment.assignmentType == 'quiz'
            ? _QuizStatusChip(assignmentId: assignment.id)
            : assignment.assignmentType == 'code'
                ? const Icon(Icons.chevron_right)
                : _SubmissionStatusChip(assignmentId: assignment.id),
        onTap: () => context.push(AppRoutes.assignmentDetailPath(assignment.id), extra: assignment),
      ),
    );
  }
}

class _SubmissionStatusChip extends ConsumerWidget {
  const _SubmissionStatusChip({required this.assignmentId});
  final int assignmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final submissionAsync = ref.watch(mySubmissionProvider(assignmentId));
    return submissionAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const Icon(Icons.chevron_right),
      data: (submission) {
        if (submission == null) return const Icon(Icons.chevron_right);
        final label = switch (submission.status) {
          'passed' => t('assignment.statusPassed'),
          'failed' => t('assignment.statusFailed'),
          'submitted' || 'checking' => t('assignment.statusSubmitted'),
          _ => t('assignment.statusDraft'),
        };
        return Text(label, style: Theme.of(context).textTheme.bodySmall);
      },
    );
  }
}

class _QuizStatusChip extends ConsumerWidget {
  const _QuizStatusChip({required this.assignmentId});
  final int assignmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final historyAsync = ref.watch(quizHistoryProvider(assignmentId));
    return historyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const Icon(Icons.chevron_right),
      data: (history) => Text(
        history.attemptsUsed == 0 ? '' : (history.passed ? t('quiz.passed') : t('quiz.failed')),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _PrevNextRow extends StatelessWidget {
  const _PrevNextRow({required this.courseId, required this.moduleId, required this.lessonId, required this.modules});
  final int courseId;
  final int moduleId;
  final int lessonId;
  final List<CourseModule> modules;

  @override
  Widget build(BuildContext context) {
    CourseModule? module;
    for (final m in modules) {
      if (m.id == moduleId) {
        module = m;
        break;
      }
    }
    if (module == null) return const SizedBox.shrink();
    final lessons = [...module.lessons]..sort((a, b) => a.position.compareTo(b.position));
    final index = lessons.indexWhere((l) => l.id == lessonId);
    if (index == -1) return const SizedBox.shrink();
    final prev = index > 0 ? lessons[index - 1] : null;
    final next = index < lessons.length - 1 ? lessons[index + 1] : null;

    return Consumer(
      builder: (context, ref, _) {
        final t = ref.watch(appStringsProvider);
        return Row(
          children: [
            if (prev != null)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.lessonDetailPath(courseId, moduleId, prev.id)),
                  icon: const Icon(Icons.chevron_left),
                  label: Text(t('lesson.previousLesson'), overflow: TextOverflow.ellipsis),
                ),
              ),
            if (prev != null && next != null) const SizedBox(width: 12),
            if (next != null)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.lessonDetailPath(courseId, moduleId, next.id)),
                  icon: const Icon(Icons.chevron_right),
                  label: Text(t('lesson.nextLesson'), overflow: TextOverflow.ellipsis),
                ),
              ),
          ],
        );
      },
    );
  }
}
