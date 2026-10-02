import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

/// Single source of truth for the app's Latin typeface (Poppins, bundled in
/// `assets/fonts/App`). Arabic glyphs fall back to Noto Sans / Cairo.
///
/// Use [AppFonts.body] anywhere a `TextStyle` with the app font is needed.
class AppFonts {
  AppFonts._();

  static const String family = 'Poppins';
  static const List<String> fallback = ['NotoSans', 'Cairo-Regular'];

  static TextStyle body({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final style = TextStyle(
      fontFamily: family,
      fontFamilyFallback: fallback,
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
    return textStyle == null ? style : textStyle.merge(style);
  }

  /// For countdowns and numbers: same typeface with fixed-width digits.
  static TextStyle mono({
    TextStyle? textStyle,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    List<Shadow>? shadows,
  }) {
    return body(
      textStyle: textStyle,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      shadows: shadows,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}
