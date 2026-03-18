import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/utils/currency_formatter.dart';

class BreakdownSection extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double totalSavings;

  const BreakdownSection({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalSavings,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BreakdownCard(
            icon: AppIcons.income,
            label: 'Gelir',
            amount: totalIncome,
            color: AppColors.income,
            bgColor: AppColors.incomeSurface,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: BreakdownCard(
            icon: AppIcons.expense,
            label: 'Gider',
            amount: totalExpense,
            color: AppColors.expense,
            bgColor: AppColors.expenseSurface,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: BreakdownCard(
            icon: AppIcons.savings,
            label: 'Birikim',
            amount: totalSavings,
            color: AppColors.savings,
            bgColor: AppColors.savingsSurface,
          ),
        ),
      ],
    );
  }
}

class BreakdownCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  final Color bgColor;

  const BreakdownCard({
    super.key,
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadius.chip,
            ),
            child: Icon(icon, color: AppColors.textInverse, size: 16),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.formatNoDecimal(amount),
              style: AppTypography.numericMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
