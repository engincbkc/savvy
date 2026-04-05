import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/features/simulation/domain/models/simulation_result.dart';
import 'package:savvy/features/simulation/presentation/widgets/affordability_gauge.dart';
import 'package:savvy/features/simulation/presentation/widgets/before_after_card.dart';
import 'package:savvy/features/simulation/presentation/widgets/sim_editor_change_card.dart';

class SimSummaryItem {
  final String label;
  final String value;
  final Color color;
  const SimSummaryItem(
      {required this.label, required this.value, required this.color});
}

class SimSummaryRow extends StatelessWidget {
  final List<SimSummaryItem> items;
  const SimSummaryRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.card,
        border: Border.all(color: c.borderDefault.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: items
            .map((item) => Expanded(
                  child: Column(
                    children: [
                      Text(item.label,
                          style: AppTypography.caption.copyWith(
                              color: c.textTertiary, fontSize: 10)),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(item.value,
                            style: AppTypography.numericSmall.copyWith(
                                color: item.color,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class SimResultsSection extends StatelessWidget {
  final SimulationResult result;
  final MonthSummary budget;
  final Color color;
  final bool advancedMode;
  final VoidCallback onViewCashFlow;

  const SimResultsSection({
    super.key,
    required this.result,
    required this.budget,
    required this.color,
    required this.advancedMode,
    required this.onViewCashFlow,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isPositive = result.monthlyNetImpact >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.barChart3, size: 18, color: color),
            const SizedBox(width: AppSpacing.sm),
            Text('Sonuçlar',
                style: AppTypography.titleMedium
                    .copyWith(color: c.textPrimary)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Hero impact card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.cardLg,
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Text('AYLIK ETKİ',
                  style: AppTypography.labelSmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5)),
              const SizedBox(height: AppSpacing.sm),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${isPositive ? '+' : ''}${CurrencyFormatter.formatNoDecimal(result.monthlyNetImpact)}',
                  style: AppTypography.numericHero.copyWith(
                    color: isPositive ? c.income : c.expense,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Yıllık: ${isPositive ? '+' : ''}${CurrencyFormatter.formatNoDecimal(result.annualNetImpact)}',
                style: AppTypography.caption.copyWith(color: c.textTertiary),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),

        // Before / After
        BeforeAfterCard(
          budget: budget,
          monthlyImpact: result.monthlyNetImpact.abs(),
          newNetBalance: result.newNet,
        ),
        const SizedBox(height: AppSpacing.base),

        // Affordability
        if (result.affordability != null) ...[
          AffordabilityGauge(
            status: result.affordability!,
            ratio: result.newExpenseRate.clamp(0.0, 1.0),
          ),
          const SizedBox(height: AppSpacing.base),
        ],

        // Summary stats
        SimSummaryRow(
          items: [
            SimSummaryItem(
              label: 'Yeni Gelir',
              value: CurrencyFormatter.formatNoDecimal(result.newIncome),
              color: c.income,
            ),
            SimSummaryItem(
              label: 'Yeni Gider',
              value: CurrencyFormatter.formatNoDecimal(result.newExpense),
              color: c.expense,
            ),
            SimSummaryItem(
              label: 'Yeni Net',
              value: CurrencyFormatter.formatNoDecimal(result.newNet),
              color: result.newNet >= 0 ? c.income : c.expense,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.base),

        // Cash flow detail button
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onViewCashFlow();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: AppRadius.card,
              border: Border.all(color: color.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.calendarDays, size: 20, color: color),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Aylık Akış Detayı',
                          style: AppTypography.labelLarge
                              .copyWith(color: c.textPrimary)),
                      Text('Kalem kalem gelir ve giderleri görüntüle',
                          style: AppTypography.caption
                              .copyWith(color: c.textTertiary)),
                    ],
                  ),
                ),
                Icon(LucideIcons.chevronRight,
                    size: 18, color: c.textTertiary),
              ],
            ),
          ),
        ),

        // Per-change breakdown in advanced mode
        if (advancedMode) ...[
          const SizedBox(height: AppSpacing.lg),
          Text('Değişiklik Detayları',
              style: AppTypography.labelLarge
                  .copyWith(color: c.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          ...result.changeResults.map((cr) => SimChangeDetailRow(
                result: cr,
                color: color,
              )),
        ],
      ],
    );
  }
}
