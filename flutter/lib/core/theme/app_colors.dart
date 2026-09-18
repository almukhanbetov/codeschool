import 'package:flutter/material.dart';

/// Colors lifted directly from the web frontend's design tokens
/// (`frontend/app/globals.css` `:root` / `:root[data-theme="light"]`) so the
/// mobile app is visually consistent with codeschool.kz, not a re-imagined
/// palette.
class AppColors {
  const AppColors._();

  // --- dark (default) ---
  static const darkBackground = Color(0xFF07080D);
  static const darkSurface = Color(0xFF0E1017);
  static const darkSurface2 = Color(0xFF151824);
  static const darkSurface3 = Color(0xFF1B1F2E);
  static const darkTextPrimary = Color(0xFFF3F4F8);
  static const darkTextSecondary = Color(0xFFA8ADC0);
  static const darkTextTertiary = Color(0xFF6C7286);
  static const darkBorder = Color(0x17FFFFFF);

  // --- light ---
  static const lightBackground = Color(0xFFF7F8FB);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurface2 = Color(0xFFF1F2F8);
  static const lightSurface3 = Color(0xFFE9EBF3);
  static const lightTextPrimary = Color(0xFF12131A);
  static const lightTextSecondary = Color(0xFF4B4F5F);
  static const lightTextTertiary = Color(0xFF7B7F92);
  static const lightBorder = Color(0x190F111A);

  // --- brand accents (same hex the web uses per theme) ---
  static const accentDark = Color(0xFF6D5EF8);
  static const accent2Dark = Color(0xFF22D3EE);
  static const accentLight = Color(0xFF5B4BF0);
  static const accent2Light = Color(0xFF0891B2);

  static const successDark = Color(0xFF34D399);
  static const dangerDark = Color(0xFFF97066);
  static const successLight = Color(0xFF10966A);
  static const dangerLight = Color(0xFFD84F43);

  /// `--accent-grad` — the signature blue→violet→cyan brand gradient, used
  /// on primary CTAs, headers and progress rings.
  static const gradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6D5EF8), Color(0xFF4F8CFF), Color(0xFF22D3EE)],
  );
  static const gradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B4BF0), Color(0xFF3D7BF0), Color(0xFF0891B2)],
  );
}
