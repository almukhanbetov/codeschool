import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/models/run.dart';
import '../data/code_runner_repository.dart';

final codeRunnerRepositoryProvider =
    Provider<CodeRunnerRepository>((ref) => CodeRunnerRepository(ref.watch(apiClientProvider)));

/// GET /assignments/:id/tests — the visible sample tests shown above the
/// Run button, so the student knows what their code needs to handle.
final assignmentTestsProvider = FutureProvider.family<TestsResponse, int>((ref, assignmentId) async {
  final repo = ref.watch(codeRunnerRepositoryProvider);
  final result = await repo.getTests(assignmentId);
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});
