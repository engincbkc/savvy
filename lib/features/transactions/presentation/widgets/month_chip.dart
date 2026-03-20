import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';

class MonthChip extends StatelessWidget {
  final String label;
  final String? year;
  final bool isSelected;
  final VoidCallback onTap;

  const MonthChip({
    super.key,
    required this.label,
    this.year,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: AppDuration.fast,
        curve: AppCurve.standard,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md + 2,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? c.brandPrimary : c.surfaceCard,
          borderRadius: AppRadius.pill,
          border: Border.all(
            color: isSelected
                ? c.brandPrimary
                : c.borderDefault.withValues(alpha: 0.3),
          ),
          boxShadow: isSelected ? AppShadow.sm : AppShadow.none,
        ),
        child: Text(
          year != null ? '$label \'${year!.substring(2)}' : label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? Colors.white : c.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
