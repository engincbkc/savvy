import 'package:flutter/material.dart';
import 'tokens/app_typography.dart';
import 'tokens/app_spacing.dart';
import 'tokens/app_radius.dart';
import 'tokens/savvy_colors.dart';

class AppTheme {
  static ThemeData light() {
    const c = SavvyColors.light;

    final cs = ColorScheme.fromSeed(
      seedColor: c.brandPrimary,
      brightness: Brightness.light,
    ).copyWith(
      primary: c.brandPrimary,
      primaryContainer: c.brandLight,
      surface: c.surfaceBackground,
      surfaceContainerLow: c.surfaceCard,
      error: c.error,
      onPrimary: c.textInverse,
      onSurface: c.textPrimary,
      outline: c.borderDefault,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: c.surfaceBackground,
      extensions: const [SavvyColors.light],
      cardTheme: CardThemeData(
        elevation: 0,
        color: c.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: c.surfaceBackground,
        foregroundColor: c.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: c.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: c.surfaceCard,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: c.brandPrimary,
        unselectedItemColor: c.textTertiary,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceInput,
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: c.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: c.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: c.borderFocus, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: c.textTertiary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.brandPrimary,
          foregroundColor: c.textInverse,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
          textStyle: AppTypography.labelLarge,
          minimumSize: const Size(0, AppSpacing.minTouchTarget),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: c.borderDefault,
        thickness: 1,
        space: 0,
      ),
    );
  }

  static ThemeData dark() {
    const c = SavvyColors.dark;

    final cs = ColorScheme.fromSeed(
      seedColor: c.brandPrimary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: c.brandPrimary,
      primaryContainer: c.brandLight,
      surface: c.surfaceBackground,
      surfaceContainerLow: c.surfaceCard,
      error: c.error,
      onPrimary: c.textInverse,
      onSurface: c.textPrimary,
      outline: c.borderDefault,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: c.surfaceBackground,
      extensions: const [SavvyColors.dark],
      cardTheme: CardThemeData(
        elevation: 0,
        color: c.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: c.surfaceBackground,
        foregroundColor: c.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: c.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: c.surfaceCard,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: c.brandPrimary,
        unselectedItemColor: c.textTertiary,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceInput,
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: c.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: c.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: c.borderFocus, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: c.textTertiary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.brandPrimary,
          foregroundColor: c.textInverse,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
          textStyle: AppTypography.labelLarge,
          minimumSize: const Size(0, AppSpacing.minTouchTarget),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: c.borderDefault,
        thickness: 1,
        space: 0,
      ),
    );
  }
}
