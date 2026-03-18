import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';

class SavingsToggle extends StatelessWidget {
  final bool isEnabled;
  final double totalSavings;
  final VoidCallback onToggle;

  const SavingsToggle({
    super.key,
    required this.isEnabled,
    required this.totalSavings,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: AppDuration.normal,
        curve: AppCurve.standard,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isEnabled
              ? AppColors.of(context).savings.withValues(alpha: 0.08)
              : AppColors.of(context).surfaceCard,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: isEnabled
                ? AppColors.of(context).savings.withValues(alpha: 0.4)
                : AppColors.of(context).borderDefault,
          ),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.piggyBank, size: 20, color: AppColors.of(context).savings),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Birikimi Dahil Et',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.of(context).textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${CurrencyFormatter.formatNoDecimal(totalSavings)} gelir olarak ekle',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.of(context).textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            // Custom toggle
            AnimatedContainer(
              duration: AppDuration.fast,
              width: 44,
              height: 26,
              decoration: BoxDecoration(
                color: isEnabled ? AppColors.of(context).savings : AppColors.of(context).surfaceOverlay,
                borderRadius: AppRadius.pill,
              ),
              child: AnimatedAlign(
                duration: AppDuration.fast,
                curve: AppCurve.standard,
                alignment:
                    isEnabled ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
