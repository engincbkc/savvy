import 'package:flutter/material.dart';
import 'tokens/app_colors.dart';
import 'tokens/app_typography.dart';
import 'tokens/app_spacing.dart';
import 'tokens/app_radius.dart';

class AppTheme {
  static ThemeData light() {
    final cs = ColorScheme.fromSeed(
      seedColor: AppColors.brandPrimary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.brandPrimary,
      primaryContainer: AppColors.brandLight,
      surface: AppColors.surfaceBackground,
      surfaceContainerLow: AppColors.surfaceCard,
      error: AppColors.error,
      onPrimary: AppColors.textInverse,
      onSurface: AppColors.textPrimary,
      outline: AppColors.borderDefault,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.surfaceBackground,
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: AppColors.surfaceCard,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: AppColors.surfaceCard,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.brandPrimary,
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceInput,
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide:
              const BorderSide(color: AppColors.borderFocus, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandPrimary,
          foregroundColor: AppColors.textInverse,
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
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDefault,
        thickness: 1,
        space: 0,
      ),
    );
  }

  static ThemeData dark() {
    return light().copyWith(
      scaffoldBackgroundColor: AppColors.darkSurfaceBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandPrimary,
        brightness: Brightness.dark,
      ).copyWith(
        surface: AppColors.darkSurfaceBackground,
        surfaceContainerLow: AppColors.darkSurfaceCard,
        outline: AppColors.darkBorder,
        onSurface: AppColors.darkTextPrimary,
      ),
    );
  }
}
