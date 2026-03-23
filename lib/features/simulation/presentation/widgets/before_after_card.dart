import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';

class BeforeAfterCard extends StatelessWidget {
  final MonthSummary budget;
  final double monthlyImpact;
  final double newNetBalance;

  const BeforeAfterCard({
    super.key,
    required this.budget,
    required this.monthlyImpact,
    required this.newNetBalance,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final newExpense = budget.totalExpense + monthlyImpact;

    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.card,
        boxShadow: AppShadow.sm,
        border: Border.all(color: c.borderDefault),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(LucideIcons.gitCompare, size: 16, color: c.brandPrimary),
              const SizedBox(width: AppSpacing.xs),
              Text('Bütçe Etkisi',
                  style: AppTypography.titleMedium
                      .copyWith(color: c.textPrimary)),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Row(
            children: [
              Expanded(
                child: _CompareColumn(
                  title: 'ŞİMDİ',
                  expense: budget.totalExpense,
                  net: budget.netBalance,
                  expenseColor: c.expense,
                  netColor: budget.netBalance >= 0 ? c.income : c.expense,
                  bgColor: c.surfaceInput,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Icon(LucideIcons.arrowRight,
                    size: 20, color: c.textTertiary),
              ),
              Expanded(
                child: _CompareColumn(
                  title: 'SONRA',
                  expense: newExpense,
                  net: newNetBalance,
                  expenseColor: c.expense,
                  netColor: newNetBalance >= 0 ? c.income : c.expense,
                  bgColor: newNetBalance >= 0
                      ? c.incomeSurfaceDim
                      : c.expenseSurfaceDim,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: (newNetBalance < budget.netBalance
                      ? c.expense
                      : c.income)
                  .withValues(alpha: 0.08),
              borderRadius: AppRadius.chip,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  newNetBalance < budget.netBalance
                      ? LucideIcons.trendingDown
                      : LucideIcons.trendingUp,
                  size: 14,
                  color: newNetBalance < budget.netBalance
                      ? c.expense
                      : c.income,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Net bakiye ${CurrencyFormatter.withSign(newNetBalance - budget.netBalance)} değişecek',
                  style: AppTypography.labelSmall.copyWith(
                    color: newNetBalance < budget.netBalance
                        ? c.expense
                        : c.income,
                    fontWeight: FontWeight.w600,
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

class _CompareColumn extends StatelessWidget {
  final String title;
  final double expense;
  final double net;
  final Color expenseColor;
  final Color netColor;
  final Color bgColor;

  const _CompareColumn({
    required this.title,
    required this.expense,
    required this.net,
    required this.expenseColor,
    required this.netColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.chip,
      ),
      child: Column(
        children: [
          Text(title,
              style: AppTypography.labelSmall.copyWith(
                  color: c.textTertiary, letterSpacing: 1)),
          const SizedBox(height: AppSpacing.sm),
          Text('Gider',
              style: AppTypography.caption.copyWith(color: c.textTertiary)),
          Text(CurrencyFormatter.formatNoDecimal(expense),
              style: AppTypography.numericSmall
                  .copyWith(color: expenseColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.xs),
          Text('Net',
              style: AppTypography.caption.copyWith(color: c.textTertiary)),
          Text(CurrencyFormatter.formatNoDecimal(net),
              style: AppTypography.numericSmall
                  .copyWith(color: netColor, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
