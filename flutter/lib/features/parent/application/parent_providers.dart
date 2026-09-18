import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/models/parent.dart';
import '../data/parent_repository.dart';

final parentRepositoryProvider = Provider<ParentRepository>((ref) => ParentRepository(ref.watch(apiClientProvider)));

final parentChildrenProvider = FutureProvider<List<ParentChildListItem>>((ref) async {
  final result = await ref.watch(parentRepositoryProvider).listChildren();
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});

final childOverviewProvider = FutureProvider.family<ParentChildOverview, int>((ref, childId) async {
  final result = await ref.watch(parentRepositoryProvider).getChild(childId);
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});

final childCourseDetailProvider = FutureProvider.family<ParentChildCourseDetail, (int childId, int courseId)>((ref, key) async {
  final result = await ref.watch(parentRepositoryProvider).getChildCourse(key.$1, key.$2);
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});

final childActivityProvider = FutureProvider.family<ParentActivitySummary, int>((ref, childId) async {
  final result = await ref.watch(parentRepositoryProvider).getChildActivity(childId);
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});
