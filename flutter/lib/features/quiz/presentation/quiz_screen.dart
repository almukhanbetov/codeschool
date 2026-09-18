import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/models/assignment.dart';
import '../../../shared/models/quiz.dart';
import '../application/quiz_providers.dart';

/// The mobile quiz flow (brief §4): start/resume an attempt, answer, submit,
/// see the real graded result and retry only when the backend says a retry
/// is allowed (`canStart`/`attemptsLeft`) — correctness is always computed
/// server-side (`POST /quiz/attempts/:id/submit`), never locally.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.assignment});
  final Assignment assignment;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int? _activeAttemptId;
  AttemptResult? _submittedResult;
  final Map<int, Set<int>> _answers = {};
  bool _starting = false;
  bool _submitting = false;

  Future<void> _start() async {
    final t = ref.read(appStringsProvider);
    setState(() => _starting = true);
    final result = await ref.read(quizRepositoryProvider).startAttempt(widget.assignment.id);
    if (!mounted) return;
    setState(() => _starting = false);
    switch (result) {
      case ApiOk(:final data):
        setState(() {
          _activeAttemptId = data.attempt.id;
          _submittedResult = null;
          _answers.clear();
        });
      case ApiErr(:final error):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorText(t, error))));
    }
  }

  void _toggleOption(StudentQuestion question, int optionId) {
    setState(() {
      final selected = _answers.putIfAbsent(question.id, () => {});
      if (question.questionType == 'multiple_choice') {
        selected.contains(optionId) ? selected.remove(optionId) : selected.add(optionId);
      } else {
        selected
          ..clear()
          ..add(optionId);
      }
    });
  }

  Future<void> _submit(int attemptId) async {
    final t = ref.read(appStringsProvider);
    setState(() => _submitting = true);
    final answers = {for (final e in _answers.entries) e.key: e.value.toList()};
    final result = await ref.read(quizRepositoryProvider).submitAttempt(attemptId, answers);
    if (!mounted) return;
    setState(() => _submitting = false);
    switch (result) {
      case ApiOk(:final data):
        setState(() => _submittedResult = data);
        ref.invalidate(quizHistoryProvider(widget.assignment.id));
      case ApiErr(:final error):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorText(t, error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appStringsProvider);
    final historyAsync = ref.watch(quizHistoryProvider(widget.assignment.id));

    return Scaffold(
      appBar: AppBar(title: Text(t('quiz.title'))),
      body: historyAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
          onRetry: () => ref.invalidate(quizHistoryProvider(widget.assignment.id)),
        ),
        data: (history) {
          if (_submittedResult != null) {
            return _ResultView(
              result: _submittedResult!,
              history: history,
              onRetry: history.canStart ? _start : null,
              retrying: _starting,
            );
          }

          final resumeId = _activeAttemptId ?? history.inProgressId;
          if (resumeId != null) {
            return _AttemptView(
              attemptId: resumeId,
              answers: _answers,
              onToggle: _toggleOption,
              onSubmit: () => _submit(resumeId),
              submitting: _submitting,
              onSubmitted: (result) => setState(() => _submittedResult = result),
            );
          }

          return _StartView(history: history, onStart: _start, starting: _starting);
        },
      ),
    );
  }
}

class _StartView extends ConsumerWidget {
  const _StartView({required this.history, required this.onStart, required this.starting});
  final QuizAttemptHistory history;
  final VoidCallback onStart;
  final bool starting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(history.title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('${t('quiz.passPercent')}: ${history.passPercent}%'),
            if (history.maxAttempts != null) Text('${t('quiz.attemptsLeft')}: ${history.attemptsLeft ?? 0}'),
            if (history.attemptsUsed > 0) ...[
              const SizedBox(height: 8),
              Text(history.passed ? '${t('quiz.passed')} — ${history.bestPercent}%' : '${t('quiz.failed')} — ${history.bestPercent ?? 0}%'),
            ],
            const SizedBox(height: 24),
            if (history.canStart)
              ElevatedButton(onPressed: starting ? null : onStart, child: Text(starting ? t('quiz.startingLabel') : t('quiz.start')))
            else
              Text(t('quiz.noAttemptsLeft'), style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ),
      ),
    );
  }
}

