import 'package:freezed_annotation/freezed_annotation.dart';

part 'support.freezed.dart';
part 'support.g.dart';

/// Real category values only — migration 00027 CHECK constraint
/// (`support_threads_category_allowed`), nothing invented.
const supportThreadCategories = [
  'general',
  'course',
  'lesson',
  'assignment',
  'quiz',
  'code_runner',
  'progress',
  'certificate',
  'account',
  'parent_question',
  'technical',
];

/// Mirrors backend/internal/support/dto.go `ThreadAbout`.
@freezed
abstract class SupportThreadAbout with _$SupportThreadAbout {
  const factory SupportThreadAbout({
    required String studentName,
    String? courseTitle,
    String? lessonTitle,
    String? assignmentName,
  }) = _SupportThreadAbout;
  factory SupportThreadAbout.fromJson(Map<String, dynamic> json) => _$SupportThreadAboutFromJson(json);
}

/// Mirrors `ThreadListItem` (GET /support/threads) — status is 'open' |
/// 'waiting_staff' | 'waiting_user' | 'closed'; priority 'normal' | 'high'
/// (migration 00027 CHECK constraints).
@freezed
abstract class SupportThreadListItem with _$SupportThreadListItem {
  const factory SupportThreadListItem({
    required int id,
    required String subject,
    required String category,
    required String status,
    required String priority,
    required SupportThreadAbout about,
    required String lastMessagePreview,
    required DateTime lastMessageAt,
    required int unreadCount,
    required bool assignedToStaff,
    required DateTime createdAt,
  }) = _SupportThreadListItem;
  factory SupportThreadListItem.fromJson(Map<String, dynamic> json) => _$SupportThreadListItemFromJson(json);
}

/// Mirrors `ThreadDetail` (GET /support/threads/:id) — a Go-embedded
/// `ThreadListItem` flattened into the same JSON level.
@freezed
abstract class SupportThreadDetail with _$SupportThreadDetail {
  const factory SupportThreadDetail({
    required int id,
    required String subject,
    required String category,
    required String status,
    required String priority,
    required SupportThreadAbout about,
    required String lastMessagePreview,
    required DateTime lastMessageAt,
    required int unreadCount,
    required bool assignedToStaff,
    required DateTime createdAt,
    required bool isParentThread,
  }) = _SupportThreadDetail;
  factory SupportThreadDetail.fromJson(Map<String, dynamic> json) => _$SupportThreadDetailFromJson(json);
}

/// Mirrors `MessageDTO` — `senderRole` is 'student' | 'parent' | 'teacher' |
/// 'admin'; `messageType` 'text' | 'system' | 'staff_note_visible' |
/// 'internal_note' | 'learning_context' (migration 00027). Internal notes
/// are already stripped server-side for a student/parent response.
@freezed
abstract class SupportMessage with _$SupportMessage {
  const factory SupportMessage({
    required int id,
    required String body,
    required String messageType,
    required String senderRole,
    required String senderName,
    required bool mine,
    required bool isInternal,
    required DateTime createdAt,
    DateTime? editedAt,
  }) = _SupportMessage;
  factory SupportMessage.fromJson(Map<String, dynamic> json) => _$SupportMessageFromJson(json);
}

/// Mirrors `UnreadCountDTO` (GET /support/unread-count) — the real
/// "notifications" signal this project actually has (no separate
/// notifications feed/list endpoint exists anywhere in the backend).
@freezed
abstract class SupportUnreadCount with _$SupportUnreadCount {
  const factory SupportUnreadCount({required int threads, required int messages}) = _SupportUnreadCount;
  factory SupportUnreadCount.fromJson(Map<String, dynamic> json) => _$SupportUnreadCountFromJson(json);
}
