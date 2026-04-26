import 'package:flutter/material.dart';
import 'color_primitives.dart';

/// Theme extension that provides context-aware semantic colors.
/// Usage: `Theme.of(context).extension<SavvyColors>()!.textPrimary`
/// Or via shortcut: `context.savvyColors.textPrimary`
class SavvyColors extends ThemeExtension<SavvyColors> {
  // Brand
  final Color brandPrimary;
  final Color brandPrimaryDim;
  final Color brandAccent;
  final Color brandLight;

  // Income
  final Color income;
  final Color incomeStrong;
  final Color incomeMuted;
  final Color incomeSurface;
  final Color incomeSurfaceDim;

  // Expense
  final Color expense;
  final Color expenseStrong;
  final Color expenseMuted;
  final Color expenseSurface;
  final Color expenseSurfaceDim;

  // Savings
  final Color savings;
  final Color savingsStrong;
  final Color savingsMuted;
  final Color savingsSurface;
  final Color savingsSurfaceDim;

  // Status
  final Color success;
  final Color warning;
  final Color error;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textInverse;

  // Surface
  final Color surfaceBackground;
  final Color surfaceCard;
  final Color surfaceElevated;
  final Color surfaceOverlay;
  final Color surfaceInput;

  // Border
  final Color borderDefault;
  final Color borderStrong;
  final Color borderFocus;

  const SavvyColors({
    required this.brandPrimary,
    required this.brandPrimaryDim,
    required this.brandAccent,
    required this.brandLight,
    required this.income,
    required this.incomeStrong,
    required this.incomeMuted,
    required this.incomeSurface,
    required this.incomeSurfaceDim,
    required this.expense,
    required this.expenseStrong,
    required this.expenseMuted,
    required this.expenseSurface,
    required this.expenseSurfaceDim,
    required this.savings,
    required this.savingsStrong,
    required this.savingsMuted,
    required this.savingsSurface,
    required this.savingsSurfaceDim,
    required this.success,
    required this.warning,
    required this.error,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textInverse,
    required this.surfaceBackground,
    required this.surfaceCard,
    required this.surfaceElevated,
    required this.surfaceOverlay,
    required this.surfaceInput,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderFocus,
  });

  // ─── Light palette ────────────────────────────────────────────────────
  static const light = SavvyColors(
    brandPrimary: ColorPrimitives.blue700,
    brandPrimaryDim: ColorPrimitives.blue800,
    brandAccent: ColorPrimitives.blue500,
    brandLight: ColorPrimitives.blue50,
    income: ColorPrimitives.green500,
    incomeStrong: ColorPrimitives.green700,
    incomeMuted: ColorPrimitives.green400,
    incomeSurface: ColorPrimitives.green100,
    incomeSurfaceDim: ColorPrimitives.green50,
    expense: ColorPrimitives.red500,
    expenseStrong: ColorPrimitives.red700,
    expenseMuted: ColorPrimitives.red400,
    expenseSurface: ColorPrimitives.red100,
    expenseSurfaceDim: ColorPrimitives.red50,
    savings: ColorPrimitives.amber600,
    savingsStrong: ColorPrimitives.amber700,
    savingsMuted: ColorPrimitives.amber400,
    savingsSurface: ColorPrimitives.amber100,
    savingsSurfaceDim: ColorPrimitives.amber50,
    success: ColorPrimitives.green500,
    warning: ColorPrimitives.amber500,
    error: ColorPrimitives.red500,
    textPrimary: ColorPrimitives.gray900,
    textSecondary: ColorPrimitives.gray600,
    textTertiary: ColorPrimitives.gray400,
    textInverse: ColorPrimitives.white,
    surfaceBackground: ColorPrimitives.gray50,
    surfaceCard: ColorPrimitives.white,
    surfaceElevated: ColorPrimitives.white,
    surfaceOverlay: ColorPrimitives.gray100,
    surfaceInput: ColorPrimitives.gray50,
    borderDefault: ColorPrimitives.gray200,
    borderStrong: ColorPrimitives.gray300,
    borderFocus: ColorPrimitives.blue700,
  );

