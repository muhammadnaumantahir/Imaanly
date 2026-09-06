import 'package:flutter/material.dart';

/// Centralized visual tokens for the Imaanly product language.
///
/// Keep feature screens dependent on these tokens instead of introducing
/// one-off spacing, radii, or text sizes. The values intentionally remain
/// small and predictable so the existing Imaanly-derived UI can migrate
/// incrementally without a visual rewrite.
class ImaanlySpacing {
  ImaanlySpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

class ImaanlyRadius {
  ImaanlyRadius._();

  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double pill = 999;
}

class ImaanlyTypography {
  ImaanlyTypography._();

  static const String fontFamily = 'ImaanlySans';

  static const TextStyle display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.4,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.2,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
}
