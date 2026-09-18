import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/models/app_role.dart';
import '../../../shared/models/user.dart';
import '../../auth/application/auth_controller.dart';
import '../../parent/presentation/parent_home_screen.dart';
import '../../support_chat/application/support_providers.dart';
import '../../teacher/presentation/teacher_home_screen.dart';
import 'public_home_screen.dart';
import 'student_home_screen.dart';

/// Role-based landing screen. A guest (no session) sees the real public
/// marketing home (brief §2-§3, Stage 35H) — `/home` never requires
/// authentication, see `app_router.dart`'s `_isPublicLocation`. The student
/// cabinet (Stage 35F) and teacher/parent cabinets (brief §1-§2, Stage 35G)
/// are the real, backend-backed screens for a signed-in user. Admin keeps
/// the Stage 35C placeholder — no admin mobile cabinet was in scope for
/// either brief.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    if (user == null) return const PublicHomeScreen();

    final t = ref.watch(appStringsProvider);
    final chatSupported = user.role == AppRole.student || user.role == AppRole.parent;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('common.appName')),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bookOpen),
            tooltip: t('catalog.title'),
            onPressed: () => context.push(AppRoutes.catalog),
          ),
          if (chatSupported) const _NotificationsButton(),
          IconButton(
            icon: const Icon(LucideIcons.logOut),
            tooltip: t('common.logout'),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: switch (user.role) {
        AppRole.student => StudentHomeScreen(user: user),
        AppRole.teacher => TeacherHomeScreen(user: user),
        AppRole.parent => ParentHomeScreen(user: user),
        AppRole.admin => _PlaceholderWelcome(user: user),
      },
    );
  }
}

/// The real notifications entry point (brief §3) — the unread support
/// thread count is the only "notification" signal the backend has (see
/// `SupportRepository`'s doc comment); tapping it opens the thread list.
class _NotificationsButton extends ConsumerWidget {
  const _NotificationsButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final unread = ref.watch(supportUnreadCountProvider).valueOrNull;
    final count = unread?.threads ?? 0;

    return IconButton(
      tooltip: t('common.notifications'),
      onPressed: () => context.push(AppRoutes.supportThreads),
      icon: count > 0
          ? Badge(label: Text('$count'), child: const Icon(LucideIcons.bell))
          : const Icon(LucideIcons.bell),
    );
  }
}

/// Admin has no mobile cabinet yet (out of scope for both Stage 35G and
/// this stage) — this stays the Stage 35C placeholder.
class _PlaceholderWelcome extends ConsumerWidget {
  const _PlaceholderWelcome({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              t('home.admin.welcome'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(t('common.role.${user.role.name}'), style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