class _AttemptView extends ConsumerWidget {
  const _AttemptView({
    required this.attemptId,
    required this.answers,
    required this.onToggle,
    required this.onSubmit,
    required this.submitting,
    required this.onSubmitted,
  });
  final int attemptId;
  final Map<int, Set<int>> answers;
  final void Function(StudentQuestion, int) onToggle;
  final VoidCallback onSubmit;
  final bool submitting;
  final void Function(AttemptResult) onSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final detailAsync = ref.watch(attemptDetailProvider(attemptId));

    return detailAsync.when(
      loading: () => const LoadingView(),
      error: (err, _) => ErrorView(
        message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
        onRetry: () => ref.invalidate(attemptDetailProvider(attemptId)),
      ),
      data: (detail) {
        // Already submitted server-side (e.g. resumed after leaving) — show
        // the real result instead of a stale question form.
        if (detail.result != null) {
          return _ResultView(result: detail.result!, history: null, onRetry: null, retrying: false);
        }
        final quiz = detail.quiz!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(quiz.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            for (var i = 0; i < quiz.questions.length; i++) _QuestionCard(index: i, total: quiz.questions.length, question: quiz.questions[i], selected: answers[quiz.questions[i].id] ?? const {}, onToggle: onToggle),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: submitting ? null : onSubmit,
              child: Text(submitting ? t('assignment.saving') : t('quiz.submit')),
            ),
          ],
        );
      },
    );
  }
}

class _QuestionCard extends ConsumerWidget {
  const _QuestionCard({required this.index, required this.total, required this.question, required this.selected, required this.onToggle});
  final int index;
  final int total;
  final StudentQuestion question;
  final Set<int> selected;
  final void Function(StudentQuestion, int) onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final isMultiple = question.questionType == 'multiple_choice';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('quiz.questionOf', {'current': '${index + 1}', 'total': '$total'}), style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(question.questionText, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (isMultiple) ...[
              const SizedBox(height: 4),
              Text(t('quiz.multipleChoiceHint'), style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 8),
            for (final option in question.options)
              isMultiple
                  ? CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      value: selected.contains(option.id),
                      onChanged: (_) => onToggle(question, option.id),
                      title: Text(option.optionText),
                    )
                  : ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: Icon(
                        selected.contains(option.id) ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      ),
                      title: Text(option.optionText),
                      onTap: () => onToggle(question, option.id),
                    ),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends ConsumerWidget {
  const _ResultView({required this.result, required this.history, required this.onRetry, required this.retrying});
  final AttemptResult result;
  final QuizAttemptHistory? history;
  final VoidCallback? onRetry;
  final bool retrying;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: result.passed ? scheme.tertiaryContainer : scheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.passed ? t('quiz.passed') : t('quiz.failed'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              const SizedBox(height: 4),
              Text('${t('quiz.yourScore')}: ${result.score}/${result.maxScore} (${result.percent}%)'),
              Text('${t('quiz.passPercent')}: ${result.passPercent}%'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (result.showCorrectAnswers)
          for (final q in result.questions) _ResultQuestionCard(question: q)
        else
          Text(t('lesson.completeHint'), style: Theme.of(context).textTheme.bodySmall),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          ElevatedButton(onPressed: retrying ? null : onRetry, child: Text(t('quiz.retry'))),
        ],
      ],
    );
  }
}

class _ResultQuestionCard extends ConsumerWidget {
  const _ResultQuestionCard({required this.question});
  final ResultQuestion question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(question.isCorrect ? Icons.check_circle : Icons.cancel, color: question.isCorrect ? scheme.tertiary : scheme.error, size: 18),
                const SizedBox(width: 6),
                Expanded(child: Text(question.questionText, style: const TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
            const SizedBox(height: 8),
            for (final o in question.options)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      o.selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      size: 16,
                      color: o.isCorrect == true ? scheme.tertiary : (o.selected ? scheme.error : scheme.outline),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(o.optionText)),
                    if (o.isCorrect == true) Text(t('quiz.correct'), style: TextStyle(color: scheme.tertiary, fontSize: 12)),
                  ],
                ),
              ),
            if (question.explanation != null) ...[
              const SizedBox(height: 6),
              Text(question.explanation!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
