import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';

// ─── MonthCompareScreen ────────────────────────────────────────────────────

class MonthCompareScreen extends ConsumerStatefulWidget {
  final String? initialMonth;

  const MonthCompareScreen({super.key, this.initialMonth});

  @override
  ConsumerState<MonthCompareScreen> createState() => _MonthCompareScreenState();
}

class _MonthCompareScreenState extends ConsumerState<MonthCompareScreen> {
  String? _monthA;
  String? _monthB;
  bool _initialized = false;

  void _initDefaults(List<MonthSummary> summaries) {
    if (_initialized || summaries.isEmpty) return;
    _initialized = true;

    if (widget.initialMonth != null) {
      // initialMonth → A, current/most-recent → B
      _monthA = widget.initialMonth;
      final others = summaries.where((s) => s.yearMonth != _monthA).toList();
      _monthB = others.isNotEmpty ? others.first.yearMonth : summaries.first.yearMonth;
    } else {
      // A = second most recent, B = most recent
      _monthB = summaries.first.yearMonth;
      _monthA = summaries.length > 1 ? summaries[1].yearMonth : summaries.first.yearMonth;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allSummaries = ref.watch(allMonthSummariesProvider);
    final allExpensesAsync = ref.watch(allExpensesProvider);
    final allIncomesAsync = ref.watch(allIncomesProvider);
    final allSavingsAsync = ref.watch(allSavingsProvider);

    final isLoading = allExpensesAsync.isLoading ||
        allIncomesAsync.isLoading ||
        allSavingsAsync.isLoading;

    if (allSummaries.isNotEmpty && !_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _initDefaults(allSummaries));
      });
    }

    final c = AppColors.of(context);

    final summaryA = _monthA != null
        ? allSummaries.where((s) => s.yearMonth == _monthA).firstOrNull
        : null;
    final summaryB = _monthB != null
        ? allSummaries.where((s) => s.yearMonth == _monthB).firstOrNull
        : null;

    return Scaffold(
      backgroundColor: c.surfaceBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── App Bar ──────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              backgroundColor: c.surfaceBackground,
              elevation: 0,
              title: Text(
                'Ay Karşılaştırması',
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
              sliver: isLoading && allSummaries.isEmpty
                  ? SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: AppSpacing.base),
                        const SavvyShimmer(
                          child: Column(
                            children: [
                              ShimmerBox(height: 56),
                              SizedBox(height: AppSpacing.base),
                              ShimmerBox(height: 160),
                              SizedBox(height: AppSpacing.base),
                              ShimmerBox(height: 220),
                              SizedBox(height: AppSpacing.base),
                              ShimmerBox(height: 280),
                            ],
                          ),
                        ),
                      ]),
                    )
                  : SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: AppSpacing.base),

                        // ── Month pickers ─────────────────────────────
                        _MonthPickerRow(
                          summaries: allSummaries,
                          monthA: _monthA,
                          monthB: _monthB,
                          onPickA: (ym) => setState(() => _monthA = ym),
                          onPickB: (ym) => setState(() => _monthB = ym),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        if (summaryA != null && summaryB != null) ...[
                          // ── Hero summary cards ─────────────────────
                          _HeroCompareCards(
                            summaryA: summaryA,
                            summaryB: summaryB,
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // ── Metric table ───────────────────────────
                          _MetricTable(
                            summaryA: summaryA,
                            summaryB: summaryB,
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // ── Category breakdown ─────────────────────
                          _CategoryBreakdown(
                            monthA: _monthA!,
                            monthB: _monthB!,
                            allExpenses: allExpensesAsync.value ?? [],
                          ),
                        ] else if (allSummaries.isEmpty && !isLoading)
                          _EmptyState(),

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

// ─── Month Picker Row ─────────────────────────────────────────────────────

class _MonthPickerRow extends StatelessWidget {
  final List<MonthSummary> summaries;
  final String? monthA;
  final String? monthB;
  final ValueChanged<String> onPickA;
  final ValueChanged<String> onPickB;

  const _MonthPickerRow({
    required this.summaries,
    required this.monthA,
    required this.monthB,
    required this.onPickA,
    required this.onPickB,
  });

  Future<void> _showPicker(
    BuildContext context,
    String? current,
    ValueChanged<String> onPick,
    String label,
  ) async {
    final c = AppColors.of(context);
    await showModalBottomSheet(
      context: context,
      backgroundColor: c.surfaceCard,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
      builder: (_) => _MonthPickerSheet(
        summaries: summaries,
        current: current,
        label: label,
        onPick: (ym) {
          onPick(ym);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Row(
      children: [
        Expanded(
          child: _PickerChip(
            label: 'Ay A',
            value: monthA != null ? MonthLabels.short(monthA!) : null,
            accentColor: c.brandPrimary,
            onTap: () => _showPicker(context, monthA, onPickA, 'Ay A'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Icon(LucideIcons.arrowLeftRight,
              color: c.textTertiary, size: 16),
        ),
        Expanded(
          child: _PickerChip(
            label: 'Ay B',
            value: monthB != null ? MonthLabels.short(monthB!) : null,
            accentColor: c.expense,
            onTap: () => _showPicker(context, monthB, onPickB, 'Ay B'),
          ),
        ),
      ],
    );
  }
}

class _PickerChip extends StatelessWidget {
  final String label;
  final String? value;
  final Color accentColor;
  final VoidCallback onTap;

  const _PickerChip({
    required this.label,
    required this.value,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final hasValue = value != null;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: hasValue
              ? accentColor.withValues(alpha: 0.08)
              : c.surfaceOverlay,
          borderRadius: AppRadius.chip,
          border: Border.all(
            color: hasValue
                ? accentColor.withValues(alpha: 0.35)
                : c.borderDefault,
          ),
          boxShadow: hasValue ? AppShadow.xs : AppShadow.none,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: hasValue ? accentColor : c.textTertiary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    hasValue ? value! : 'Seç',
                    style: AppTypography.titleSmall.copyWith(
                      color: hasValue ? c.textPrimary : c.textTertiary,
                    ),
                  ),
                ),
                Icon(
                  LucideIcons.chevronsUpDown,
                  size: 14,
                  color: hasValue ? accentColor : c.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthPickerSheet extends StatelessWidget {
  final List<MonthSummary> summaries;
  final String? current;
  final String label;
  final ValueChanged<String> onPick;

  const _MonthPickerSheet({
    required this.summaries,
    required this.current,
    required this.label,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacing.md),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: c.borderDefault,
            borderRadius: AppRadius.pill,
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        Padding(
          padding: AppSpacing.screenH,
          child: Text(
            '$label — Ay Seç',
            style: AppTypography.titleLarge.copyWith(color: c.textPrimary),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.lg,
              AppSpacing.xl + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: summaries.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.xs),
            itemBuilder: (_, i) {
              final s = summaries[i];
              final isSelected = s.yearMonth == current;
              final isPositive = s.netBalance >= 0;
              final netColor = isPositive ? c.income : c.expense;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onPick(s.yearMonth);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                    vertical: AppSpacing.sm + 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? c.brandPrimary.withValues(alpha: 0.1)
                        : c.surfaceOverlay,
                    borderRadius: AppRadius.chip,
                    border: Border.all(
                      color: isSelected
                          ? c.brandPrimary.withValues(alpha: 0.4)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          MonthLabels.full(s.yearMonth),
                          style: AppTypography.titleSmall.copyWith(
                            color: isSelected
                                ? c.brandPrimary
                                : c.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.compact(s.netBalance),
                        style: AppTypography.labelSmall.copyWith(
                          color: netColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Icon(LucideIcons.check,
                            size: 14, color: c.brandPrimary),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Hero Compare Cards ───────────────────────────────────────────────────

class _HeroCompareCards extends StatelessWidget {
  final MonthSummary summaryA;
  final MonthSummary summaryB;

  const _HeroCompareCards({
    required this.summaryA,
    required this.summaryB,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Container(
      padding: AppSpacing.cardLg,
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.cardLg,
        boxShadow: AppShadow.sm,
        border: Border.all(color: c.borderDefault.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Month labels row ─────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _MonthBadge(
                  yearMonth: summaryA.yearMonth,
                  color: c.brandPrimary,
                  label: 'A',
                ),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: _MonthBadge(
                  yearMonth: summaryB.yearMonth,
                  color: c.expense,
                  label: 'B',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Container(
            height: 1,
            color: c.borderDefault.withValues(alpha: 0.4),
          ),
          const SizedBox(height: AppSpacing.base),

          // ── Stat rows ────────────────────────────────────────
          _HeroStatRow(
            label: 'Gelir',
            valueA: summaryA.totalIncome,
            valueB: summaryB.totalIncome,
            colorA: c.income,
            colorB: c.income,
            positiveIsGood: true,
            c: c,
          ),
          const SizedBox(height: AppSpacing.sm),
          _HeroStatRow(
            label: 'Gider',
            valueA: summaryA.totalExpense,
            valueB: summaryB.totalExpense,
            colorA: c.expense,
            colorB: c.expense,
            positiveIsGood: false,
            c: c,
          ),
          const SizedBox(height: AppSpacing.sm),
          _HeroStatRow(
            label: 'Net',
            valueA: summaryA.netBalance,
            valueB: summaryB.netBalance,
            colorA: summaryA.netBalance >= 0 ? c.income : c.expense,
            colorB: summaryB.netBalance >= 0 ? c.income : c.expense,
            positiveIsGood: true,
            bold: true,
            c: c,
          ),
          const SizedBox(height: AppSpacing.sm),
          _HeroStatRow(
            label: 'Birikim',
            valueA: summaryA.totalSavings,
            valueB: summaryB.totalSavings,
            colorA: c.savings,
            colorB: c.savings,
            positiveIsGood: true,
            c: c,
          ),
        ],
      ),
    );
  }
}

class _MonthBadge extends StatelessWidget {
  final String yearMonth;
  final Color color;
  final String label;

  const _MonthBadge({
    required this.yearMonth,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.chip,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              MonthLabels.full(yearMonth),
              style: AppTypography.labelSmall.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatRow extends StatelessWidget {
  final String label;
  final double valueA;
  final double valueB;
  final Color colorA;
  final Color colorB;
  final bool positiveIsGood;
  final bool bold;
  final dynamic c;

  const _HeroStatRow({
    required this.label,
    required this.valueA,
    required this.valueB,
    required this.colorA,
    required this.colorB,
    required this.positiveIsGood,
    required this.c,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final delta = valueB - valueA;
    final isPositiveDelta = delta >= 0;
    final isGood = positiveIsGood ? isPositiveDelta : !isPositiveDelta;
    final deltaColor = delta == 0
        ? (c as dynamic).textTertiary as Color
        : isGood
            ? (c as dynamic).income as Color
            : (c as dynamic).expense as Color;
    final col = AppColors.of(context);

    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: col.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            CurrencyFormatter.formatNoDecimal(valueA),
            style: AppTypography.numericSmall.copyWith(
              color: colorA,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
            textAlign: TextAlign.end,
          ),
        ),
        // Delta chip
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: _DeltaChip(
            delta: delta,
            color: deltaColor,
          ),
        ),
        Expanded(
          child: Text(
            CurrencyFormatter.formatNoDecimal(valueB),
            style: AppTypography.numericSmall.copyWith(
              color: colorB,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _DeltaChip extends StatelessWidget {
  final double delta;
  final Color color;

  const _DeltaChip({required this.delta, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    if (delta == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs, vertical: 2),
        decoration: BoxDecoration(
          color: c.surfaceOverlay,
          borderRadius: AppRadius.pill,
        ),
        child: Text(
          '=',
          style: AppTypography.caption.copyWith(
            color: c.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            delta > 0 ? LucideIcons.arrowUp : LucideIcons.arrowDown,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            CurrencyFormatter.compact(delta.abs()),
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Metric Comparison Table ───────────────────────────────────────────────

class _MetricTable extends StatelessWidget {
  final MonthSummary summaryA;
  final MonthSummary summaryB;

  const _MetricTable({required this.summaryA, required this.summaryB});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    final metrics = [
      _MetricDef(
        label: 'Toplam Gelir',
        valueA: summaryA.totalIncome,
        valueB: summaryB.totalIncome,
        positiveIsGood: true,
      ),
      _MetricDef(
        label: 'Toplam Gider',
        valueA: summaryA.totalExpense,
        valueB: summaryB.totalExpense,
        positiveIsGood: false,
      ),
      _MetricDef(
        label: 'Net Bakiye',
        valueA: summaryA.netBalance,
        valueB: summaryB.netBalance,
        positiveIsGood: true,
      ),
      _MetricDef(
        label: 'Birikim',
        valueA: summaryA.totalSavings,
        valueB: summaryB.totalSavings,
        positiveIsGood: true,
      ),
      _MetricDef(
        label: 'Tasarruf Oranı',
        valueA: summaryA.savingsRate,
        valueB: summaryB.savingsRate,
        positiveIsGood: true,
        isPercent: true,
      ),
      _MetricDef(
        label: 'Gider Oranı',
        valueA: summaryA.expenseRate,
        valueB: summaryB.expenseRate,
        positiveIsGood: false,
        isPercent: true,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.card,
        boxShadow: AppShadow.sm,
        border: Border.all(color: c.borderDefault.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base,
              AppSpacing.base,
              AppSpacing.base,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: c.brandPrimary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'METRİK KARŞILAŞTIRMA',
                  style: AppTypography.labelMedium.copyWith(
                    color: c.textTertiary,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Row(
              children: [
                const SizedBox(width: 110),
                Expanded(
                  child: Text(
                    'Ay A',
                    style: AppTypography.caption.copyWith(
                      color: c.brandPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: Text(
                    'Ay B',
                    style: AppTypography.caption.copyWith(
                      color: c.expense,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ...metrics.asMap().entries.map((entry) {
            return Column(
              children: [
                Container(
                  height: 1,
                  color: c.borderDefault.withValues(alpha: 0.3),
                ),
                _MetricRow(
                  metric: entry.value,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _MetricDef {
  final String label;
  final double valueA;
  final double valueB;
  final bool positiveIsGood;
  final bool isPercent;

  const _MetricDef({
    required this.label,
    required this.valueA,
    required this.valueB,
    required this.positiveIsGood,
    this.isPercent = false,
  });
}

class _MetricRow extends StatelessWidget {
  final _MetricDef metric;

  const _MetricRow({required this.metric});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final delta = metric.valueB - metric.valueA;
    final isPositive = delta >= 0;
    final isGood =
        metric.positiveIsGood ? isPositive : !isPositive;
    final deltaColor = delta == 0
        ? c.textTertiary
        : isGood
            ? c.income
            : c.expense;

    String formatVal(double v) => metric.isPercent
        ? CurrencyFormatter.percent(v)
        : CurrencyFormatter.formatNoDecimal(v);

    String formatDelta(double d) {
      if (metric.isPercent) {
        return CurrencyFormatter.changePercent(d);
      }
      final sign = d >= 0 ? '+' : '-';
      return '$sign${CurrencyFormatter.compact(d.abs())}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              metric.label,
              style: AppTypography.bodySmall.copyWith(
                color: c.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              formatVal(metric.valueA),
              style: AppTypography.numericSmall.copyWith(
                color: c.textPrimary,
                fontSize: 12,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          // Delta column
          SizedBox(
            width: AppSpacing.xl3,
            child: Center(
              child: delta == 0
                  ? Text(
                      '—',
                      style: AppTypography.caption
                          .copyWith(color: c.textTertiary),
                      textAlign: TextAlign.center,
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          delta > 0
                              ? LucideIcons.arrowUp
                              : LucideIcons.arrowDown,
                          size: 10,
                          color: deltaColor,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          formatDelta(delta).replaceAll('+', '').replaceAll('-', ''),
                          style: AppTypography.caption.copyWith(
                            color: deltaColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          Expanded(
            child: Text(
              formatVal(metric.valueB),
              style: AppTypography.numericSmall.copyWith(
                color: c.textPrimary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category Breakdown ───────────────────────────────────────────────────

class _CategoryBreakdown extends StatelessWidget {
  final String monthA;
  final String monthB;
  final List<dynamic> allExpenses;

  const _CategoryBreakdown({
    required this.monthA,
    required this.monthB,
    required this.allExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    // Build per-category totals for each month
    final Map<ExpenseCategory, double> totalsA = {};
    final Map<ExpenseCategory, double> totalsB = {};

    for (final e in allExpenses) {
      if (e.isDeleted == true) continue;
      final ym = (e.date as DateTime).toYearMonth();
      if (ym == monthA) {
        totalsA[e.category as ExpenseCategory] =
            (totalsA[e.category] ?? 0) + (e.amount as double);
      } else if (ym == monthB) {
        totalsB[e.category as ExpenseCategory] =
            (totalsB[e.category] ?? 0) + (e.amount as double);
      }
    }

    // Union of categories
    final categories = <ExpenseCategory>{
      ...totalsA.keys,
      ...totalsB.keys,
    }.toList();

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort by largest absolute difference
    categories.sort((a, b) {
      final diffA = ((totalsA[a] ?? 0) - (totalsB[a] ?? 0)).abs();
      final diffB = ((totalsA[b] ?? 0) - (totalsB[b] ?? 0)).abs();
      return diffB.compareTo(diffA);
    });

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.card,
        boxShadow: AppShadow.sm,
        border: Border.all(color: c.borderDefault.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base,
              AppSpacing.base,
              AppSpacing.base,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: c.expense,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'KATEGORİ KARŞILAŞTIRMA',
                  style: AppTypography.labelMedium.copyWith(
                    color: c.textTertiary,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Row(
              children: [
                const SizedBox(width: 130),
                Expanded(
                  child: Text(
                    'Ay A',
                    style: AppTypography.caption.copyWith(
                      color: c.brandPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: Text(
                    'Ay B',
                    style: AppTypography.caption.copyWith(
                      color: c.expense,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ...categories.asMap().entries.map((entry) {
            final cat = entry.value;
            final aVal = totalsA[cat] ?? 0;
            final bVal = totalsB[cat] ?? 0;
            final delta = bVal - aVal;

            return Column(
              children: [
                Container(
                  height: 1,
                  color: c.borderDefault.withValues(alpha: 0.3),
                ),
                _CategoryRow(
                  category: cat,
                  valueA: aVal,
                  valueB: bVal,
                  delta: delta,
                ),
              ],
            );
          }),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final ExpenseCategory category;
  final double valueA;
  final double valueB;
  final double delta;

  const _CategoryRow({
    required this.category,
    required this.valueA,
    required this.valueB,
    required this.delta,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    // For expenses: higher B = worse (red), lower B = better (green)
    final deltaColor = delta == 0
        ? c.textTertiary
        : delta > 0
            ? c.expense
            : c.income;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Category icon + name
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: c.expenseSurface,
              borderRadius: AppRadius.chip,
            ),
            child: Icon(
              category.icon,
              size: 14,
              color: c.expense,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 90,
            child: Text(
              category.label,
              style: AppTypography.bodySmall.copyWith(
                color: c.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              valueA > 0 ? CurrencyFormatter.formatNoDecimal(valueA) : '—',
              style: AppTypography.numericSmall.copyWith(
                color: valueA > 0 ? c.textPrimary : c.textTertiary,
                fontSize: 12,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          // Delta chip
          SizedBox(
            width: AppSpacing.xl3,
            child: Center(
              child: delta == 0
                  ? Text(
                      '—',
                      style: AppTypography.caption
                          .copyWith(color: c.textTertiary),
                      textAlign: TextAlign.center,
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: deltaColor.withValues(alpha: 0.12),
                        borderRadius: AppRadius.pill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            delta > 0
                                ? LucideIcons.arrowUp
                                : LucideIcons.arrowDown,
                            size: 9,
                            color: deltaColor,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            CurrencyFormatter.compact(delta.abs()),
                            style: AppTypography.caption.copyWith(
                              color: deltaColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          Expanded(
            child: Text(
              valueB > 0 ? CurrencyFormatter.formatNoDecimal(valueB) : '—',
              style: AppTypography.numericSmall.copyWith(
                color: valueB > 0 ? c.textPrimary : c.textTertiary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl3),
      child: Column(
        children: [
          Icon(
            LucideIcons.barChart2,
            size: 48,
            color: c.textTertiary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Karşılaştırmak için en az\nbir aylık veri gerekli.',
            style: AppTypography.bodyMedium.copyWith(color: c.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
