import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/models/teacher.dart';
import '../data/teacher_repository.dart';

final teacherRepositoryProvider = Provider<TeacherRepository>((ref) => TeacherRepository(ref.watch(apiClientProvider)));

final teacherDashboardProvider = FutureProvider<TeacherDashboard>((ref) async {
  final result = await ref.watch(teacherRepositoryProvider).dashboard();
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});

final teacherGroupsProvider = FutureProvider<List<TeacherGroupListItem>>((ref) async {
  final result = await ref.watch(teacherRepositoryProvider).listGroups();
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});

final teacherGroupDetailProvider = FutureProvider.family<TeacherGroupDetail, int>((ref, groupId) async {
  final result = await ref.watch(teacherRepositoryProvider).getGroup(groupId);
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});

final teacherGroupStudentsProvider = FutureProvider.family<List<TeacherGroupStudentItem>, int>((ref, groupId) async {
  final result = await ref.watch(teacherRepositoryProvider).listGroupStudents(groupId);
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});

/// Keyed by (groupId, studentId) — a record is a clean family key without
/// inventing a wrapper class just to carry two ints.
final teacherStudentDetailProvider = FutureProvider.family<TeacherStudentDetail, (int groupId, int studentId)>((ref, key) async {
  final result = await ref.watch(teacherRepositoryProvider).getGroupStudent(key.$1, key.$2);
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});

/// `null` status = every status (the review queue's default "all" tab).
class SubmissionQueueFilter {
  const SubmissionQueueFilter({this.status});
  final String? status;

  @override
  bool operator ==(Object other) => other is SubmissionQueueFilter && other.status == status;

  @override
  int get hashCode => status.hashCode;
}

class SubmissionQueueFilterNotifier extends Notifier<SubmissionQueueFilter> {
  @override
  SubmissionQueueFilter build() => const SubmissionQueueFilter();

  void setStatus(String? status) => state = SubmissionQueueFilter(status: status);
}

final submissionQueueFilterProvider = NotifierProvider<SubmissionQueueFilterNotifier, SubmissionQueueFilter>(
  SubmissionQueueFilterNotifier.new,
);

final teacherSubmissionsProvider = FutureProvider<TeacherSubmissionListResult>((ref) async {
  final filter = ref.watch(submissionQueueFilterProvider);
  final result = await ref.watch(teacherRepositoryProvider).listSubmissions(status: filter.status, limit: 50);
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});

final teacherSubmissionDetailProvider = FutureProvider.family<TeacherSubmissionDetail, int>((ref, id) async {
  final result = await ref.watch(teacherRepositoryProvider).getSubmission(id);
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});
