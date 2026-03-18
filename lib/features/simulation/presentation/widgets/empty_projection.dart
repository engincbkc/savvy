import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';

class EmptyProjection extends StatelessWidget {
  const EmptyProjection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.of(context).surfaceCard,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.of(context).borderDefault),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_graph_rounded,
            size: 48,
            color: AppColors.of(context).textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Henüz projeksiyon yok',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.of(context).textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Gelir veya gider eklerken "Periyodik" seçeneğini açarak gelecek ay tahminlerinizi görün.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.of(context).textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
