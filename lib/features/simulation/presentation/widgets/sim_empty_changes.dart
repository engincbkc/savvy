import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';

class SimEmptyChanges extends StatelessWidget {
  final Color color;
  final VoidCallback onAdd;

  const SimEmptyChanges({super.key, required this.color, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.04),
          borderRadius: AppRadius.cardLg,
          border:
              Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.plus, color: color, size: 28),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Değişiklik Ekleyin',
                style: AppTypography.titleMedium
                    .copyWith(color: c.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              'Gelir, gider, kredi, zam veya yatırım ekleyin',
              style: AppTypography.bodySmall.copyWith(color: c.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
