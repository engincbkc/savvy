import 'package:flutter/painting.dart';

/// Typography tokens — all text styles in the app.
abstract class AppTypography {
  static const String _fontFamily = 'Inter';

  // ─── Display — Numeric (Money amounts) ────────────────────────────
  static const numericHero = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 44,
    fontWeight: FontWeight.w800,
    letterSpacing: -2.0,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const numericLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.1,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const numericMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const numericSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // ─── Headline ────────────────────────────────────────────────────
  static const headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.2,
  );

  static const headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.25,
  );

  static const headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  // ─── Title ───────────────────────────────────────────────────────
  static const titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
  );

  static const titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    height: 1.4,
  );

  static const titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // ─── Body ────────────────────────────────────────────────────────
  static const bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.55,
  );

  static const bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
  );

  static const bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
  );

  // ─── Label ───────────────────────────────────────────────────────
  static const labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static const labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
  );

  // ─── Caption ─────────────────────────────────────────────────────
  static const caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    height: 1.4,
  );
}
