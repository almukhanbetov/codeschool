import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/models/assignment.dart';
import '../application/assignment_providers.dart';

/// Catalog -> Course -> Module -> Lesson -> **Assignment**. Hosts the
/// text/project submission flow directly; a `quiz` or `code` assignment
/// hands off to [QuizScreen]/[CodeRunnerScreen] instead (brief §3/§4 keep
/// those as their own dedicated flows).
class AssignmentScreen extends ConsumerWidget {
  const AssignmentScreen({super.key, required this.assignment});
  final Assignment assignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(assignment.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(assignment.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Chip(label: Text('${assignment.points} ${t('assignment.points')}')),
          if (assignment.description != null) ...[
            const SizedBox(height: 16),
            Text(assignment.description!, style: Theme.of(context).textTheme.bodyLarge),
          ],
          const SizedBox(height: 24),
          switch (assignment.assignmentType) {
            'quiz' => ElevatedButton(
                onPressed: () => context.push(AppRoutes.assignmentQuizPath(assignment.id), extra: assignment),
                child: Text(t('quiz.start')),
              ),
            'code' => ElevatedButton(
                onPressed: () => context.push(AppRoutes.assignmentCodePath(assignment.id), extra: assignment),
                child: Text(t('code.title')),
              ),
            _ => _TextSubmissionForm(assignment: assignment),
          },
        ],
      ),
    );
  }
}

class _TextSubmissionForm extends ConsumerStatefulWidget {
  const _TextSubmissionForm({required this.assignment});
  final Assignment assignment;

  @override
  ConsumerState<_TextSubmissionForm> createState() => _TextSubmissionFormState();
}

class _TextSubmissionFormState extends ConsumerState<_TextSubmissionForm> {
  final _controller = TextEditingController();
  bool _saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveDraft() async {
    final t = ref.read(appStringsProvider);
    setState(() => _saving = true);
    final result = await ref.read(assignmentRepositoryProvider).saveDraft(widget.assignment.id, answer: _controller.text);
    if (!mounted) return;
    setState(() => _saving = false);
    ref.invalidate(mySubmissionProvider(widget.assignment.id));
    if (result is ApiErr<Submission>) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorText(t, result.error))));
    }
  }

  Future<void> _submit() async {
    final t = ref.read(appStringsProvider);
    setState(() => _saving = true);
    // Save the latest text as a draft first so submit never finalizes stale text.
    await ref.read(assignmentRepositoryProvider).saveDraft(widget.assignment.id, answer: _controller.text);
    final result = await ref.read(assignmentRepositoryProvider).submit(widget.assignment.id);
    if (!mounted) return;
    setState(() => _saving = false);
    ref.invalidate(mySubmissionProvider(widget.assignment.id));
    final message = switch (result) {
      ApiOk() => t('assignment.submitted'),
      ApiErr(:final error) => apiErrorText(t, error),
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appStringsProvider);
    final submissionAsync = ref.watch(mySubmissionProvider(widget.assignment.id));

    return submissionAsync.when(
      loading: () => const LoadingView(),
      error: (err, _) => ErrorView(
        message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
        onRetry: () => ref.invalidate(mySubmissionProvider(widget.assignment.id)),
      ),
      data: (submission) {
        if (!_initialized) {
          _controller.text = submission?.answer ?? '';
          _initialized = true;
        }
        final editable = submission == null || submission.status == 'draft';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (submission != null) _StatusBadge(status: submission.status),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              enabled: editable && !_saving,
              minLines: 5,
              maxLines: 12,
              decoration: InputDecoration(labelText: t('assignment.yourAnswer')),
            ),
            if (submission?.score != null) ...[
              const SizedBox(height: 12),
              Text('${t('assignment.score')}: ${submission!.score}/${widget.assignment.points}'),
            ],
            if (submission?.teacherFeedback != null) ...[
              const SizedBox(height: 12),
              Text(t('assignment.teacherFeedback'), style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(submission!.teacherFeedback!),
            ],
            if (editable) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: _saving ? null : _saveDraft,
                    child: Text(_saving ? t('assignment.saving') : t('assignment.saveDraft')),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saving || _controller.text.trim().isEmpty ? null : _submit,
                    child: Text(t('assignment.submit')),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _StatusBadge extends ConsumerWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final (label, color) = switch (status) {
      'draft' => (t('assignment.statusDraft'), Theme.of(context).colorScheme.outline),
      'submitted' || 'checking' => (t('assignment.statusSubmitted'), Theme.of(context).colorScheme.primary),
      'passed' => (t('assignment.statusPassed'), Theme.of(context).colorScheme.tertiary),
      'failed' => (t('assignment.statusFailed'), Theme.of(context).colorScheme.error),
      _ => (status, Theme.of(context).colorScheme.outline),
    };
    return Chip(label: Text(label), backgroundColor: color.withValues(alpha: 0.15));
  }
}
