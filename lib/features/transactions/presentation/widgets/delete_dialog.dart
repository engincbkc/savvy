import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';

void showDeleteConfirmation({
  required BuildContext context,
  required String type,
  required VoidCallback onConfirm,
}) {
  showModalBottomSheet(useRootNavigator: true, 
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final c = AppColors.of(ctx);
      return Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: c.surfaceCard,
          borderRadius: AppRadius.card,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: c.expense.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(AppIcons.delete, color: c.expense, size: 24),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              '$type Sil',
              style: AppTypography.headlineSmall.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: AppSpacing.screenH,
              child: Text(
                'Bu ${type.toLowerCase()}i silmek istediğine emin misin?\nBu işlem geri alınamaz.',
                style: AppTypography.bodyMedium.copyWith(color: c.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: AppSpacing.screenH,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: c.surfaceOverlay,
                          borderRadius: AppRadius.input,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Vazgeç',
                          style: AppTypography.labelMedium.copyWith(
                            color: c.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        HapticFeedback.mediumImpact();
                        onConfirm();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: c.expense,
                          borderRadius: AppRadius.input,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Evet, Sil',
                          style: AppTypography.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + AppSpacing.lg),
          ],
        ),
      );
    },
  );
}
