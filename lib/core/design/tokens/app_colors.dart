import 'package:flutter/material.dart';
import 'color_primitives.dart';
import 'savvy_colors.dart';

/// Semantic color tokens.
///
/// For theme-aware colors (dark mode), use `AppColors.of(context).textPrimary`.
/// Static constants are kept for backward compatibility and default to light theme.
class AppColors {
  /// Returns theme-aware colors based on current brightness.
  static SavvyColors of(BuildContext context) => context.savvyColors;

  // ─── Brand ───────────────────────────────────────────────────────
  static const brandPrimary = ColorPrimitives.blue700;
  static const brandPrimaryDim = ColorPrimitives.blue800;
  static const brandAccent = ColorPrimitives.blue500;
  static const brandLight = ColorPrimitives.blue50;

  // ─── Financial Semantic ──────────────────────────────────────────
  // Gelir (Income) — Green
  static const income = ColorPrimitives.green500;
  static const incomeStrong = ColorPrimitives.green700;
  static const incomeMuted = ColorPrimitives.green400;
  static const incomeSurface = ColorPrimitives.green100;
  static const incomeSurfaceDim = ColorPrimitives.green50;

  // Gider (Expense) — Red
  static const expense = ColorPrimitives.red500;
  static const expenseStrong = ColorPrimitives.red700;
  static const expenseMuted = ColorPrimitives.red400;
  static const expenseSurface = ColorPrimitives.red100;
  static const expenseSurfaceDim = ColorPrimitives.red50;

  // Birikim (Savings) — Amber/Gold
  static const savings = ColorPrimitives.amber600;
  static const savingsStrong = ColorPrimitives.amber700;
  static const savingsMuted = ColorPrimitives.amber400;
  static const savingsSurface = ColorPrimitives.amber100;
  static const savingsSurfaceDim = ColorPrimitives.amber50;

  // ─── Status ──────────────────────────────────────────────────────
  static const success = ColorPrimitives.green500;
  static const successLight = ColorPrimitives.green50;
  static const warning = ColorPrimitives.amber500;
  static const warningLight = ColorPrimitives.amber50;
  static const error = ColorPrimitives.red500;
  static const errorLight = ColorPrimitives.red50;
  static const info = ColorPrimitives.blue500;
  static const infoLight = ColorPrimitives.blue50;

  // ─── Text ────────────────────────────────────────────────────────
  static const textPrimary = ColorPrimitives.gray900;
  static const textSecondary = ColorPrimitives.gray600;
  static const textTertiary = ColorPrimitives.gray400;
  static const textInverse = ColorPrimitives.white;
  static const textLink = ColorPrimitives.blue700;

  // ─── Surface ─────────────────────────────────────────────────────
  static const surfaceBackground = ColorPrimitives.gray50;
  static const surfaceCard = ColorPrimitives.white;
  static const surfaceElevated = ColorPrimitives.white;
  static const surfaceOverlay = ColorPrimitives.gray100;
  static const surfaceInput = ColorPrimitives.gray50;

  // ─── Border ──────────────────────────────────────────────────────
  static const borderDefault = ColorPrimitives.gray200;
  static const borderStrong = ColorPrimitives.gray300;
  static const borderFocus = ColorPrimitives.blue700;

  // ─── Dark Mode Overrides ─────────────────────────────────────────
  static const darkSurfaceBackground = ColorPrimitives.dark900;
  static const darkSurfaceCard = ColorPrimitives.dark800;
  static const darkSurfaceElevated = ColorPrimitives.dark700;
  static const darkTextPrimary = ColorPrimitives.gray50;
  static const darkTextSecondary = ColorPrimitives.gray400;
  static const darkBorder = ColorPrimitives.dark600;
}
