import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_text.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/models/support.dart';
import '../application/support_providers.dart';

/// GET/POST /support/threads/:id/messages (brief §4). Marks the thread
/// read on open ("Отметка о прочтении") and polls for new messages with a
/// plain widget-level `Timer.periodic` — kept out of the provider layer on
/// purpose so widget tests can drive it with explicit `tester.pump()`
/// instead of `pumpAndSettle()` (a repeating timer never settles).
class SupportThreadDetailScreen extends ConsumerStatefulWidget {
  const SupportThreadDetailScreen({super.key, required this.threadId});
  final int threadId;

  @override
  ConsumerState<SupportThreadDetailScreen> createState() => _SupportThreadDetailScreenState();
}

class _SupportThreadDetailScreenState extends ConsumerState<SupportThreadDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _pollTimer;
  bool _sending = false;
  String? _sendError;
  bool _markedRead = false;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      ref.invalidate(supportMessagesProvider(widget.threadId));
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markRead() async {
    if (_markedRead) return;
    _markedRead = true;
    await ref.read(supportRepositoryProvider).markRead(widget.threadId);
    if (mounted) ref.invalidate(supportUnreadCountProvider);
  }

  Future<void> _send() async {
    final body = _messageController.text.trim();
    if (body.isEmpty) return;
    setState(() {
      _sending = true;
      _sendError = null;
    });
    final result = await ref.read(supportRepositoryProvider).postMessage(widget.threadId, body);
    if (!mounted) return;
    switch (result) {
      case ApiOk():
        _messageController.clear();
        ref.invalidate(supportMessagesProvider(widget.threadId));
        setState(() => _sending = false);
      case ApiErr(:final error):
        setState(() {
          _sending = false;
          _sendError = apiErrorText(ref.read(appStringsProvider), error);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appStringsProvider);
    final threadAsync = ref.watch(supportThreadDetailProvider(widget.threadId));
    final messagesAsync = ref.watch(supportMessagesProvider(widget.threadId));

    threadAsync.whenData((_) => _markRead());

    return Scaffold(
      appBar: AppBar(
        title: Text(threadAsync.valueOrNull?.subject ?? ''),
        bottom: threadAsync.valueOrNull != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(28),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${t('chat.about')}: ${threadAsync.value!.about.studentName}',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const LoadingView(),
              error: (err, _) => ErrorView(
                message: err is ApiException ? apiErrorText(t, err) : t('error.unknown'),
                onRetry: () => ref.invalidate(supportMessagesProvider(widget.threadId)),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return EmptyView(message: t('chat.noMessages'), icon: LucideIcons.messageCircle);
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, i) => _MessageBubble(message: messages[i]),
                );
              },
            ),
          ),
          if (_sendError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(_sendError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: t('chat.typeMessage'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _sending
                      ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                      : IconButton.filled(icon: const Icon(LucideIcons.send), onPressed: _send),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final SupportMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = message.mine;
    final isSystem = message.messageType == 'system';
    if (isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Text(message.body, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
        ),
      );
    }
    final bg = mine ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!mine) Text(message.senderName, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
            SelectableText(message.body),
          ],
        ),
      ),
    );
  }
}
