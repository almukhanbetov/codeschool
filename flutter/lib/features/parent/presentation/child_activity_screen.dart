import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/models/parent.dart';
import '../application/parent_providers.dart';

/// GET /parent/children/:id/activity — a raw event timeline, `type` shown
/// as-is (the backend's own free-form event kind, never re-labelled into
/// an invented closed set — see [ParentActivityItem]'s doc comment).
class ChildActivityScreen extends ConsumerWidget {
  const ChildActivityScreen({super.key, required this.childId});
  final int childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);
    final activityAsync = ref.watch(childActivityProvider(childId));

    return Scaffold(
      appBar: AppBar(title: Text(t('parent.activity.title'))),
      body: activityAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
          onRetry: () => ref.invalidate(childActivityProvider(childId)),
        ),
        data: (summary) {
          if (summary.items.isEmpty) {
            return EmptyView(message: t('parent.activity.empty'), icon: LucideIcons.activity);
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(childActivityProvider(childId).future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: summary.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _ActivityTile(item: summary.items[i]),
            ),
          );
        },
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item});
  final ParentActivityItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(LucideIcons.activity),
        title: Text(item.assignmentTitle ?? item.lessonTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${item.type} · ${item.courseTitle}', maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Text('${item.at.day.toString().padLeft(2, '0')}.${item.at.month.toString().padLeft(2, '0')}'),
      ),
    );
  }
}
