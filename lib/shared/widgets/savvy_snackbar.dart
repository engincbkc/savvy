import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';

/// Unified snackbar API. All transient feedback in the app should funnel through
/// this so colors, radii, and behaviors stay consistent.
abstract class SavvySnackbar {
  static void success(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 2)}) {
    _show(
      context,
      message: message,
      icon: LucideIcons.check,
      bg: AppColors.of(context).income,
      duration: duration,
    );
  }

  static void error(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 3)}) {
    _show(
      context,
      message: message,
      icon: LucideIcons.alertCircle,
      bg: AppColors.of(context).expense,
      duration: duration,
    );
  }

  static void info(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 2)}) {
    _show(
      context,
      message: message,
      icon: LucideIcons.info,
      bg: AppColors.of(context).brandPrimary,
      duration: duration,
    );
  }

  static void warning(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 3)}) {
    _show(
      context,
      message: message,
      icon: LucideIcons.alertTriangle,
      bg: AppColors.of(context).savings,
      duration: duration,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color bg,
    required Duration duration,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
        margin: const EdgeInsets.all(AppSpacing.base),
        duration: duration,
        elevation: 4,
      ),
    );
  }
}
