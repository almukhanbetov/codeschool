import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/models/app_role.dart';
import '../../../shared/models/support.dart';
import '../../auth/application/auth_controller.dart';
import '../application/support_providers.dart';

/// GET /support/threads — real support-chat threads only (brief §4). Also
/// the notifications entry point (brief §3): the unread badge here IS the
/// real notifications signal, since the backend has no separate
/// notifications feed (see [SupportRepository]'s doc comment and
/// `common.notificationsNote`).
class SupportThreadListScreen extends ConsumerWidget {
  const SupportThreadListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final role = ref.watch(authControllerProvider).valueOrNull?.role;
    final supported = role == AppRole.student || role == AppRole.parent;

    return Scaffold(
      appBar: AppBar(title: Text(t('chat.title'))),
      floatingActionButton: supported
          ? FloatingActionButton(
              onPressed: () => context.push(AppRoutes.supportNewThread),
              child: const Icon(LucideIcons.plus),
            )
          : null,
      body: !supported
          ? EmptyView(message: t('chat.notAvailableForRole'), icon: LucideIcons.messageCircle)
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(LucideIcons.info, size: 16, color: Theme.of(context).colorScheme.outline),
                          const SizedBox(width: 8),
                          Expanded(child: Text(t('common.notificationsNote'), style: Theme.of(context).textTheme.bodySmall)),
                        ],
                      ),
                    ),
                  ),
                ),
                const Expanded(child: _ThreadList()),
              ],
            ),
    );
  }
}

class _ThreadList extends ConsumerWidget {
  const _ThreadList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final threadsAsync = ref.watch(supportThreadsProvider);

    return threadsAsync.when(
      loading: () => const LoadingView(),
      error: (err, _) => ErrorView(
        message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
        onRetry: () => ref.invalidate(supportThreadsProvider),
      ),
      data: (threads) {
        if (threads.isEmpty) {
          return EmptyView(message: t('chat.empty'), icon: LucideIcons.messageCircle);
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(supportThreadsProvider);
            ref.invalidate(supportUnreadCountProvider);
          },
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: threads.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _ThreadTile(item: threads[i], t: t),
          ),
        );
      },
    );
  }
}

class _ThreadTile extends StatelessWidget {
  const _ThreadTile({required this.item, required this.t});
  final SupportThreadListItem item;
  final dynamic t;

  String _statusLabel() => switch (item.status) {
        'open' => t('chat.statusOpen'),
        'waiting_staff' => t('chat.statusWaitingStaff'),
        'waiting_user' => t('chat.statusWaitingUser'),
        'closed' => t('chat.statusClosed'),
        _ => item.status,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.supportThreadDetailPath(item.id)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(item.subject, style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  if (item.unreadCount > 0) Badge(label: Text('${item.unreadCount}')),
                ],
              ),
              const SizedBox(height: 4),
              Text(item.lastMessagePreview, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(label: Text(_statusLabel()), visualDensity: VisualDensity.compact),
                  const SizedBox(width: 8),
                  Chip(label: Text(t('chat.category.${item.category}')), visualDensity: VisualDensity.compact),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
