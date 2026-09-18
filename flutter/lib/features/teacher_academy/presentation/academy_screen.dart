import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/models/academy.dart';
import '../application/academy_providers.dart';

/// GET /teacher-academy/dashboard + /teacher-academy/courses (brief §1
/// "Teacher Academy"). Scoped to catalog/dashboard/enrollment only — taking
/// a lesson would reuse the student lesson/quiz/code-runner screens under a
/// prefix-aware provider, a cross-cutting change out of scope for this
/// stage (see [AcademyRepository]'s doc comment and the report).
class AcademyScreen extends ConsumerWidget {
  const AcademyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final dashAsync = ref.watch(academyDashboardProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t('teacher.academy.title')),
          bottom: TabBar(tabs: [
            Tab(text: t('teacher.academy.dashboard')),
            Tab(text: t('teacher.academy.catalog')),
          ]),
        ),
        body: TabBarView(
          children: [
            dashAsync.when(
              loading: () => const LoadingView(),
              error: (err, _) => ErrorView(
                message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
                onRetry: () => ref.invalidate(academyDashboardProvider),
              ),
              data: (dash) => _DashboardTab(dash: dash, t: t),
            ),
            const _CatalogTab(),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({required this.dash, required this.t});
  final AcademyDashboard dash;
  final dynamic t;

  @override
  Widget build(BuildContext context) {
    if (dash.courses.isEmpty) {
      return EmptyView(message: t('teacher.academy.empty'), icon: LucideIcons.graduationCap);
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _StatChip(label: t('teacher.academy.myCourses'), value: '${dash.totalCourses}'),
            const SizedBox(width: 8),
            _StatChip(label: '%', value: '${dash.overallPercent}%'),
          ],
        ),
        const SizedBox(height: 16),
        for (final c in dash.courses) _MyCourseTile(course: c),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}

class _MyCourseTile extends StatelessWidget {
  const _MyCourseTile({required this.course});
  final AcademyMyCourse course;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(course.title, style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                if (course.courseCompleted) const Icon(LucideIcons.circleCheck, color: Colors.green),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: course.progressPercent / 100, minHeight: 6),
            ),
            const SizedBox(height: 6),
            Text('${course.progressPercent}% · ${course.completedLessons}/${course.totalLessons}', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _CatalogTab extends ConsumerWidget {
  const _CatalogTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final coursesAsync = ref.watch(academyCoursesProvider);

    return coursesAsync.when(
      loading: () => const LoadingView(),
      error: (err, _) => ErrorView(
        message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
        onRetry: () => ref.invalidate(academyCoursesProvider),
      ),
      data: (courses) {
        if (courses.isEmpty) {
          return EmptyView(message: t('teacher.academy.empty'), icon: LucideIcons.bookOpen);
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(academyCoursesProvider.future),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _CatalogCard(course: courses[i]),
          ),
        );
      },
    );
  }
}

class _CatalogCard extends ConsumerStatefulWidget {
  const _CatalogCard({required this.course});
  final AcademyCourseCard course;

  @override
  ConsumerState<_CatalogCard> createState() => _CatalogCardState();
}

class _CatalogCardState extends ConsumerState<_CatalogCard> {
  bool _enrolling = false;
  bool _justEnrolled = false;

  Future<void> _enroll() async {
    setState(() => _enrolling = true);
    final repo = ref.read(academyRepositoryProvider);
    final result = await repo.enroll(widget.course.id);
    if (!mounted) return;
    setState(() {
      _enrolling = false;
      _justEnrolled = result is ApiOk;
    });
    if (result is ApiOk) {
      ref.invalidate(academyCoursesProvider);
      ref.invalidate(academyDashboardProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appStringsProvider);
    final enrolled = widget.course.enrolled || _justEnrolled;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.course.title, style: const TextStyle(fontWeight: FontWeight.w700)),
            if (widget.course.shortDescription != null) ...[
              const SizedBox(height: 4),
              Text(widget.course.shortDescription!, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Text('${widget.course.totalLessons}', style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                if (enrolled)
                  Chip(label: Text(t('teacher.academy.enrolled')), visualDensity: VisualDensity.compact)
                else if (_enrolling)
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                else
                  ElevatedButton(onPressed: _enroll, child: Text(t('teacher.academy.enroll'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
