import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/models/assignment.dart';
import '../data/assignment_repository.dart';

final assignmentRepositoryProvider =
    Provider<AssignmentRepository>((ref) => AssignmentRepository(ref.watch(apiClientProvider)));

/// GET /assignments/:id/submission — `null` means "no submission yet", a
/// normal state (submissions/handler.go returns 200/null, not 404).
final mySubmissionProvider = FutureProvider.family<Submission?, int>((ref, assignmentId) async {
  final repo = ref.watch(assignmentRepositoryProvider);
  final result = await repo.getMine(assignmentId);
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});
