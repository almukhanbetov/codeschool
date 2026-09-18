import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_text.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/models/support.dart';
import '../application/support_providers.dart';

/// POST /support/threads — a new support request (brief §4). `category`
/// is one of the real [supportThreadCategories] only.
class SupportNewThreadScreen extends ConsumerStatefulWidget {
  const SupportNewThreadScreen({super.key});

  @override
  ConsumerState<SupportNewThreadScreen> createState() => _SupportNewThreadScreenState();
}

class _SupportNewThreadScreenState extends ConsumerState<SupportNewThreadScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _category = supportThreadCategories.first;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = ref.read(appStringsProvider);
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();
    if (subject.isEmpty || message.isEmpty) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    final result = await ref.read(supportRepositoryProvider).createThread(
          subject: subject,
          category: _category,
          message: message,
        );
    if (!mounted) return;
    switch (result) {
      case ApiOk(:final data):
        ref.invalidate(supportThreadsProvider);
        ref.invalidate(supportUnreadCountProvider);
        context.pushReplacement(AppRoutes.supportThreadDetailPath(data.id));
      case ApiErr(:final error):
        setState(() {
          _submitting = false;
          _error = apiErrorText(t, error);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appStringsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t('chat.newThread'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _subjectController,
            decoration: InputDecoration(labelText: t('chat.subject'), border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: InputDecoration(labelText: t('chat.category'), border: const OutlineInputBorder()),
            items: [
              for (final c in supportThreadCategories) DropdownMenuItem(value: c, child: Text(t('chat.category.$c'))),
            ],
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            maxLines: 5,
            decoration: InputDecoration(labelText: t('chat.message'), border: const OutlineInputBorder()),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 16),
          _submitting
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(onPressed: _submit, child: Text(t('chat.createSubmit'))),
        ],
      ),
    );
  }
}
