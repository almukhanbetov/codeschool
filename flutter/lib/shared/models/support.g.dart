// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SupportThreadAboutImpl _$$SupportThreadAboutImplFromJson(
  Map<String, dynamic> json,
) => _$SupportThreadAboutImpl(
  studentName: json['studentName'] as String,
  courseTitle: json['courseTitle'] as String?,
  lessonTitle: json['lessonTitle'] as String?,
  assignmentName: json['assignmentName'] as String?,
);

Map<String, dynamic> _$$SupportThreadAboutImplToJson(
  _$SupportThreadAboutImpl instance,
) => <String, dynamic>{
  'studentName': instance.studentName,
  'courseTitle': instance.courseTitle,
  'lessonTitle': instance.lessonTitle,
  'assignmentName': instance.assignmentName,
};

_$SupportThreadListItemImpl _$$SupportThreadListItemImplFromJson(
  Map<String, dynamic> json,
) => _$SupportThreadListItemImpl(
  id: (json['id'] as num).toInt(),
  subject: json['subject'] as String,
  category: json['category'] as String,
  status: json['status'] as String,
  priority: json['priority'] as String,
  about: SupportThreadAbout.fromJson(json['about'] as Map<String, dynamic>),
  lastMessagePreview: json['lastMessagePreview'] as String,
  lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
  unreadCount: (json['unreadCount'] as num).toInt(),
  assignedToStaff: json['assignedToStaff'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$SupportThreadListItemImplToJson(
  _$SupportThreadListItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'subject': instance.subject,
  'category': instance.category,
  'status': instance.status,
  'priority': instance.priority,
  'about': instance.about,
  'lastMessagePreview': instance.lastMessagePreview,
  'lastMessageAt': instance.lastMessageAt.toIso8601String(),
  'unreadCount': instance.unreadCount,
  'assignedToStaff': instance.assignedToStaff,
  'createdAt': instance.createdAt.toIso8601String(),
};

_$SupportThreadDetailImpl _$$SupportThreadDetailImplFromJson(
  Map<String, dynamic> json,
) => _$SupportThreadDetailImpl(
  id: (json['id'] as num).toInt(),
  subject: json['subject'] as String,
  category: json['category'] as String,
  status: json['status'] as String,
  priority: json['priority'] as String,
  about: SupportThreadAbout.fromJson(json['about'] as Map<String, dynamic>),
  lastMessagePreview: json['lastMessagePreview'] as String,
  lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
  unreadCount: (json['unreadCount'] as num).toInt(),
  assignedToStaff: json['assignedToStaff'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isParentThread: json['isParentThread'] as bool,
);

Map<String, dynamic> _$$SupportThreadDetailImplToJson(
  _$SupportThreadDetailImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'subject': instance.subject,
  'category': instance.category,
  'status': instance.status,
  'priority': instance.priority,
  'about': instance.about,
  'lastMessagePreview': instance.lastMessagePreview,
  'lastMessageAt': instance.lastMessageAt.toIso8601String(),
  'unreadCount': instance.unreadCount,
  'assignedToStaff': instance.assignedToStaff,
  'createdAt': instance.createdAt.toIso8601String(),
  'isParentThread': instance.isParentThread,
};

_$SupportMessageImpl _$$SupportMessageImplFromJson(Map<String, dynamic> json) =>
    _$SupportMessageImpl(
      id: (json['id'] as num).toInt(),
      body: json['body'] as String,
      messageType: json['messageType'] as String,
      senderRole: json['senderRole'] as String,
      senderName: json['senderName'] as String,
      mine: json['mine'] as bool,
      isInternal: json['isInternal'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      editedAt: json['editedAt'] == null
          ? null
          : DateTime.parse(json['editedAt'] as String),
    );

Map<String, dynamic> _$$SupportMessageImplToJson(
  _$SupportMessageImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'body': instance.body,
  'messageType': instance.messageType,
  'senderRole': instance.senderRole,
  'senderName': instance.senderName,
  'mine': instance.mine,
  'isInternal': instance.isInternal,
  'createdAt': instance.createdAt.toIso8601String(),
  'editedAt': instance.editedAt?.toIso8601String(),
};

_$SupportUnreadCountImpl _$$SupportUnreadCountImplFromJson(
  Map<String, dynamic> json,
) => _$SupportUnreadCountImpl(
  threads: (json['threads'] as num).toInt(),
  messages: (json['messages'] as num).toInt(),
);

Map<String, dynamic> _$$SupportUnreadCountImplToJson(
  _$SupportUnreadCountImpl instance,
) => <String, dynamic>{
  'threads': instance.threads,
  'messages': instance.messages,
};
