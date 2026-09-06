import 'package:flutter/material.dart';

/// Imaanly color system — calm, warm, and focused on readability.
///
/// Kept in one place so feature screens can migrate away from legacy
/// Al-Furkan styling without changing the underlying worship architecture.
class AppColors {
  AppColors._();

  // ── LIGHT MODE ───────────────────────────────────────────────────────────

  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightBackgroundSecondary = Color(0xFFF0EAE2);
  static const Color lightSurface = Color(0xFFE3D5CA);
  static const Color lightSurfaceSecondary = Color(0xFFD6CCC2);
  static const Color lightCard = Color(0xFFF5EBE0);
  static const Color lightElevated = Color(0xFFE3D5CA);

  static const Color lightPrimary = Color(0xFF73877B);
  static const Color lightPrimaryHover = Color(0xFF5C6E65);
  static const Color lightPrimaryLight = Color(0xFFD4E2D9);
  static const Color lightPrimaryContainer = Color(0xFFB8CFC0);
  static const Color lightSecondary = Color(0xFF8B7355);
  static const Color lightSecondaryContainer = Color(0xFFF0E6D6);

  static const Color lightAyahHighlight = Color(0xFFEADBC3);
  static const Color lightAudioPlayerBg = Color(0xFFEDE4D4);

  static const Color lightTextMain = Color(0xFF212529);
  static const Color lightTextSecondary = Color(0xFF495057);
  static const Color lightTextMuted = Color(0xFF6C757D);

  static const Color lightBorder = Color(0xFFC8B9AD);
  static const Color lightBorderSubtle = Color(0xFFEDE8E2);
  static const Color lightOutlineVariant = Color(0xFFE3D5CA);

  // ── DARK MODE ────────────────────────────────────────────────────────────

  static const Color darkBackground = Color(0xFF212529);
  static const Color darkBackgroundSecondary = Color(0xFF1A1D21);
  static const Color darkSurface = Color(0xFF343A40);
  static const Color darkSurfaceSecondary = Color(0xFF495057);
  static const Color darkCard = Color(0xFF495057);
  static const Color darkElevated = Color(0xFF545C64);

  static const Color darkPrimary = Color(0xFF73877B);
  static const Color darkPrimaryHover = Color(0xFF839788);
  static const Color darkPrimaryLight = Color(0xFF3D4A42);
  static const Color darkPrimaryContainer = Color(0xFF4A5B52);
  static const Color darkSecondary = Color(0xFFB8A080);
  static const Color darkSecondaryContainer = Color(0xFF3D3529);

  static const Color darkAyahHighlight = Color(0xFF4A5B52);
  static const Color darkAudioPlayerBg = Color(0xFF343A40);

  static const Color darkTextMain = Color(0xFFF8F9FA);
  static const Color darkTextSecondary = Color(0xFFCED4DA);
  static const Color darkTextMuted = Color(0xFF6C757D);

  static const Color darkBorder = Color(0xFFADB5BD);
  static const Color darkBorderSubtle = Color(0xFF2E3338);
  static const Color darkOutlineVariant = Color(0xFF545C64);

  // ── SEMANTIC ─────────────────────────────────────────────────────────────

  static const Color error = Color(0xFF922B21);
  static const Color errorDark = Color(0xFFC0392B);
  static const Color success = Color(0xFF1E8449);
  static const Color successDark = Color(0xFF27AE60);
  static const Color warning = Color(0xFFB7950B);
  static const Color warningDark = Color(0xFFD4AC0D);
}

/// Imaanly-branded alias for the shared palette.
///
/// AppColors remains available during the migration so existing features do
/// not need to be rewritten in one risky change.
class ImaanlyColors {
  ImaanlyColors._();

  static const lightBackground = AppColors.lightBackground;
  static const lightSurface = AppColors.lightSurface;
  static const lightCard = AppColors.lightCard;
  static const lightPrimary = AppColors.lightPrimary;
  static const lightPrimaryContainer = AppColors.lightPrimaryContainer;
  static const lightSecondary = AppColors.lightSecondary;
  static const lightTextMain = AppColors.lightTextMain;
  static const lightTextSecondary = AppColors.lightTextSecondary;
  static const lightTextMuted = AppColors.lightTextMuted;
  static const lightBorder = AppColors.lightBorder;

  static const darkBackground = AppColors.darkBackground;
  static const darkSurface = AppColors.darkSurface;
  static const darkCard = AppColors.darkCard;
  static const darkPrimary = AppColors.darkPrimary;
  static const darkPrimaryContainer = AppColors.darkPrimaryContainer;
  static const darkSecondary = AppColors.darkSecondary;
  static const darkTextMain = AppColors.darkTextMain;
  static const darkTextSecondary = AppColors.darkTextSecondary;
  static const darkTextMuted = AppColors.darkTextMuted;
  static const darkBorder = AppColors.darkBorder;

  static const success = AppColors.success;
  static const warning = AppColors.warning;
  static const error = AppColors.error;
}
