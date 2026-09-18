import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/models/lesson.dart';
import '../application/catalog_providers.dart';
import 'lesson_type_icon.dart';

/// Catalog -> Course Details -> **Module** -> Lesson. Reuses the course's
/// already-fetched `/courses/:id/content` (via [courseContentProvider]) —
/// the module/lesson list it needs is already in that response, so a second
/// `/courses/:id/modules` + `/modules/:id/lessons` round trip would just
/// re-fetch data already in hand (see `CatalogRepository.listModules` for
/// where those endpoints are still exercised directly).
class ModuleScreen extends ConsumerWidget {
  const ModuleScreen({super.key, required this.courseId, required this.moduleId});
  final int courseId;
  final int moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final contentAsync = ref.watch(courseContentProvider(courseId));

    return Scaffold(
      appBar: AppBar(title: Text(t('course.modules'))),
      body: contentAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: err is ApiException ? apiErrorText(t, err) : t('catalog.loadError'),
          onRetry: () => ref.invalidate(courseContentProvider(courseId)),
        ),
        data: (content) {
          CourseModule? module;
          for (final m in content.modules) {
            if (m.id == moduleId) {
              module = m;
              break;
            }
          }
          if (module == null) {
            return EmptyView(message: t('error.notFound'));
          }

          final lessons = [...module.lessons]..sort((a, b) => a.position.compareTo(b.position));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '${module.position}. ${module.title}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (module.description != null && module.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(module.description!, style: Theme.of(context).textTheme.bodyLarge),
              ],
              const SizedBox(height: 20),
              if (lessons.isEmpty)
                EmptyView(message: t('common.emptyGeneric'))
              else
                ...lessons.map((lesson) => _LessonListTile(courseId: courseId, moduleId: moduleId, lesson: lesson)),
            ],
          );
        },
      ),
    );
  }
}

class _LessonListTile extends ConsumerWidget {
  const _LessonListTile({required this.courseId, required this.moduleId, required this.lesson});
  final int courseId;
  final int moduleId;
  final Lesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(lessonTypeIcon(lesson.lessonType)),
        title: Text('${lesson.position}. ${lesson.title}'),
        subtitle: lesson.description != null ? Text(lesson.description!, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
        trailing: _LessonStatusIcon(courseId: courseId, lessonId: lesson.id),
        onTap: () => context.push(AppRoutes.lessonDetailPath(courseId, moduleId, lesson.id)),
      ),
    );
  }
}

/// Per-lesson progress marker (brief §5: "отображение прогресса по
/// модулям") — reads the already-fetched course progress (`null` for a
/// guest/non-enrolled student, an expected state, not an error) and shows a
/// checkmark/dot only for lessons the backend actually has status for.
class _LessonStatusIcon extends ConsumerWidget {
  const _LessonStatusIcon({required this.courseId, required this.lessonId});
  final int courseId;
  final int lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(courseProgressProvider(courseId));
    return progressAsync.when(
      loading: () => const Icon(Icons.chevron_right),
      error: (_, _) => const Icon(Icons.chevron_right),
      data: (progress) {
        if (progress == null) return const Icon(Icons.chevron_right);
        String? status;
        for (final l in progress.lessons) {
          if (l.lessonId == lessonId) {
            status = l.status;
            break;
          }
        }
        return switch (status) {
          'completed' => Icon(LucideIcons.circleCheck, color: Theme.of(context).colorScheme.tertiary),
          'in_progress' => Icon(LucideIcons.circleDot, color: Theme.of(context).colorScheme.primary),
          _ => const Icon(Icons.chevron_right),
        };
      },
    );
  }
}
