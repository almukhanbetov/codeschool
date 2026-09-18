import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/models/app_role.dart';
import '../../../shared/models/lesson.dart';
import '../../auth/application/auth_controller.dart';
import '../application/catalog_providers.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  const CourseDetailScreen({super.key, required this.courseId});
  final int courseId;

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  bool _enrolling = false;

  Future<void> _enroll() async {
    final t = ref.read(appStringsProvider);
    setState(() => _enrolling = true);
    final result = await ref.read(catalogRepositoryProvider).enroll(widget.courseId);
    if (!mounted) return;
    setState(() => _enrolling = false);

    switch (result) {
      case ApiOk():
        ref.invalidate(myCoursesProvider);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('catalog.enrollSuccess'))));
      case ApiErr(:final error):
        final message = error.statusCode == 409 ? t('catalog.alreadyEnrolled') : apiErrorText(t, error);
        if (error.statusCode == 409) ref.invalidate(myCoursesProvider);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appStringsProvider);
    final contentAsync = ref.watch(courseContentProvider(widget.courseId));

    return Scaffold(
      appBar: AppBar(title: Text(t('course.about'))),
      body: contentAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: err is ApiException ? apiErrorText(t, err) : t('catalog.loadError'),
          onRetry: () => ref.invalidate(courseContentProvider(widget.courseId)),
        ),
        data: (content) {
          final course = content.course;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(course.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (course.ageFrom != null && course.ageTo != null)
                    Chip(label: Text('${course.ageFrom}–${course.ageTo} ${t('catalog.years')}')),
                  if (course.durationLessons != null)
                    Chip(label: Text('${course.durationLessons} ${t('catalog.lessons')}')),
                  if (course.projectsCount != null && course.projectsCount! > 0)
                    Chip(label: Text('${course.projectsCount} ${t('catalog.projects')}')),
                ],
              ),
              if (course.description != null) ...[
                const SizedBox(height: 16),
                Text(course.description!, style: Theme.of(context).textTheme.bodyLarge),
              ],
              const SizedBox(height: 24),
              _EnrollSection(courseId: widget.courseId, enrolling: _enrolling, onEnroll: _enroll),
              _CourseProgressSection(courseId: widget.courseId),
              const SizedBox(height: 24),
              Text(t('course.modules'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...content.modules.map((m) => _ModuleTile(courseId: widget.courseId, module: m)),
            ],
          );
        },
      ),
    );
  }
}

class _EnrollSection extends ConsumerWidget {
  const _EnrollSection({required this.courseId, required this.enrolling, required this.onEnroll});
  final int courseId;
  final bool enrolling;
  final VoidCallback onEnroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final user = ref.watch(authControllerProvider).valueOrNull;

    if (user == null) {
      return OutlinedButton.icon(
        onPressed: () => context.push(AppRoutes.loginWithNext(AppRoutes.courseDetailPath(courseId))),
        icon: const Icon(LucideIcons.logIn),
        label: Text(t('auth.loginSubmit')),
      );
    }

    if (user.role != AppRole.student) return const SizedBox.shrink();

    final myCourses = ref.watch(myCoursesProvider);
    return myCourses.when(
      loading: () => const SizedBox(height: 52, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (_, _) => ElevatedButton(
        onPressed: enrolling ? null : onEnroll,
        child: Text(t('catalog.enroll')),
      ),
      data: (items) {
        final alreadyEnrolled = items.any((m) => m.course.id == courseId);
        if (alreadyEnrolled) {
          return OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(LucideIcons.circleCheck),
            label: Text(t('catalog.enrolled')),
          );
        }
        return ElevatedButton(
          onPressed: enrolling ? null : onEnroll,
          child: Text(enrolling ? t('auth.submitting') : t('catalog.enroll')),
        );
      },
    );
  }
}

/// Catalog -> Course Details -> **Module** (tap navigates, per the brief's
/// navigation hierarchy) rather than expanding lessons inline.
class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.courseId, required this.module});
  final int courseId;
  final CourseModule module;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text('${module.position}. ${module.title}', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: module.lessons.isNotEmpty ? Text('${module.lessons.length}') : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(AppRoutes.moduleDetailPath(courseId, module.id)),
      ),
    );
  }
}

/// Shown only for a signed-in student who is enrolled — `null` from
/// [courseProgressProvider] covers both "not a student" and "not enrolled
/// yet" (a real 403 from the backend), so this section just disappears
/// rather than showing an error for an entirely expected state.
class _CourseProgressSection extends ConsumerWidget {
  const _CourseProgressSection({required this.courseId});
  final int courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final progressAsync = ref.watch(courseProgressProvider(courseId));

    return progressAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (progress) {
        if (progress == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('progress.courseProgress'), style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(value: progress.progressPercent / 100, minHeight: 8),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${t('progress.completedLessons')}: ${progress.completedLessons}/${progress.totalLessons} (${progress.progressPercent}%)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
