import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:highlight/languages/go.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/highlight_core.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/models/assignment.dart';
import '../../../shared/models/run.dart';
import '../../assignment/application/assignment_providers.dart';
import '../../assignment/data/assignment_repository.dart';
import '../application/code_runner_providers.dart';

Mode? _highlightMode(String? language) => switch (language) {
      'python' => python,
      'javascript' => javascript,
      'go' => go,
      _ => null,
    };

/// The mobile Code Runner (brief §2): editable, syntax-highlighted editor
/// (`code_text_field`, built on the same `highlight`/`flutter_highlight`
/// already used for read-only display), Run + submit-for-grading, real
/// stdout/stderr/exit-code/timeout/truncated from the response. All
/// execution happens server-side on the existing isolated runner
/// (POST /assignments/:id/run, /code/submit) — nothing here ever executes
/// the student's code on-device, and no client-side code changes any of the
/// server's own CPU/RAM/time/network limits.
class CodeRunnerScreen extends ConsumerStatefulWidget {
  const CodeRunnerScreen({super.key, required this.assignment});
  final Assignment assignment;

  @override
  ConsumerState<CodeRunnerScreen> createState() => _CodeRunnerScreenState();
}

class _CodeRunnerScreenState extends ConsumerState<CodeRunnerScreen> {
  CodeController? _controller;
  final _stdinController = TextEditingController();
  bool _running = false;
  bool _grading = false;
  RunResult? _lastRun;
  GradeResult? _lastGrade;

  // Captured in initState (not a lazy `late final` initializer, which would
  // only run on first *access* — possibly during dispose() itself, too
  // late) while `ref` is still valid. `ref.read` is unsafe inside
  // `dispose()` (ConsumerStatefulElement asserts against it), but the
  // repository instance itself doesn't depend on `ref` after construction,
  // so holding onto it directly is what makes save-on-leave possible at all.
  late final AssignmentRepository _assignmentRepo;

  @override
  void initState() {
    super.initState();
    _assignmentRepo = ref.read(assignmentRepositoryProvider);
  }

  @override
  void dispose() {
    _saveDraft();
    _controller?.dispose();
    _stdinController.dispose();
    super.dispose();
  }

  void _initController(String initialCode) {
    if (_controller != null) return;
    _controller = CodeController(text: initialCode, language: _highlightMode(widget.assignment.language));
  }

  void _saveDraft() {
    final code = _controller?.text;
    if (code == null) return;
    // Best-effort, fire-and-forget: persists the code server-side so it
    // survives navigating away and coming back (brief §2: "код должен
    // сохраняться при переключении экранов"), not just an in-memory copy.
    // ignore: discarded_futures
    _assignmentRepo.saveDraft(widget.assignment.id, code: code);
  }

  Future<void> _run() async {
    final t = ref.read(appStringsProvider);
    setState(() {
      _running = true;
      _lastRun = null;
    });
    final result = await ref.read(codeRunnerRepositoryProvider).run(
          widget.assignment.id,
          code: _controller!.text,
          stdin: _stdinController.text,
        );
    if (!mounted) return;
    setState(() => _running = false);
    switch (result) {
      case ApiOk(:final data):
        setState(() => _lastRun = data);
      case ApiErr(:final error):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorText(t, error))));
    }
  }

  Future<void> _submitForGrading() async {
    final t = ref.read(appStringsProvider);
    setState(() {
      _grading = true;
      _lastGrade = null;
    });
    final result = await ref.read(codeRunnerRepositoryProvider).submitCode(widget.assignment.id, code: _controller!.text);
    if (!mounted) return;
    setState(() => _grading = false);
    ref.invalidate(mySubmissionProvider(widget.assignment.id));
    switch (result) {
      case ApiOk(:final data):
        setState(() => _lastGrade = data);
      case ApiErr(:final error):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorText(t, error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appStringsProvider);
    final submissionAsync = ref.watch(mySubmissionProvider(widget.assignment.id));

    return Scaffold(
      appBar: AppBar(title: Text(t('code.title'))),
      body: submissionAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
          onRetry: () => ref.invalidate(mySubmissionProvider(widget.assignment.id)),
        ),
        data: (submission) {
          _initController(submission?.code ?? widget.assignment.starterCode ?? '');
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(widget.assignment.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              if (widget.assignment.description != null) ...[
                const SizedBox(height: 6),
                Text(widget.assignment.description!, style: Theme.of(context).textTheme.bodyMedium),
              ],
              const SizedBox(height: 12),
              _SampleTests(assignmentId: widget.assignment.id),
              const SizedBox(height: 12),
              CodeTheme(
                data: CodeThemeData(styles: isDark ? atomOneDarkTheme : githubTheme),
                child: Container(
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CodeField(
                    controller: _controller!,
                    textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _stdinController,
                minLines: 1,
                maxLines: 3,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: InputDecoration(labelText: t('code.stdin')),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _running || _grading ? null : _run,
                    icon: const Icon(LucideIcons.play),
                    label: Text(_running ? t('code.running') : t('code.run')),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _running || _grading ? null : _submitForGrading,
                    icon: const Icon(LucideIcons.send),
                    label: Text(_grading ? t('code.grading') : t('code.submitForGrading')),
                  ),
                ],
              ),
              if (_lastRun != null) ...[
                const SizedBox(height: 16),
                _RunOutputPanel(result: _lastRun!),
              ],
              if (_lastGrade != null) ...[
                const SizedBox(height: 16),
                _GradeResultPanel(result: _lastGrade!),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SampleTests extends ConsumerWidget {
  const _SampleTests({required this.assignmentId});
  final int assignmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final testsAsync = ref.watch(assignmentTestsProvider(assignmentId));

    return testsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (tests) {
        if (tests.visible.isEmpty) return const SizedBox.shrink();
        return ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(t('code.sampleTests')),
          children: tests.visible
              .map(
                (test) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(test.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        if (test.stdin.isNotEmpty) Text('stdin: ${test.stdin}', style: const TextStyle(fontFamily: 'monospace')),
                        Text('expected: ${test.expectedStdout}', style: const TextStyle(fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _RunOutputPanel extends ConsumerWidget {
  const _RunOutputPanel({required this.result});
  final RunResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('code.output'), style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          SelectableText(
            result.stdout.isEmpty ? t('code.noOutput') : result.stdout,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
          if (result.stderr.isNotEmpty) ...[
            const SizedBox(height: 8),
            SelectableText(result.stderr, style: TextStyle(fontFamily: 'monospace', color: scheme.error)),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              if (result.exitCode != null) Chip(label: Text('${t('code.exitCode')}: ${result.exitCode}')),
              if (result.durationMs != null) Chip(label: Text('${result.durationMs} ms')),
              if (result.timedOut) Chip(label: Text(t('code.timedOut')), backgroundColor: scheme.errorContainer),
              if (result.truncated) Chip(label: Text(t('code.truncated'))),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradeResultPanel extends ConsumerWidget {
  const _GradeResultPanel({required this.result});
  final GradeResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: result.passed ? scheme.tertiaryContainer : scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${t('code.testsPassed')}: ${result.testsPassed}/${result.testsTotal} (${result.percent}%)',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          if (result.feedback.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(result.feedback),
          ],
          for (final outcome in result.outcomes)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(outcome.passed ? Icons.check_circle : Icons.cancel, size: 18, color: outcome.passed ? scheme.tertiary : scheme.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(outcome.name),
                        if (!outcome.hidden && !outcome.passed && outcome.got != null)
                          Text('expected: ${outcome.expected}\ngot: ${outcome.got}', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
