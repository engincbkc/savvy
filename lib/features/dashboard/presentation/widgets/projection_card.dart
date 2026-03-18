import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';

class ProjectionCard extends StatelessWidget {
  final MonthSummary summary;
  final String label;

  const ProjectionCard({
    super.key,
    required this.summary,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = summary.netBalance >= 0;

    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.of(context).surfaceCard,
        borderRadius: AppRadius.card,
        boxShadow: AppShadow.sm,
        border: Border.all(
          color: AppColors.of(context).borderDefault.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.of(context).brandPrimary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(
                  LucideIcons.calendar,
                  color: AppColors.of(context).brandPrimary,
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
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.of(context).textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.of(context).brandPrimary.withValues(alpha: 0.1),
                            borderRadius: AppRadius.pill,
                          ),
                          child: Text(
                            'Tahmini',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.of(context).brandPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Saglık: ${summary.healthScore}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.of(context).textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Net badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppColors.of(context).incomeSurface
                      : AppColors.of(context).expenseSurface,
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  '${isPositive ? '+' : ''}${CurrencyFormatter.formatNoDecimal(summary.netBalance)}',
                  style: AppTypography.numericSmall.copyWith(
                    color: isPositive ? AppColors.of(context).income : AppColors.of(context).expense,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.base),

          // Gelir / Gider row
          Row(
            children: [
              Expanded(
                child: ProjStat(
                  icon: LucideIcons.trendingUp,
                  label: 'Tahmini Gelir',
                  amount: summary.totalIncome,
                  color: AppColors.of(context).income,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ProjStat(
                  icon: LucideIcons.trendingDown,
                  label: 'Tahmini Gider',
                  amount: summary.totalExpense,
                  color: AppColors.of(context).expense,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Cumulative row
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: summary.netWithCarryOver >= 0
                  ? AppColors.of(context).incomeSurfaceDim
                  : AppColors.of(context).expenseSurfaceDim,
              borderRadius: AppRadius.chip,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.wallet,
                      size: 16,
                      color: summary.netWithCarryOver >= 0
                          ? AppColors.of(context).income
                          : AppColors.of(context).expense,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Kumulatif Bakiye',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.of(context).textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  CurrencyFormatter.formatNoDecimal(summary.netWithCarryOver),
                  style: AppTypography.numericSmall.copyWith(
                    color: summary.netWithCarryOver >= 0
                        ? AppColors.of(context).income
                        : AppColors.of(context).expense,
                    fontWeight: FontWeight.w700,
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

class ProjStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;

  const ProjStat({
    super.key,
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: AppRadius.chip,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.formatNoDecimal(amount),
              style: AppTypography.numericSmall.copyWith(
                color: AppColors.of(context).textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
