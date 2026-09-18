import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../../core/widgets/theme_toggle.dart';
import '../../../shared/models/course.dart';
import '../../catalog/application/catalog_providers.dart';

/// The public marketing home page (brief §2/§3, Stage 35H) — what a guest
/// (no session) sees at `/home` instead of being forced straight to
/// `/login`. Visual language ported from the web's `HeroSection`/
/// `DirectionsSection`/`WhyUsSection` (`frontend/components/sections/*`,
/// `frontend/app/globals.css` design tokens), adapted for a phone screen.
/// Course data is the real `GET /courses` catalog (no auth, same endpoint
/// the catalog screen uses) — nothing fabricated; categories/advantages are
/// static copy (like the web's own `data/directions.ts`), not statistics.
class PublicHomeScreen extends ConsumerWidget {
  const PublicHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      bottomNavigationBar: const _PublicBottomNav(),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            _HeroBlock(),
            SizedBox(height: 28),
            _CategoriesSection(),
            SizedBox(height: 28),
            _PopularProgramsSection(),
            SizedBox(height: 28),
            _AdvantagesSection(),
            SizedBox(height: 28),
            _AudienceSection(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _HeroBlock extends ConsumerWidget {
  const _HeroBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark ? AppColors.gradientDark : AppColors.gradientLight;

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.codeXml, color: Colors.white, size: 26),
              const SizedBox(width: 8),
              const Text(
                'CodeSchool.kz',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const Spacer(),
              const LanguageSwitcher(color: Colors.white),
              const ThemeToggle(color: Colors.white),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              t('public.hero.badge'),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${t('public.hero.title1')}\n${t('public.hero.title2')}',
            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, height: 1.15),
          ),
          const SizedBox(height: 12),
          Text(
            t('public.hero.subtitle'),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.92), fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: isDark ? AppColors.accentDark : AppColors.accentLight,
                  ),
                  onPressed: () => context.push(AppRoutes.register),
                  icon: const Icon(LucideIcons.arrowRight, size: 18),
                  label: Text(t('course.startLearning')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                  ),
                  onPressed: () => context.push(AppRoutes.catalog),
                  child: Text(t('public.hero.cta2')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
    );
  }
}

/// Real directions (mirrors the web's `data/directions.ts`) — only the
/// three the brief explicitly names. Tapping opens the full catalog: the
/// backend has no `category` filter to query against (only
/// `age_from`/`age_to`/`level_id`, see `CatalogRepository`), so these are
/// honest navigational entries, not a fake per-category course count.
class _CategoriesSection extends ConsumerWidget {
  const _CategoriesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final items = [
      (LucideIcons.terminalSquare, t('public.categories.programming'), t('public.categories.programmingDesc')),
      (LucideIcons.bot, t('public.categories.robotics'), t('public.categories.roboticsDesc')),
      (LucideIcons.brainCircuit, t('public.categories.ai'), t('public.categories.aiDesc')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(title: t('public.categories.title')),
        SizedBox(
          height: 172,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final (icon, title, desc) = items[i];
              return _CategoryCard(icon: icon, title: title, desc: desc);
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.icon, required this.title, required this.desc});
  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 168,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(AppRoutes.catalog),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: isDark ? AppColors.gradientDark : AppColors.gradientLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(height: 10),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(desc, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Real `GET /courses` data (public, no auth — [coursesProvider] already
/// backs the catalog screen). Never a hand-written "popular" list.
class _PopularProgramsSection extends ConsumerWidget {
  const _PopularProgramsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final coursesAsync = ref.watch(coursesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t('public.programs.title'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              TextButton(onPressed: () => context.push(AppRoutes.catalog), child: Text(t('catalog.more'))),
            ],
          ),
        ),
        coursesAsync.when(
          loading: () => const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              err is ApiException ? apiErrorText(t, err) : t('public.programs.empty'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          data: (courses) {
            if (courses.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(t('public.programs.empty'), style: Theme.of(context).textTheme.bodySmall),
              );
            }
            final shown = courses.take(6).toList();
            return SizedBox(
              height: 188,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: shown.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) => _ProgramCard(course: shown[i], t: t),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.course, required this.t});
  final Course course;
  final dynamic t;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ageLabel = course.ageFrom != null && course.ageTo != null ? '${course.ageFrom}–${course.ageTo} ${t('catalog.years')}' : null;

    return SizedBox(
      width: 220,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(AppRoutes.courseDetailPath(course.id)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: isDark ? AppColors.gradientDark : AppColors.gradientLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.bookOpen, color: Colors.white, size: 18),
                ),
                const SizedBox(height: 10),
                Text(course.title, style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                const Spacer(),
                if (ageLabel != null) Text(ageLabel, style: Theme.of(context).textTheme.bodySmall),
                if (course.durationLessons != null)
                  Text('${course.durationLessons} ${t('catalog.lessons')}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Feature bullets — same idea as the web's `WhyUsSection`, adapted to real
/// mobile-app features that actually exist (AI mentor, Teacher Academy,
/// certificates, Code Runner) rather than invented marketing numbers.
class _AdvantagesSection extends ConsumerWidget {
  const _AdvantagesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final items = [
      (LucideIcons.target, t('public.advantages.a1')),
      (LucideIcons.brainCircuit, t('public.advantages.a2')),
      (LucideIcons.award, t('public.advantages.a3')),
      (LucideIcons.graduationCap, t('public.advantages.a4')),
      (LucideIcons.languages, t('public.advantages.a5')),
      (LucideIcons.terminalSquare, t('public.advantages.a6')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(title: t('public.advantages.title')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.4,
            children: items
                .map(
                  (e) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(e.$1, size: 20, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 10),
                          Expanded(child: Text(e.$2, style: Theme.of(context).textTheme.bodySmall)),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

/// "Информация для учеников, родителей и преподавателей" (brief §2).
class _AudienceSection extends ConsumerWidget {
  const _AudienceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final items = [
      (LucideIcons.bookOpen, t('public.audience.students'), t('public.audience.studentsDesc')),
      (LucideIcons.users, t('public.audience.parents'), t('public.audience.parentsDesc')),
      (LucideIcons.graduationCap, t('public.audience.teachers'), t('public.audience.teachersDesc')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(title: t('public.audience.title')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: items
                .map(
                  (e) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(e.$1, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.$2, style: const TextStyle(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(e.$3, style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => context.push(AppRoutes.register),
                            child: Text(t('public.audience.cta')),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

/// Bottom navigation for a guest (brief §2 "Нижнюю навигацию"). Only three
/// destinations exist without a session — Home (this screen), the public
/// Catalog, and Login — a full app-wide shell/bottom-nav for every
/// authenticated screen is a separate, larger change not attempted here.
class _PublicBottomNav extends ConsumerWidget {
  const _PublicBottomNav();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);

    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        switch (index) {
          case 1:
            context.push(AppRoutes.catalog);
          case 2:
            context.push(AppRoutes.login);
        }
      },
      destinations: [
        NavigationDestination(icon: const Icon(LucideIcons.house), label: t('public.nav.home')),
        NavigationDestination(icon: const Icon(LucideIcons.bookOpen), label: t('public.nav.catalog')),
        NavigationDestination(icon: const Icon(LucideIcons.logIn), label: t('public.nav.login')),
      ],
    );
  }
}
