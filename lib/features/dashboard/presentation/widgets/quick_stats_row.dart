import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/shared/widgets/info_tooltip.dart';

class QuickStatsRow extends StatelessWidget {
  final MonthSummary summary;
  const QuickStatsRow({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: QuickStatCard(
            label: 'Gelir',
            amount: summary.totalIncome,
            color: AppColors.of(context).income,
            icon: AppIcons.income,
            tooltipTitle: 'Aylık Gelir',
            tooltipDesc: 'Bu ayki toplam gelir tutarıdır. Maaş, ek iş, freelance ve diğer tüm gelir kaynaklarını içerir.',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: QuickStatCard(
            label: 'Gider',
            amount: summary.totalExpense,
            color: AppColors.of(context).expense,
            icon: AppIcons.expense,
            tooltipTitle: 'Aylık Gider',
            tooltipDesc: 'Bu ayki toplam gider tutarıdır. Sabit, değişken ve isteğe bağlı tüm harcamaları içerir.',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: QuickStatCard(
            label: 'Birikim',
            amount: summary.totalSavings,
            color: AppColors.of(context).savings,
            icon: AppIcons.savings,
            tooltipTitle: 'Aylık Birikim',
            tooltipDesc: 'Bu ayki toplam birikim tutarıdır. Acil durum fonu, altın, döviz ve diğer yatırımları içerir.',
          ),
        ),
      ],
    );
  }
}

class QuickStatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final String? tooltipTitle;
  final String? tooltipDesc;

  const QuickStatCard({
    super.key,
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    this.tooltipTitle,
    this.tooltipDesc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.of(context).surfaceCard,
        borderRadius: AppRadius.input,
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(icon, size: 13, color: color),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.of(context).textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (tooltipTitle != null && tooltipDesc != null)
                InfoTooltip(
                  title: tooltipTitle!,
                  description: tooltipDesc!,
                  size: 12,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.formatNoDecimal(amount),
              style: AppTypography.numericSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
