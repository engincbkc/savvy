import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';

class QuickStatsRow extends StatelessWidget {
  final MonthSummary summary;
  const QuickStatsRow({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Gelir',
            amount: summary.totalIncome,
            accentColor: c.income,
            icon: AppIcons.income,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            label: 'Gider',
            amount: summary.totalExpense,
            accentColor: c.expense,
            icon: AppIcons.expense,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            label: 'Birikim',
            amount: summary.totalSavings,
            accentColor: c.savings,
            icon: AppIcons.savings,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color accentColor;
  final IconData icon;
  const _StatCard({
    required this.label,
    required this.amount,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.card,
        boxShadow: AppShadow.md,
        border: Border.all(color: c.borderDefault.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Bold colored left accent stripe
          Container(
            width: 3,
            height: 82,
            color: accentColor,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.base,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon + label
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: AppRadius.chip,
                        ),
                        child: Icon(icon, size: 13, color: accentColor),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: AppTypography.caption.copyWith(
                          color: c.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Amount with count-up
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: amount),
                    duration: AppDuration.countUp,
                    curve: AppCurve.decelerate,
                    builder: (context, value, _) => FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        CurrencyFormatter.formatNoDecimal(value),
                        style: AppTypography.numericMedium.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
