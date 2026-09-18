import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeschool_mobile/core/network/api_client.dart';
import 'package:codeschool_mobile/core/network/api_exception.dart';
import 'package:codeschool_mobile/features/catalog/application/catalog_providers.dart';
import 'package:codeschool_mobile/features/catalog/data/catalog_repository.dart';
import 'package:codeschool_mobile/shared/models/course.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

Course _course(int id, String title, {String? shortDescription}) => Course(
      id: id,
      levelId: 1,
      title: title,
      slug: 'course-$id',
      shortDescription: shortDescription,
      audience: 'student',
    );

void main() {
  group('AgeRange', () {
    test('two ranges with the same bounds are equal regardless of label', () {
      const a = AgeRange(6, 8, 'catalog.age6to8');
      const b = AgeRange(6, 8, 'a different label key');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('all-ages preset carries null bounds', () {
      expect(AgeRange.all.from, isNull);
      expect(AgeRange.all.to, isNull);
    });
  });

  group('coursesProvider + filteredCoursesProvider', () {
    late MockCatalogRepository repo;
    late ProviderContainer container;

    setUp(() {
      repo = MockCatalogRepository();
      container = ProviderContainer(overrides: [catalogRepositoryProvider.overrideWithValue(repo)]);
      addTearDown(container.dispose);
    });

    test('fetches with no age params for the "all ages" default filter', () async {
      when(() => repo.listCourses(ageFrom: null, ageTo: null, levelId: null)).thenAnswer(
        (_) async => ApiResult.ok([_course(1, 'Scratch Junior'), _course(2, 'Python для детей')]),
      );

      final courses = await container.read(coursesProvider.future);
      expect(courses, hasLength(2));
      verify(() => repo.listCourses(ageFrom: null, ageTo: null, levelId: null)).called(1);
    });

    test('changing the age filter re-fetches with the new age_from/age_to', () async {
      when(() => repo.listCourses(ageFrom: null, ageTo: null, levelId: null))
          .thenAnswer((_) async => ApiResult.ok([_course(1, 'All ages course')]));
      when(() => repo.listCourses(ageFrom: 9, ageTo: 11, levelId: null))
          .thenAnswer((_) async => ApiResult.ok([_course(2, '9-11 course')]));

      await container.read(coursesProvider.future);
      container.read(catalogAgeFilterProvider.notifier).setRange(const AgeRange(9, 11, 'catalog.age9to11'));
      final refetched = await container.read(coursesProvider.future);

      expect(refetched.single.title, '9-11 course');
      verify(() => repo.listCourses(ageFrom: 9, ageTo: 11, levelId: null)).called(1);
    });

    test('search filters client-side by title without re-hitting the repository', () async {
      when(() => repo.listCourses(ageFrom: null, ageTo: null, levelId: null)).thenAnswer(
        (_) async => ApiResult.ok([
          _course(1, 'Scratch Junior', shortDescription: 'Визуальное программирование'),
          _course(2, 'Python для детей'),
        ]),
      );

      await container.read(coursesProvider.future);
      container.read(catalogSearchProvider.notifier).setQuery('scratch');

      final filtered = container.read(filteredCoursesProvider);
      expect(filtered.value, hasLength(1));
      expect(filtered.value!.single.title, 'Scratch Junior');
      verify(() => repo.listCourses(ageFrom: null, ageTo: null, levelId: null)).called(1);
    });

    test('a failed fetch surfaces as an AsyncError carrying the ApiException', () async {
      when(() => repo.listCourses(ageFrom: null, ageTo: null, levelId: null))
          .thenAnswer((_) async => ApiResult.err(ApiException.network()));

      await expectLater(container.read(coursesProvider.future), throwsA(isA<ApiException>()));
    });
  });
}
