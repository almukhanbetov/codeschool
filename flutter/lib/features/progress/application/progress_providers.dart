import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/models/assignment.dart';
import '../../../shared/models/lesson.dart';
import '../../../shared/models/progress.dart';
import '../../../shared/models/quiz.dart';
import '../../assignment/application/assignment_providers.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../lesson/application/lesson_providers.dart';
import '../../quiz/application/quiz_providers.dart';
import '../data/progress_repository.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) => ProgressRepository(ref.watch(apiClientProvider)));

/// GET /me/progress — one row per enrolled course, source of the percent
/// shown on every course card in the student cabinet. Empty (not an error)
/// for a signed-out visitor or non-student, same "hide what the role can't
/// use" pattern as the rest of the app.
final myProgressListProvider = FutureProvider<List<CourseProgress>>((ref) async {
  final repo = ref.watch(progressRepositoryProvider);
  final result = await repo.listMyProgress();
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});

/// Where "Continue learning" should take the student: the first lesson
/// that's `in_progress`, else the first `not_started` lesson in module/
/// lesson position order, else `null` if every lesson is completed.
/// Computed client-side from two already-fetched, real sources
/// (`courseContentProvider` for the ordered tree, `courseProgressProvider`
/// for per-lesson status) — never a fabricated "next lesson" guess.
class ContinueTarget {
  const ContinueTarget({required this.moduleId, required this.lessonId, required this.lessonTitle});
  final int moduleId;
  final int lessonId;
  final String lessonTitle;
}

final continueLearningTargetProvider = FutureProvider.family<ContinueTarget?, int>((ref, courseId) async {
  final content = await ref.watch(courseContentProvider(courseId).future);
  final progress = await ref.watch(courseProgressProvider(courseId).future);
  if (progress == null) return null;

  final statusByLesson = {for (final l in progress.lessons) l.lessonId: l.status};
  final modules = [...content.modules]..sort((a, b) => a.position.compareTo(b.position));

  ContinueTarget? firstNotStarted;
  for (final module in modules) {
    final lessons = [...module.lessons]..sort((a, b) => a.position.compareTo(b.position));
    for (final lesson in lessons) {
      final status = statusByLesson[lesson.id];
      if (status == 'in_progress') {
        return ContinueTarget(moduleId: module.id, lessonId: lesson.id, lessonTitle: lesson.title);
      }
      if (status == null || status == 'not_started') {
        firstNotStarted ??= ContinueTarget(moduleId: module.id, lessonId: lesson.id, lessonTitle: lesson.title);
      }
    }
  }
  return firstNotStarted;
});

/// One row of assignment/quiz activity for the course progress screen's
/// history section.
class AssignmentHistoryEntry {
  const AssignmentHistoryEntry({required this.assignment, this.submission, this.quizHistory});
  final Assignment assignment;
  final Submission? submission;
  final QuizAttemptHistory? quizHistory;
}

/// The backend has no aggregate "my assignment history for this course"
/// endpoint, so this composes real, already-existing ones: walks the
/// course's lessons (from the already-cached `courseContentProvider`),
/// skips any lesson the student hasn't touched yet (`courseProgressProvider`
/// status `not_started`) to bound the number of requests to real activity
/// rather than the whole course, then fetches each touched lesson's
/// assignments and — per assignment — either its submission or quiz attempt
/// history. Every field shown comes straight from these real responses.
final courseAssignmentHistoryProvider = FutureProvider.family<List<AssignmentHistoryEntry>, int>((ref, courseId) async {
  final content = await ref.watch(courseContentProvider(courseId).future);
  final progress = await ref.watch(courseProgressProvider(courseId).future);
  if (progress == null) return [];

  final touchedLessonIds = progress.lessons.where((l) => l.status != 'not_started').map((l) => l.lessonId).toSet();
  if (touchedLessonIds.isEmpty) return [];

  final lessonRepo = ref.watch(lessonRepositoryProvider);
  final assignmentRepo = ref.watch(assignmentRepositoryProvider);
  final quizRepo = ref.watch(quizRepositoryProvider);

  final touchedLessons = <Lesson>[
    for (final module in content.modules)
      for (final lesson in module.lessons)
        if (touchedLessonIds.contains(lesson.id)) lesson,
  ];

  final entries = <AssignmentHistoryEntry>[];
  for (final lesson in touchedLessons) {
    final assignmentsResult = await lessonRepo.listAssignments(lesson.id);
    if (assignmentsResult is! ApiOk<List<Assignment>>) continue;

    for (final assignment in assignmentsResult.data) {
      if (assignment.assignmentType == 'quiz') {
        final historyResult = await quizRepo.listAttempts(assignment.id);
        if (historyResult is ApiOk<QuizAttemptHistory> && historyResult.data.attemptsUsed > 0) {
          entries.add(AssignmentHistoryEntry(assignment: assignment, quizHistory: historyResult.data));
        }
      } else {
        final submissionResult = await assignmentRepo.getMine(assignment.id);
        if (submissionResult is ApiOk<Submission?> && submissionResult.data != null) {
          entries.add(AssignmentHistoryEntry(assignment: assignment, submission: submissionResult.data));
        }
      }
    }
  }
  return entries;
});
