import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';

class TaxReportScreen extends ConsumerStatefulWidget {
  const TaxReportScreen({super.key});

  @override
  ConsumerState<TaxReportScreen> createState() => _TaxReportScreenState();
}

class _TaxReportScreenState extends ConsumerState<TaxReportScreen> {
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    final allIncomesAsync = ref.watch(allIncomesProvider);
    final c = AppColors.of(context);
    final currentYear = DateTime.now().year;

    final isLoading = allIncomesAsync.isLoading;

    // Filter to selected year's gross incomes only
    final grossIncomes = (allIncomesAsync.value ?? [])
        .where((i) => i.isGross && i.date.year == _selectedYear && !i.isDeleted)
        .toList();

    // Aggregate annual breakdowns
    // Group gross incomes by their gross amount, sum them per month
    // For simplicity: calculate per income item over 12 months and scale by
    // the months it was active within the year (we use full-year for each
    // unique amount, then weight by occurrence).
    // Approach: compute monthly tax breakdown for each unique gross amount
    // and sum contributions.

    // Build a per-month (1..12) contribution map
    final Map<int, double> monthlyGross = {};
    final Map<int, double> monthlyTax = {};
    final Map<int, double> monthlySgk = {};
    final Map<int, double> monthlyStamp = {};
    final Map<int, double> monthlyNet = {};

    for (final income in grossIncomes) {
      final bd = FinancialCalculator.calculateAnnualNetSalary(
        grossMonthly: income.amount,
      );
      // We credit this income to its actual month in the selected year
      final m = income.date.month; // 1-indexed
      final detail = bd.months[m - 1];
      monthlyGross[m] = (monthlyGross[m] ?? 0) + income.amount;
      monthlyTax[m] = (monthlyTax[m] ?? 0) + detail.netIncomeTax;
      monthlySgk[m] = (monthlySgk[m] ?? 0) +
          detail.sgk +
          detail.unemploymentInsurance;
      monthlyStamp[m] = (monthlyStamp[m] ?? 0) + detail.netStampTax;
      monthlyNet[m] = (monthlyNet[m] ?? 0) + detail.netTakeHome;
    }

    final totalGross =
        monthlyGross.values.fold(0.0, (s, v) => s + v);
    final totalTax = monthlyTax.values.fold(0.0, (s, v) => s + v);
    final totalSgk = monthlySgk.values.fold(0.0, (s, v) => s + v);
    final totalStamp =
        monthlyStamp.values.fold(0.0, (s, v) => s + v);
    final totalNet = monthlyNet.values.fold(0.0, (s, v) => s + v);
    final totalDeductions = totalTax + totalSgk + totalStamp;
    final effectiveRate =
        totalGross > 0 ? totalDeductions / totalGross : 0.0;

