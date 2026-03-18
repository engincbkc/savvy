import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';

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
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.of(context).brandPrimary : AppColors.of(context).surfaceOverlay,
          borderRadius: AppRadius.pill,
          border: Border.all(
            color: isSelected
                ? AppColors.of(context).brandPrimary
                : AppColors.of(context).borderDefault.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              year != null ? '$label \'${year!.substring(2)}' : label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.of(context).textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
