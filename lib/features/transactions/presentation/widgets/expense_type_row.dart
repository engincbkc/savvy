import 'package:flutter/material.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';

class ExpenseTypeRow extends StatelessWidget {
  final Map<ExpenseType, double> byType;
  final double total;

  const ExpenseTypeRow({super.key, required this.byType, required this.total});

  @override
  Widget build(BuildContext context) {
    if (byType.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: byType.entries.map((entry) {
        final pct = total > 0 ? (entry.value / total * 100) : 0.0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.of(context).surfaceCard,
            borderRadius: AppRadius.pill,
            border: Border.all(
                color: AppColors.of(context).borderDefault.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(entry.key.label,
                  style: AppTypography.caption.copyWith(
                      color: AppColors.of(context).textSecondary,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              Text('%${pct.toStringAsFixed(0)}',
                  style: AppTypography.caption.copyWith(
                      color: AppColors.of(context).expense, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