    return Scaffold(
      backgroundColor: c.surfaceBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── App Bar ────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              backgroundColor: c.surfaceBackground,
              elevation: 0,
              title: Text(
                'Vergi Özeti $_selectedYear',
                style: AppTypography.headlineSmall.copyWith(
                  color: c.textPrimary,
                ),
              ),
              centerTitle: false,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded,
                    color: c.textPrimary, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            SliverPadding(
              padding: AppSpacing.screenH,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: AppSpacing.base),

                  // ─── Year Selector ─────────────────────────────────
                  _YearSelector(
                    selectedYear: _selectedYear,
                    currentYear: currentYear,
                    onChanged: (y) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedYear = y);
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ─── Content ───────────────────────────────────────
                  if (isLoading) ...[
                    const SavvyShimmer(
                      child: Column(
                        children: [
                          ShimmerBox(height: 260),
                          SizedBox(height: AppSpacing.xl),
                          ShimmerBox(height: 320),
                        ],
                      ),
                    ),
                  ] else if (grossIncomes.isEmpty) ...[
                    _EmptyState(year: _selectedYear),
                  ] else ...[
                    // ─── Summary Card ──────────────────────────────
                    _SummaryCard(
                      totalGross: totalGross,
                      totalTax: totalTax,
                      totalSgk: totalSgk,
                      totalStamp: totalStamp,
                      totalDeductions: totalDeductions,
                      totalNet: totalNet,
                      effectiveRate: effectiveRate,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // ─── Monthly breakdown ─────────────────────────
                    _MonthlyBreakdownTable(
                      year: _selectedYear,
                      monthlyGross: monthlyGross,
                      monthlyTax: monthlyTax,
                      monthlySgk: monthlySgk,
                      monthlyNet: monthlyNet,
                    ),
                  ],

                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Year Selector ─────────────────────────────────────────────────────────

class _YearSelector extends StatelessWidget {
  final int selectedYear;
  final int currentYear;
  final ValueChanged<int> onChanged;

  const _YearSelector({
    required this.selectedYear,
    required this.currentYear,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: c.surfaceOverlay,
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _YearTab(
            label: '${currentYear - 1}',
            isSelected: selectedYear == currentYear - 1,
            onTap: () => onChanged(currentYear - 1),
          ),
          _YearTab(
            label: '$currentYear',
            isSelected: selectedYear == currentYear,
            onTap: () => onChanged(currentYear),
          ),
        ],
      ),
    );
  }
}

class _YearTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _YearTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? c.surfaceCard : Colors.transparent,
          borderRadius: AppRadius.pill,
          boxShadow: isSelected ? AppShadow.sm : null,
        ),
        child: Text(
          label,
          style: AppTypography.titleSmall.copyWith(
            color: isSelected ? c.textPrimary : c.textTertiary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final double totalGross;
  final double totalTax;
  final double totalSgk;
  final double totalStamp;
  final double totalDeductions;
  final double totalNet;
  final double effectiveRate;

  const _SummaryCard({
    required this.totalGross,
    required this.totalTax,
    required this.totalSgk,
    required this.totalStamp,
    required this.totalDeductions,
    required this.totalNet,
    required this.effectiveRate,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.cardLg,
        boxShadow: AppShadow.sm,
        border: Border.all(
          color: c.borderDefault.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base,
              AppSpacing.base,
              AppSpacing.base,
              AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: c.surfaceOverlay.withValues(alpha: 0.4),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long_rounded,
                    size: 18, color: c.brandPrimary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Vergi Özeti',
                  style: AppTypography.titleMedium.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: AppSpacing.card,
            child: Column(
              children: [
                _SummaryRow(
                  label: 'Toplam Brüt',
                  amount: totalGross,
                  color: c.textPrimary,
                  isTotal: false,
                ),
                const SizedBox(height: AppSpacing.sm),
                _DividerLine(),
                const SizedBox(height: AppSpacing.sm),
                _SummaryRow(
                  label: 'Gelir Vergisi',
                  amount: -totalTax,
                  color: c.expense,
                  isTotal: false,
                ),
                const SizedBox(height: AppSpacing.xs),
                _SummaryRow(
                  label: 'SGK Primi',
                  amount: -totalSgk,
                  color: c.expense,
                  isTotal: false,
                ),
                const SizedBox(height: AppSpacing.xs),
                _SummaryRow(
                  label: 'Damga Vergisi',
                  amount: -totalStamp,
                  color: c.expense,
                  isTotal: false,
                ),
                const SizedBox(height: AppSpacing.sm),
                _DividerLine(),
                const SizedBox(height: AppSpacing.sm),
                _SummaryRow(
                  label: 'Toplam Kesinti',
                  amount: -totalDeductions,
                  color: c.expense,
                  isTotal: true,
                ),
                const SizedBox(height: AppSpacing.sm),
                _SummaryRow(
                  label: 'Net Gelir',
                  amount: totalNet,
                  color: c.income,
                  isTotal: true,
                ),
                const SizedBox(height: AppSpacing.base),

                // Effective rate chip
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                    horizontal: AppSpacing.base,
                  ),
                  decoration: BoxDecoration(
                    color: c.expense.withValues(alpha: 0.07),
                    borderRadius: AppRadius.chip,
                    border: Border.all(
                      color: c.expense.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Efektif Vergi Oranı',
                        style: AppTypography.titleSmall.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.percent(effectiveRate),
                        style: AppTypography.titleMedium.copyWith(
                          color: c.expense,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.amount,
    required this.color,
    required this.isTotal,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final displayAmount = amount < 0
        ? '-${CurrencyFormatter.formatNoDecimal(amount.abs())}'
        : CurrencyFormatter.formatNoDecimal(amount);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTypography.titleSmall.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w600,
                )
              : AppTypography.bodyMedium.copyWith(
                  color: c.textSecondary,
                ),
        ),
        Text(
          displayAmount,
          style: isTotal
              ? AppTypography.titleSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                )
              : AppTypography.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
        ),
      ],
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Divider(
      height: 1,
      thickness: 1,
      color: c.borderDefault.withValues(alpha: 0.3),
    );
  }
}

// ─── Monthly Breakdown Table ───────────────────────────────────────────────

class _MonthlyBreakdownTable extends StatelessWidget {
  final int year;
  final Map<int, double> monthlyGross;
  final Map<int, double> monthlyTax;
  final Map<int, double> monthlySgk;
  final Map<int, double> monthlyNet;

  const _MonthlyBreakdownTable({
    required this.year,
    required this.monthlyGross,
    required this.monthlyTax,
    required this.monthlySgk,
    required this.monthlyNet,
  });

  static const _monthNames = [
    'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    // Only show months that have data
    final activeMonths = List.generate(12, (i) => i + 1)
        .where((m) => (monthlyGross[m] ?? 0) > 0)
        .toList();

    if (activeMonths.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.cardLg,
        boxShadow: AppShadow.sm,
        border: Border.all(
          color: c.borderDefault.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base,
              AppSpacing.base,
              AppSpacing.base,
              AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: c.surfaceOverlay.withValues(alpha: 0.4),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded,
                    size: 16, color: c.brandPrimary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Aylık Detay',
                  style: AppTypography.titleMedium.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    'Ay',
                    style: AppTypography.caption.copyWith(
                      color: c.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Brüt',
                    style: AppTypography.caption.copyWith(
                      color: c.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Vergi',
                    style: AppTypography.caption.copyWith(
                      color: c.expense,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Net',
                    style: AppTypography.caption.copyWith(
                      color: c.income,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: c.borderDefault.withValues(alpha: 0.3),
          ),

          // Month rows
          ...activeMonths.asMap().entries.map((entry) {
            final idx = entry.key;
            final m = entry.value;
            final gross = monthlyGross[m] ?? 0;
            final tax = monthlyTax[m] ?? 0;
            final net = monthlyNet[m] ?? 0;
            final isLast = idx == activeMonths.length - 1;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 36,
                        child: Text(
                          _monthNames[m - 1],
                          style: AppTypography.titleSmall.copyWith(
                            color: c.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          CurrencyFormatter.compact(gross),
                          style: AppTypography.bodyMedium.copyWith(
                            color: c.textPrimary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          CurrencyFormatter.compact(tax),
                          style: AppTypography.bodyMedium.copyWith(
                            color: c.expense,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          CurrencyFormatter.compact(net),
                          style: AppTypography.bodyMedium.copyWith(
                            color: c.income,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: AppSpacing.base,
                    endIndent: AppSpacing.base,
                    color: c.borderDefault.withValues(alpha: 0.2),
                  ),
              ],
            );
          }),

          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final int year;

  const _EmptyState({required this.year});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl3,
        horizontal: AppSpacing.xl,
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 48,
            color: c.textTertiary.withValues(alpha: 0.35),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            '$year yılına ait brüt maaş geliri bulunamadı.',
            style: AppTypography.bodyMedium.copyWith(
              color: c.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Vergi hesabı için gelirlerinizi\n"Brüt" olarak işaretleyerek ekleyin.',
            style: AppTypography.bodySmall.copyWith(
              color: c.textTertiary.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
