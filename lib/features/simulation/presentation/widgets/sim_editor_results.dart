import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/features/simulation/domain/models/simulation_change.dart';
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
            color: c.surfaceCard,
            borderRadius: AppRadius.cardLg,
            border: Border.all(color: c.borderDefault.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Text('AYLIK BÜTÇE ETKİSİ',
                  style: AppTypography.labelSmall.copyWith(
                      color: c.textSecondary,
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
                isPositive
                    ? 'Bu simülasyon aylık bütçenize ${CurrencyFormatter.formatNoDecimal(result.monthlyNetImpact)} ekleyecek'
                    : 'Bu simülasyon aylık bütçenizden ${CurrencyFormatter.formatNoDecimal(result.monthlyNetImpact.abs())} çıkaracak',
                style: AppTypography.caption.copyWith(color: c.textTertiary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Yıllık: ${isPositive ? '+' : ''}${CurrencyFormatter.formatNoDecimal(result.annualNetImpact)}',
                style: AppTypography.caption.copyWith(
                  color: c.textTertiary.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
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

        // Hesaplama Özeti kutusu
        _CalculationSummaryBox(result: result, color: color),
        const SizedBox(height: AppSpacing.base),

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

        // Disclaimer
        const SizedBox(height: AppSpacing.base),
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: c.surfaceCard,
            borderRadius: AppRadius.chip,
            border: Border.all(color: c.borderDefault.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.info, size: 12, color: c.textTertiary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Bu simülasyon bilgilendirme amaçlıdır. Bankaların gerçek kredi tekliflerinde kredi notu, gelir düzeyi ve kampanyalar gibi faktörler faiz oranını değiştirebilir. Kesin teklif için bankanızla görüşün.',
                  style: AppTypography.caption.copyWith(
                    color: c.textTertiary,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
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

/// Hesaplama Özeti — shows detailed breakdown for loan-based simulations.
class _CalculationSummaryBox extends StatelessWidget {
  final SimulationResult result;
  final Color color;

  const _CalculationSummaryBox({required this.result, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    // Find the first loan-based change for detail display
    final loanResult = result.changeResults
        .where((cr) => cr.change.hasLoan && cr.totalInterest != null)
        .firstOrNull;

    if (loanResult == null) return const SizedBox.shrink();

    final change = loanResult.change;
    final monthlyRate = change.monthlyRate ?? 0.0;
    final termMonths = change.termMonths ?? 0;
    final principal = change.loanPrincipal;
    final monthlyPayment = loanResult.monthlyImpact.abs();
    final totalPayment = monthlyPayment * termMonths;
    final totalInterest = loanResult.totalInterest ?? 0.0;
    final ymo = FinancialCalculator.calculateYMO(monthlyRate / 100);

    // Determine if housing (tax exempt)
    final isHousing = change is HousingChange;
    final taxLabel = isHousing ? 'Konut muaf' : 'KKDF %15 + BSMV %15';

    // For housing/car: show price and down payment
    double? price;
    double? downPayment;
    if (change is HousingChange) {
      price = change.price;
      downPayment = change.downPayment;
    } else if (change is CarChange) {
      price = change.price;
      downPayment = change.downPayment;
    }

    final termYears = termMonths ~/ 12;
    final termRemainder = termMonths % 12;
    final termLabel = termRemainder == 0
        ? '$termMonths ay ($termYears yıl)'
        : '$termMonths ay';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.card,
        border: Border.all(color: c.borderDefault.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.calculator, size: 16, color: color),
              const SizedBox(width: AppSpacing.xs),
              Text('Hesaplama Özeti',
                  style: AppTypography.titleMedium
                      .copyWith(color: c.textPrimary, fontSize: 14)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          if (price != null) ...[
            _SummaryLine(label: change.label, value: CurrencyFormatter.formatNoDecimal(price)),
            if (downPayment != null && downPayment > 0)
              _SummaryLine(label: 'Peşinat', value: '- ${CurrencyFormatter.formatNoDecimal(downPayment)}'),
            Divider(color: c.borderDefault.withValues(alpha: 0.3), height: AppSpacing.md),
          ],

          _SummaryLine(label: 'Çekilecek kredi', value: CurrencyFormatter.formatNoDecimal(principal), bold: true),
          const SizedBox(height: AppSpacing.sm),
          _SummaryLine(label: 'Aylık faiz', value: '%${monthlyRate.toStringAsFixed(2)}'),
          _SummaryLine(label: 'KKDF + BSMV', value: taxLabel),
          _SummaryLine(label: 'YMO', value: '%${(ymo * 100).toStringAsFixed(2)}'),
          _SummaryLine(label: 'Vade', value: termLabel),
          Divider(color: c.borderDefault.withValues(alpha: 0.3), height: AppSpacing.md),
          _SummaryLine(label: 'Aylık taksit', value: CurrencyFormatter.formatNoDecimal(monthlyPayment), bold: true),
          _SummaryLine(label: 'Toplam ödeme', value: CurrencyFormatter.formatNoDecimal(totalPayment)),
          _SummaryLine(label: 'Toplam faiz', value: CurrencyFormatter.formatNoDecimal(totalInterest), valueColor: c.expense),

          const SizedBox(height: AppSpacing.sm),
          Text(
            'Hesaplama bankaların kullandığı anüite (eşit taksit) yöntemine göre yapılmıştır.',
            style: AppTypography.caption.copyWith(
              color: c.textTertiary,
              fontSize: 9,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _SummaryLine({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.caption.copyWith(
                color: c.textSecondary,
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              )),
          Text(value,
              style: AppTypography.labelSmall.copyWith(
                color: valueColor ?? c.textPrimary,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                fontFeatures: const [FontFeature.tabularFigures()],
              )),
        ],
      ),
    );
  }
}
