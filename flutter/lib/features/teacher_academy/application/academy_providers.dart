import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/models/academy.dart';
import '../data/academy_repository.dart';

final academyRepositoryProvider = Provider<AcademyRepository>((ref) => AcademyRepository(ref.watch(apiClientProvider)));

final academyDashboardProvider = FutureProvider<AcademyDashboard>((ref) async {
  final result = await ref.watch(academyRepositoryProvider).dashboard();
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});

final academyCoursesProvider = FutureProvider<List<AcademyCourseCard>>((ref) async {
  final result = await ref.watch(academyRepositoryProvider).listCourses();
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});
