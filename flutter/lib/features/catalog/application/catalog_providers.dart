import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/models/app_role.dart';
import '../../../shared/models/course.dart';
import '../../../shared/models/course_content.dart';
import '../../../shared/models/enrollment.dart';
import '../../../shared/models/lesson.dart';
import '../../../shared/models/progress.dart';
import '../../auth/application/auth_controller.dart';
import '../data/catalog_repository.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) => CatalogRepository(ref.watch(apiClientProvider)));

/// Age range filter applied server-side (`age_from`/`age_to` query params —
/// the only filter the backend actually supports). `null`/`null` means "all
/// ages". A small fixed set of presets rather than a two-thumb range slider
/// keeps this usable at phone width (brief §3/§8: small-screen adaptation).
class AgeRange {
  const AgeRange(this.from, this.to, this.labelKey);
  final int? from;
  final int? to;
  final String labelKey;

  static const all = AgeRange(null, null, 'catalog.ageAll');
  static const options = [
    all,
    AgeRange(6, 8, 'catalog.age6to8'),
    AgeRange(9, 11, 'catalog.age9to11'),
    AgeRange(12, 14, 'catalog.age12to14'),
    AgeRange(15, 17, 'catalog.age15to17'),
  ];

  @override
  bool operator ==(Object other) => other is AgeRange && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}

class CatalogFilterNotifier extends Notifier<AgeRange> {
  @override
  AgeRange build() => AgeRange.all;

  void setRange(AgeRange range) => state = range;
}

final catalogAgeFilterProvider = NotifierProvider<CatalogFilterNotifier, AgeRange>(CatalogFilterNotifier.new);

class CatalogSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

final catalogSearchProvider = NotifierProvider<CatalogSearchNotifier, String>(CatalogSearchNotifier.new);

/// Refetches from the API whenever the age filter changes; the text search
/// is applied as a pure client-side filter in [filteredCoursesProvider] so
/// typing doesn't re-hit the network on every keystroke.
final coursesProvider = FutureProvider<List<Course>>((ref) async {
  final range = ref.watch(catalogAgeFilterProvider);
  final repo = ref.watch(catalogRepositoryProvider);
  final result = await repo.listCourses(ageFrom: range.from, ageTo: range.to);
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});

final filteredCoursesProvider = Provider<AsyncValue<List<Course>>>((ref) {
  final query = ref.watch(catalogSearchProvider).trim().toLowerCase();
  final courses = ref.watch(coursesProvider);
  if (query.isEmpty) return courses;
  return courses.whenData(
    (list) => list.where((c) {
      final haystack = '${c.title} ${c.shortDescription ?? ''}'.toLowerCase();
      return haystack.contains(query);
    }).toList(),
  );
});

final courseContentProvider = FutureProvider.family<CourseContent, int>((ref, courseId) async {
  final repo = ref.watch(catalogRepositoryProvider);
  final result = await repo.getContent(courseId);
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});

/// Only students can enroll (backend/internal/enrollments/routes.go is
/// mounted behind `RequireRole("student")`), so this stays empty for any
/// other role or signed-out visitor rather than calling an endpoint that
/// would just 401/403 — the enroll button itself is also hidden for them
/// (brief §5/§11: hide what the role can't use, but the backend remains the
/// real access boundary, not this client-side check).
final myCoursesProvider = FutureProvider<List<MyCourseItem>>((ref) async {
  final user = ref.watch(authControllerProvider).valueOrNull;
  if (user == null || user.role != AppRole.student) return [];

  final repo = ref.watch(catalogRepositoryProvider);
  final result = await repo.listMyCourses();
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});

/// Fetches a single lesson fresh via GET /lessons/:id (not derived from
/// [courseContentProvider]'s cache) — see [CatalogRepository.getLessonById]
/// for why the Lesson Details stub screen stays self-sufficient.
final lessonByIdProvider = FutureProvider.family<Lesson, int>((ref, lessonId) async {
  final repo = ref.watch(catalogRepositoryProvider);
  final result = await repo.getLessonById(lessonId);
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});

/// `null` means "nothing to show" — either the viewer isn't a signed-in
/// student, or the backend 403'd because they aren't enrolled in this course
/// yet (`ErrNotEnrolled`, progress/service.go). Both are expected, normal
/// states, not failures, so neither surfaces as an [AsyncError] the course
/// detail screen would have to render an error banner for.
final courseProgressProvider = FutureProvider.family<CourseProgressDetail?, int>((ref, courseId) async {
  final user = ref.watch(authControllerProvider).valueOrNull;
  if (user == null || user.role != AppRole.student) return null;

  final repo = ref.watch(catalogRepositoryProvider);
  final result = await repo.getCourseProgress(courseId);
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr() => null,
  };
});
