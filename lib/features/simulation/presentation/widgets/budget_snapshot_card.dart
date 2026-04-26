import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';

class BudgetSnapshotCard extends StatelessWidget {
  final MonthSummary budget;

  const BudgetSnapshotCard({super.key, required this.budget});

  String _monthLabel() {
    // budget.yearMonth format: "2026-04"
    final parts = budget.yearMonth.split('-');
    if (parts.length < 2) return 'Mevcut';
    final monthIdx = int.tryParse(parts[1]);
    if (monthIdx == null || monthIdx < 1 || monthIdx > 12) return 'Mevcut';
    return FinancialCalculator.monthNamesTR[monthIdx - 1];
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFF8FAFC), const Color(0xFFEFF6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        border: Border.all(
          color: c.brandPrimary.withValues(alpha: isDark ? 0.2 : 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.wallet, size: 16, color: c.brandPrimary),
              const SizedBox(width: AppSpacing.xs),
              Text('${_monthLabel()} Ayı Bütçe Durumunuz',
                  style: AppTypography.labelMedium
                      .copyWith(color: c.brandPrimary)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _BudgetMini(
                    label: 'Gelir',
                    amount: budget.totalIncome,
                    color: c.income,
                    icon: LucideIcons.trendingUp),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _BudgetMini(
                    label: 'Gider',
                    amount: budget.totalExpense,
                    color: c.expense,
                    icon: LucideIcons.trendingDown),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _BudgetMini(
                    label: 'Net',
                    amount: budget.netBalance,
                    color: budget.netBalance >= 0 ? c.income : c.expense,
                    icon: LucideIcons.wallet),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetMini extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _BudgetMini(
      {required this.label,
      required this.amount,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 3),
            Text(label,
                style: AppTypography.caption.copyWith(color: c.textTertiary)),
          ],
        ),
        const SizedBox(height: 2),
        Text(CurrencyFormatter.formatNoDecimal(amount),
            style: AppTypography.numericSmall
                .copyWith(color: color, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
