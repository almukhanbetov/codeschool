import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Icon shown per `lessonType` — mirrors the lesson-type set already
/// established by the Year 1 seed content (text/video/quiz/code/project).
/// Shared by the module and lesson-details screens.
IconData lessonTypeIcon(String lessonType) => switch (lessonType) {
      'video' => LucideIcons.playCircle,
      'quiz' => LucideIcons.listChecks,
      'code' => LucideIcons.code,
      'project' => LucideIcons.rocket,
      _ => LucideIcons.fileText,
    };