  // ─── Dark palette ─────────────────────────────────────────────────────
  static const dark = SavvyColors(
    brandPrimary: ColorPrimitives.blue500,
    brandPrimaryDim: ColorPrimitives.blue600,
    brandAccent: ColorPrimitives.blue400,
    brandLight: Color(0xFF172554),
    income: ColorPrimitives.green400,
    incomeStrong: ColorPrimitives.green200,
    incomeMuted: ColorPrimitives.green500,
    incomeSurface: Color(0xFF052E16),
    incomeSurfaceDim: Color(0xFF1F2937),
    expense: ColorPrimitives.red400,
    expenseStrong: Color(0xFFFCA5A5),
    expenseMuted: ColorPrimitives.red500,
    expenseSurface: Color(0xFF450A0A),
    expenseSurfaceDim: Color(0xFF1F2937),
    savings: ColorPrimitives.amber400,
    savingsStrong: Color(0xFFFCD34D),
    savingsMuted: ColorPrimitives.amber500,
    savingsSurface: Color(0xFF451A03),
    savingsSurfaceDim: Color(0xFF1F2937),
    success: ColorPrimitives.green400,
    warning: ColorPrimitives.amber400,
    error: ColorPrimitives.red400,
    textPrimary: ColorPrimitives.gray50,
    textSecondary: ColorPrimitives.gray400,
    textTertiary: ColorPrimitives.gray500,
    textInverse: ColorPrimitives.gray900,
    surfaceBackground: ColorPrimitives.dark900,
    surfaceCard: ColorPrimitives.dark800,
    surfaceElevated: ColorPrimitives.dark700,
    surfaceOverlay: ColorPrimitives.dark700,
    surfaceInput: ColorPrimitives.dark700,
    borderDefault: ColorPrimitives.dark600,
    borderStrong: ColorPrimitives.dark500,
    borderFocus: ColorPrimitives.blue500,
  );

  @override
  SavvyColors copyWith({Color? brandPrimary, Color? textPrimary}) => this;

  @override
  SavvyColors lerp(SavvyColors? other, double t) {
    if (other == null) return this;
    return SavvyColors(
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandPrimaryDim: Color.lerp(brandPrimaryDim, other.brandPrimaryDim, t)!,
      brandAccent: Color.lerp(brandAccent, other.brandAccent, t)!,
      brandLight: Color.lerp(brandLight, other.brandLight, t)!,
      income: Color.lerp(income, other.income, t)!,
      incomeStrong: Color.lerp(incomeStrong, other.incomeStrong, t)!,
      incomeMuted: Color.lerp(incomeMuted, other.incomeMuted, t)!,
      incomeSurface: Color.lerp(incomeSurface, other.incomeSurface, t)!,
      incomeSurfaceDim: Color.lerp(incomeSurfaceDim, other.incomeSurfaceDim, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      expenseStrong: Color.lerp(expenseStrong, other.expenseStrong, t)!,
      expenseMuted: Color.lerp(expenseMuted, other.expenseMuted, t)!,
      expenseSurface: Color.lerp(expenseSurface, other.expenseSurface, t)!,
      expenseSurfaceDim: Color.lerp(expenseSurfaceDim, other.expenseSurfaceDim, t)!,
      savings: Color.lerp(savings, other.savings, t)!,
      savingsStrong: Color.lerp(savingsStrong, other.savingsStrong, t)!,
      savingsMuted: Color.lerp(savingsMuted, other.savingsMuted, t)!,
      savingsSurface: Color.lerp(savingsSurface, other.savingsSurface, t)!,
      savingsSurfaceDim: Color.lerp(savingsSurfaceDim, other.savingsSurfaceDim, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      surfaceBackground: Color.lerp(surfaceBackground, other.surfaceBackground, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceOverlay: Color.lerp(surfaceOverlay, other.surfaceOverlay, t)!,
      surfaceInput: Color.lerp(surfaceInput, other.surfaceInput, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
    );
  }
}

/// Shortcut to access SavvyColors from BuildContext.
extension SavvyColorsExtension on BuildContext {
  SavvyColors get savvyColors =>
      Theme.of(this).extension<SavvyColors>() ?? SavvyColors.light;
}
