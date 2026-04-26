import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/simulation/domain/models/simulation_change.dart';
import 'package:savvy/features/simulation/domain/models/simulation_result.dart';

class SimChangeCard extends StatelessWidget {
  final SimulationChange change;
  final int index;
  final Color color;
  final ChangeResult? result;
  final bool advancedMode;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SimChangeCard({
    super.key,
    required this.change,
    required this.index,
    required this.color,
    this.result,
    required this.advancedMode,
    required this.onTap,
    required this.onDelete,
  });

  IconData get _icon => switch (change) {
        CreditChange() => LucideIcons.creditCard,
        HousingChange() => LucideIcons.home,
        CarChange() => LucideIcons.car,
        RentChangeChange() => LucideIcons.building2,
        SalaryChangeChange() => LucideIcons.briefcase,
        IncomeChange() => LucideIcons.trendingUp,
        ExpenseChange() => LucideIcons.trendingDown,
        InvestmentChange() => LucideIcons.lineChart,
      };

  String get _subtitle => switch (change) {
        CreditChange c =>
          '${CurrencyFormatter.formatNoDecimal(c.principal)} · %${c.monthlyRate}/ay · ${c.termMonths} ay',
        HousingChange c =>
          '${CurrencyFormatter.formatNoDecimal(c.price)} · ${c.termMonths} ay',
        CarChange c =>
          '${CurrencyFormatter.formatNoDecimal(c.price)} · ${c.termMonths} ay',
        RentChangeChange c =>
          '${CurrencyFormatter.formatNoDecimal(c.currentRent)} → ${CurrencyFormatter.formatNoDecimal(c.newRent)}',
        SalaryChangeChange c =>
          '${CurrencyFormatter.formatNoDecimal(c.currentGross)} → ${CurrencyFormatter.formatNoDecimal(c.newGross)} brüt',
        IncomeChange c =>
          '${CurrencyFormatter.formatNoDecimal(c.amount)} ${c.isRecurring ? "/ ay" : "tek seferlik"}',
        ExpenseChange c =>
          '${CurrencyFormatter.formatNoDecimal(c.amount)} ${c.isRecurring ? "/ ay" : "tek seferlik"}',
        InvestmentChange c =>
          '${CurrencyFormatter.formatNoDecimal(c.principal)} · %${c.annualReturnRate} · ${c.termMonths} ay',
      };

  bool get _isPositive => (result?.monthlyImpact ?? 0) >= 0;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final impact = result?.monthlyImpact;

    return Dismissible(
      key: ValueKey('change_$index'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: c.expense.withValues(alpha: 0.1),
          borderRadius: AppRadius.card,
        ),
        child: Icon(LucideIcons.trash2, color: c.expense),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: c.surfaceCard,
            borderRadius: AppRadius.card,
            border: Border.all(
                color: c.borderDefault.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(_icon, size: 18, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(change.label,
                        style: AppTypography.labelLarge
                            .copyWith(color: c.textPrimary)),
                    const SizedBox(height: 2),
                    Text(_subtitle,
                        style: AppTypography.caption
                            .copyWith(color: c.textTertiary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    // Always visible: total interest and total cost for loan-based changes
                    if (result != null) ...[
                      if (result!.totalInterest != null &&
                          result!.totalInterest! > 0) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Toplam Faiz: ${CurrencyFormatter.formatNoDecimal(result!.totalInterest!)}',
                          style: AppTypography.caption.copyWith(
                              color: c.expense, fontSize: 10),
                        ),
                      ],
                      if (result!.totalCost != null &&
                          result!.totalCost! > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Toplam Maliyet: ${CurrencyFormatter.formatNoDecimal(result!.totalCost!)}',
                          style: AppTypography.caption.copyWith(
                              color: c.textSecondary, fontSize: 10),
                        ),
                      ],
                    ],
                    // Advanced: show detailed breakdown
                    if (advancedMode && result != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      if (result!.salaryImpact != null)
                        Text(
                          'Net Ort: ${CurrencyFormatter.formatNoDecimal(result!.salaryImpact!.currentNetAvg)} → ${CurrencyFormatter.formatNoDecimal(result!.salaryImpact!.newNetAvg)}',
                          style: AppTypography.caption.copyWith(
                              color: c.income, fontSize: 10),
                        ),
                      if (result!.investmentImpact != null) ...[
                        Text(
                          'Vade Sonu: ${CurrencyFormatter.formatNoDecimal(result!.investmentImpact!.totalValue)}',
                          style: AppTypography.caption.copyWith(
                              color: c.savings, fontSize: 10),
                        ),
                        Text(
                          'Net Getiri: +${CurrencyFormatter.formatNoDecimal(result!.investmentImpact!.totalReturn)} (${result!.investmentImpact!.termMonths} ay)',
                          style: AppTypography.caption.copyWith(
                              color: c.textSecondary, fontSize: 10),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              if (impact != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_isPositive ? '+' : ''}${CurrencyFormatter.formatNoDecimal(impact)}',
                      style: AppTypography.numericSmall.copyWith(
                        color: _isPositive ? c.income : c.expense,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text('/ay',
                        style: AppTypography.caption.copyWith(
                            color: c.textTertiary, fontSize: 9)),
                  ],
                ),
              ],
              const SizedBox(width: AppSpacing.xs),
              Icon(LucideIcons.chevronRight,
                  size: 16, color: c.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class SimChangeDetailRow extends StatelessWidget {
  final ChangeResult result;
  final Color color;

  const SimChangeDetailRow({
    super.key,
    required this.result,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isPositive = result.monthlyImpact >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.chip,
        border: Border.all(color: c.borderDefault.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(result.change.label,
                  style: AppTypography.labelMedium
                      .copyWith(color: c.textPrimary)),
              Text(
                '${isPositive ? '+' : ''}${CurrencyFormatter.formatNoDecimal(result.monthlyImpact)}/ay',
                style: AppTypography.numericSmall.copyWith(
                    color: isPositive ? c.income : c.expense,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          if (result.totalCost != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Text('Toplam: ',
                    style: AppTypography.caption
                        .copyWith(color: c.textTertiary, fontSize: 10)),
                Text(CurrencyFormatter.formatNoDecimal(result.totalCost!),
                    style: AppTypography.caption.copyWith(
                        color: c.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
                if (result.totalInterest != null) ...[
                  Text(' · Faiz: ',
                      style: AppTypography.caption
                          .copyWith(color: c.textTertiary, fontSize: 10)),
                  Text(
                      CurrencyFormatter.formatNoDecimal(
                          result.totalInterest!),
                      style: AppTypography.caption.copyWith(
                          color: c.expense,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
