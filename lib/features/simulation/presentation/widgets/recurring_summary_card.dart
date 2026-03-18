import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';

class RecurringSummaryCard extends StatelessWidget {
  final int recurringIncomeCount;
  final int recurringExpenseCount;
  final double totalRecurringIncome;
  final double totalRecurringExpense;

  const RecurringSummaryCard({
    super.key,
    required this.recurringIncomeCount,
    required this.recurringExpenseCount,
    required this.totalRecurringIncome,
    required this.totalRecurringExpense,
  });

  @override
  Widget build(BuildContext context) {
    final monthlyNet = totalRecurringIncome - totalRecurringExpense;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E3A5F),
            AppColors.of(context).brandPrimary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.cardLg,
        boxShadow: AppShadow.hero,
      ),
      child: Column(
        children: [
          Text(
            'AYLIK PERİYODİK ÖZET',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.of(context).textInverse.withValues(alpha: 0.7),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            CurrencyFormatter.formatNoDecimal(monthlyNet),
            style: AppTypography.numericHero.copyWith(
              color: AppColors.of(context).textInverse,
            ),
          ),
          Text(
            'aylık tahmini net',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.of(context).textInverse.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _RecurringMini(
                  label: 'Periyodik Gelir',
                  amount: totalRecurringIncome,
                  count: recurringIncomeCount,
                  color: AppColors.of(context).income,
                  icon: AppIcons.income,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _RecurringMini(
                  label: 'Periyodik Gider',
                  amount: totalRecurringExpense,
                  count: recurringExpenseCount,
                  color: AppColors.of(context).expense,
                  icon: AppIcons.expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecurringMini extends StatelessWidget {
  final String label;
  final double amount;
  final int count;
  final Color color;
  final IconData icon;

  const _RecurringMini({
    required this.label,
    required this.amount,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.of(context).textInverse.withValues(alpha: 0.1),
        borderRadius: AppRadius.chip,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.of(context).textInverse.withValues(alpha: 0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.formatNoDecimal(amount),
            style: AppTypography.numericSmall.copyWith(
              color: AppColors.of(context).textInverse,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '$count adet',
            style: AppTypography.caption.copyWith(
              color: AppColors.of(context).textInverse.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
