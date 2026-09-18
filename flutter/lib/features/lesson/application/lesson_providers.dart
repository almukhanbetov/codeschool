import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/models/assignment.dart';
import '../data/lesson_repository.dart';

final lessonRepositoryProvider = Provider<LessonRepository>((ref) => LessonRepository(ref.watch(apiClientProvider)));

/// GET /lessons/:id/assignments — requires an enrolled student; a 403 from
/// the backend (not enrolled / not a student) is a real, expected state the
/// screen degrades on rather than treating as a fetch failure.
final lessonAssignmentsProvider = FutureProvider.family<List<Assignment>, int>((ref, lessonId) async {
  final repo = ref.watch(lessonRepositoryProvider);
  final result = await repo.listAssignments(lessonId);
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => error.isForbidden || error.isUnauthorized ? <Assignment>[] : throw error,
  };
});
