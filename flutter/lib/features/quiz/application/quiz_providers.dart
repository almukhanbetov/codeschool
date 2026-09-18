import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/models/quiz.dart';
import '../data/quiz_repository.dart';

final quizRepositoryProvider = Provider<QuizRepository>((ref) => QuizRepository(ref.watch(apiClientProvider)));

/// GET /assignments/:id/quiz/attempts — history + real retry eligibility
/// (`canStart`/`attemptsLeft`/`maxAttempts`), never guessed client-side.
final quizHistoryProvider = FutureProvider.family<QuizAttemptHistory, int>((ref, assignmentId) async {
  final repo = ref.watch(quizRepositoryProvider);
  final result = await repo.listAttempts(assignmentId);
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});

/// GET /quiz/attempts/:id.
final attemptDetailProvider = FutureProvider.family<AttemptDetail, int>((ref, attemptId) async {
  final repo = ref.watch(quizRepositoryProvider);
  final result = await repo.getAttempt(attemptId);
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});
