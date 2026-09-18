import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/models/app_role.dart';
import '../../../shared/models/support.dart';
import '../../auth/application/auth_controller.dart';
import '../data/support_repository.dart';

final supportRepositoryProvider = Provider<SupportRepository>((ref) => SupportRepository(ref.watch(apiClientProvider)));

/// `true` only for the two roles the backend actually allows on
/// `/support/*` (`RequireRole("student","parent")` — teachers explicitly
/// excluded, per the backend's own comment).
bool _supportsChat(AppRole? role) => role == AppRole.student || role == AppRole.parent;

final supportThreadsProvider = FutureProvider<List<SupportThreadListItem>>((ref) async {
  final user = ref.watch(authControllerProvider).valueOrNull;
  if (!_supportsChat(user?.role)) return [];

  final result = await ref.watch(supportRepositoryProvider).listThreads();
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});

/// The real "notifications" signal (see [SupportRepository]'s doc comment)
/// — `null` for a role that has no support-chat access at all (not zero,
/// so the UI can tell "no badge to show" apart from "0 unread").
final supportUnreadCountProvider = FutureProvider<SupportUnreadCount?>((ref) async {
  final user = ref.watch(authControllerProvider).valueOrNull;
  if (!_supportsChat(user?.role)) return null;

  final result = await ref.watch(supportRepositoryProvider).unreadCount();
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr() => null,
  };
});

final supportThreadDetailProvider = FutureProvider.family<SupportThreadDetail, int>((ref, threadId) async {
  final result = await ref.watch(supportRepositoryProvider).getThread(threadId);
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});

final supportMessagesProvider = FutureProvider.family<List<SupportMessage>, int>((ref, threadId) async {
  final result = await ref.watch(supportRepositoryProvider).listMessages(threadId);
  return switch (result) {
    ApiOk(:final data) => data,
    ApiErr(:final error) => throw error,
  };
});
