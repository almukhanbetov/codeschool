import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/models/teacher.dart';
import '../application/teacher_providers.dart';

/// GET /teacher/submissions/:id — the student's code/answer (brief §1
/// "Просмотр решения ученика") plus the grading form (POST
/// .../start-review then .../review — "Выставление оценки и комментария").
/// Opening a `submitted` row calls start-review automatically (submitted →
/// checking, the real backend lock — matches a teacher actually looking at
/// it); a `checking`/`passed`/`failed` row is shown read-only-plus-form as
/// returned, nothing guessed.
class TeacherSubmissionDetailScreen extends ConsumerStatefulWidget {
  const TeacherSubmissionDetailScreen({super.key, required this.submissionId});
  final int submissionId;

  @override
  ConsumerState<TeacherSubmissionDetailScreen> createState() => _TeacherSubmissionDetailScreenState();
}

class _TeacherSubmissionDetailScreenState extends ConsumerState<TeacherSubmissionDetailScreen> {
  final _scoreController = TextEditingController();
  final _feedbackController = TextEditingController();
  bool _startedReview = false;
  bool _submitting = false;
  String? _submitError;

  @override
  void dispose() {
    _scoreController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _maybeStartReview(TeacherSubmissionDetail detail) async {
    if (_startedReview || detail.status != 'submitted') return;
    _startedReview = true;
    final repo = ref.read(teacherRepositoryProvider);
    await repo.startReview(widget.submissionId);
    if (mounted) ref.invalidate(teacherSubmissionDetailProvider(widget.submissionId));
  }

  Future<void> _submitReview(String status) async {
    final t = ref.read(appStringsProvider);
    if (status == 'failed' && _feedbackController.text.trim().isEmpty) {
      setState(() => _submitError = t('teacher.submissions.feedback'));
      return;
    }
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    final repo = ref.read(teacherRepositoryProvider);
    final score = int.tryParse(_scoreController.text.trim());
    final result = await repo.review(
      widget.submissionId,
      score: score,
      feedback: _feedbackController.text.trim(),
      status: status,
    );
    if (!mounted) return;
    switch (result) {
      case ApiOk():
        ref.invalidate(teacherSubmissionDetailProvider(widget.submissionId));
        setState(() => _submitting = false);
      case ApiErr(:final error):
        setState(() {
          _submitting = false;
          _submitError = apiErrorText(ref.read(appStringsProvider), error);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appStringsProvider);
    final detailAsync = ref.watch(teacherSubmissionDetailProvider(widget.submissionId));

    detailAsync.whenData(_maybeStartReview);

    return Scaffold(
      appBar: AppBar(title: Text(detailAsync.valueOrNull?.assignment.title ?? '')),
      body: detailAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
          onRetry: () => ref.invalidate(teacherSubmissionDetailProvider(widget.submissionId)),
        ),
        data: (detail) {
          final reviewed = detail.status == 'passed' || detail.status == 'failed';
          if (reviewed && _scoreController.text.isEmpty && detail.score != null) {
            _scoreController.text = '${detail.score}';
          }
          if (reviewed && _feedbackController.text.isEmpty && detail.teacherFeedback != null) {
            _feedbackController.text = detail.teacherFeedback!;
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StudentHeader(detail: detail),
              const SizedBox(height: 16),
              Text(t('teacher.submissions.solution'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _SolutionCard(detail: detail, t: t),
              const SizedBox(height: 20),
              if (reviewed) _ReviewedBanner(detail: detail, t: t) else _ReviewForm(
                scoreController: _scoreController,
                feedbackController: _feedbackController,
                maxScore: detail.assignment.points,
                submitting: _submitting,
                error: _submitError,
                onSubmit: _submitReview,
                t: t,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StudentHeader extends StatelessWidget {
  const _StudentHeader({required this.detail});
  final TeacherSubmissionDetail detail;

  @override
  Widget build(BuildContext context) {
    final name = '${detail.student.firstName} ${detail.student.lastName ?? ''}'.trim();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(detail.assignment.title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('$name · ${detail.group.title} · ${detail.lesson.title}', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Chip(label: Text(detail.status), visualDensity: VisualDensity.compact),
          ],
        ),
      ),
    );
  }
}

class _SolutionCard extends StatelessWidget {
  const _SolutionCard({required this.detail, required this.t});
  final TeacherSubmissionDetail detail;
  final dynamic t;

  @override
  Widget build(BuildContext context) {
    final content = detail.assignment.assignmentType == 'code' ? detail.code : detail.answer;
    if (content == null || content.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(t('teacher.submissions.noAnswer'), style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          content,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
        ),
      ),
    );
  }
}

class _ReviewedBanner extends StatelessWidget {
  const _ReviewedBanner({required this.detail, required this.t});
  final TeacherSubmissionDetail detail;
  final dynamic t;

  @override
  Widget build(BuildContext context) {
    final passed = detail.status == 'passed';
    return Card(
      color: (passed ? Colors.green : Colors.orange).withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(passed ? LucideIcons.circleCheck : LucideIcons.circleX, color: passed ? Colors.green : Colors.orange),
                const SizedBox(width: 8),
                Text(t('teacher.submissions.reviewed'), style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            if (detail.score != null) ...[
              const SizedBox(height: 8),
              Text('${t('teacher.submissions.score')}: ${detail.score}/${detail.assignment.points}'),
            ],
            if (detail.teacherFeedback != null && detail.teacherFeedback!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(detail.teacherFeedback!),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewForm extends StatelessWidget {
  const _ReviewForm({
    required this.scoreController,
    required this.feedbackController,
    required this.maxScore,
    required this.submitting,
    required this.error,
    required this.onSubmit,
    required this.t,
  });
  final TextEditingController scoreController;
  final TextEditingController feedbackController;
  final int maxScore;
  final bool submitting;
  final String? error;
  final void Function(String status) onSubmit;
  final dynamic t;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('teacher.submissions.review'), style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(
              controller: scoreController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: '${t('teacher.submissions.score')} (0-$maxScore)', border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: InputDecoration(labelText: t('teacher.submissions.feedback'), border: const OutlineInputBorder()),
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 16),
            if (submitting)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onSubmit('failed'),
                      child: Text(t('teacher.submissions.fail')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onSubmit('passed'),
                      child: Text(t('teacher.submissions.pass')),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
