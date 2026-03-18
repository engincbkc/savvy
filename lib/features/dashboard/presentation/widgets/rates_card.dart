import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/financial_calculator.dart';

class RatesCard extends StatelessWidget {
  final double savingsRate;
  final double expenseRate;
  final int healthScore;

  const RatesCard({
    super.key,
    required this.savingsRate,
    required this.expenseRate,
    required this.healthScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.card,
        boxShadow: AppShadow.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Finansal Oranlar',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // Savings rate
          ProgressRow(
            label: 'Tasarruf Oranı',
            value: savingsRate,
            color: AppColors.savings,
            target: 0.20,
            hint: 'Hedef: ≥%20',
          ),

          const SizedBox(height: AppSpacing.lg),

          // Expense rate
          ProgressRow(
            label: 'Harcama Oranı',
            value: expenseRate.clamp(0.0, 1.0),
            color: expenseRate > 0.80
                ? AppColors.expense
                : expenseRate > 0.60
                    ? AppColors.warning
                    : AppColors.income,
            target: 0.70,
            hint: 'Hedef: ≤%70',
          ),

          const SizedBox(height: AppSpacing.lg),

          // Health score bar
          HealthScoreBar(score: healthScore),
        ],
      ),
    );
  }
}

class ProgressRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final double target;
  final String hint;

  const ProgressRow({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.target,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              CurrencyFormatter.percent(value),
              style: AppTypography.numericSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: AppRadius.pill,
          child: Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.surfaceOverlay,
                ),
              ),
              AnimatedContainer(
                duration: AppDuration.slow,
                curve: AppCurve.decelerate,
                height: 10,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hint,
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class HealthScoreBar extends StatelessWidget {
  final int score;

  const HealthScoreBar({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final label = FinancialCalculator.healthScoreLabel(score);
    final color = switch (score) {
      >= 80 => AppColors.income,
      >= 65 => AppColors.brandPrimary,
      >= 50 => AppColors.warning,
      >= 35 => AppColors.savings,
      _ => AppColors.expense,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Finansal Sağlık',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppRadius.pill,
              ),
              child: Text(
                '$label · $score/100',
                style: AppTypography.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: AppRadius.pill,
          child: Stack(
            children: [
              Container(
                height: 10,
                color: AppColors.surfaceOverlay,
              ),
              AnimatedContainer(
                duration: AppDuration.slow,
                curve: AppCurve.decelerate,
                height: 10,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: (score / 100.0).clamp(0.0, 1.0),
                  child: Container(color: color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
