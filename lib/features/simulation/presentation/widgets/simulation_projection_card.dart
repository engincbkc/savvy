import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';

class SimulationProjectionCard extends StatelessWidget {
  final MonthSummary projection;

  const SimulationProjectionCard({super.key, required this.projection});

  @override
  Widget build(BuildContext context) {
    final label = MonthLabels.full(projection.yearMonth);
    final isPositive = projection.netBalance >= 0;

    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.of(context).surfaceCard,
        borderRadius: AppRadius.card,
        boxShadow: AppShadow.sm,
        border: Border.all(
          color: AppColors.of(context).borderDefault.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.of(context).income : AppColors.of(context).expense)
                      .withValues(alpha: 0.1),
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(
                  isPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: isPositive ? AppColors.of(context).income : AppColors.of(context).expense,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.of(context).textPrimary,
                      ),
                    ),
                    Text(
                      'Tahmini',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.of(context).textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Net',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.of(context).textTertiary,
                    ),
                  ),
                  Text(
                    '${isPositive ? '+' : ''}${CurrencyFormatter.formatNoDecimal(projection.netBalance)}',
                    style: AppTypography.numericSmall.copyWith(
                      color:
                          isPositive ? AppColors.of(context).income : AppColors.of(context).expense,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Row(
            children: [
              _MiniStat(
                label: 'Gelir',
                amount: projection.totalIncome,
                color: AppColors.of(context).income,
                prefix: '+',
              ),
              _MiniStat(
                label: 'Gider',
                amount: projection.totalExpense,
                color: AppColors.of(context).expense,
                prefix: '-',
              ),
              _MiniStat(
                label: 'Kümülatif',
                amount: projection.netWithCarryOver,
                color: projection.netWithCarryOver >= 0
                    ? AppColors.of(context).brandPrimary
                    : AppColors.of(context).expense,
                prefix: '',
              ),
            ],
          ),
          if (projection.totalIncome == 0 && projection.totalExpense == 0)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: AppColors.of(context).warning),
                  const SizedBox(width: 4),
                  Text(
                    'Bu ay için periyodik kayıt yok',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.of(context).warning,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final String prefix;

  const _MiniStat({
    required this.label,
    required this.amount,
    required this.color,
    required this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.of(context).textTertiary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$prefix${CurrencyFormatter.formatNoDecimal(amount)}',
            style: AppTypography.numericSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
