import 'package:flutter/material.dart';

/// Imaanly color system — deep emerald and gold, inspired by modern prayer apps.
///
/// Kept in one place so feature screens can migrate away from legacy
/// Imaanly styling without changing the underlying worship architecture.
class AppColors {
  AppColors._();

  // ── LIGHT MODE ───────────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF3F8F5);
  static const Color lightBackgroundSecondary = Color(0xFFE8F1ED);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFEAF2EE);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFF7FBF9);
  static const Color lightPrimary = Color(0xFF0F7A5C);
  static const Color lightPrimaryHover = Color(0xFF0B5F47);
  static const Color lightPrimaryLight = Color(0xFFDDF0E8);
  static const Color lightPrimaryContainer = Color(0xFFBFE5D4);
  static const Color lightSecondary = Color(0xFFB8892B);
  static const Color lightSecondaryContainer = Color(0xFFF8EBCB);
  static const Color lightAyahHighlight = Color(0xFFFFF1CC);
  static const Color lightAudioPlayerBg = Color(0xFFE8F4EE);
  static const Color lightTextMain = Color(0xFF0E1F1A);
  static const Color lightTextSecondary = Color(0xFF3C524A);
  static const Color lightTextMuted = Color(0xFF6B7F77);
  static const Color lightBorder = Color(0xFFD3E2DA);
  static const Color lightBorderSubtle = Color(0xFFE6EFEA);
  static const Color lightOutlineVariant = Color(0xFFDCE9E2);

  // ── DARK MODE ────────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF071E18);
  static const Color darkBackgroundSecondary = Color(0xFF05150F);
  static const Color darkSurface = Color(0xFF0E2E25);
  static const Color darkSurfaceSecondary = Color(0xFF14392E);
  static const Color darkCard = Color(0xFF11332A);
  static const Color darkElevated = Color(0xFF174035);
  static const Color darkPrimary = Color(0xFF34C792);
  static const Color darkPrimaryHover = Color(0xFF2BAE7F);
  static const Color darkPrimaryLight = Color(0xFF12392D);
  static const Color darkPrimaryContainer = Color(0xFF1B5A45);
  static const Color darkSecondary = Color(0xFFE2BC6B);
  static const Color darkSecondaryContainer = Color(0xFF3A2F14);
  static const Color darkAyahHighlight = Color(0xFF1F4A3A);
  static const Color darkAudioPlayerBg = Color(0xFF0E2E25);
  static const Color darkTextMain = Color(0xFFF2F8F5);
  static const Color darkTextSecondary = Color(0xFFBFD3CA);
  static const Color darkTextMuted = Color(0xFF86A094);
  static const Color darkBorder = Color(0xFF2F5A4A);
  static const Color darkBorderSubtle = Color(0xFF153629);
  static const Color darkOutlineVariant = Color(0xFF1F4538);

  static const Color error = Color(0xFFC0392B);
  static const Color errorDark = Color(0xFFEF6B5B);
  static const Color success = Color(0xFF168A5A);
  static const Color successDark = Color(0xFF34C792);
  static const Color warning = Color(0xFFC99A18);
  static const Color warningDark = Color(0xFFE2BC6B);

  // ── BRAND GRADIENTS (hero cards, headers) ─────────────────────────────────
  static const Color gradientTop = Color(0xFF0F7A5C);
  static const Color gradientBottom = Color(0xFF063D2E);
  static const Color gradientTopDark = Color(0xFF14604A);
  static const Color gradientBottomDark = Color(0xFF082B22);
  static const Color gold = Color(0xFFE2BC6B);
  static const Color goldDeep = Color(0xFFC9A24B);

  static LinearGradient heroGradient(bool isDark) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [gradientTopDark, gradientBottomDark]
            : const [gradientTop, gradientBottom],
      );
}

/// Imaanly-branded alias for the shared palette.
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
