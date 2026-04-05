import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';

class CashFlowForecastScreen extends ConsumerWidget {
  const CashFlowForecastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allIncomesAsync = ref.watch(allIncomesProvider);
    final allExpensesAsync = ref.watch(allExpensesProvider);
    final allSavingsAsync = ref.watch(allSavingsProvider);

    final isLoading = allIncomesAsync.isLoading ||
        allExpensesAsync.isLoading ||
        allSavingsAsync.isLoading;

    final projections = ref.watch(futureProjectionsProvider);
    final allSummaries = ref.watch(allMonthSummariesProvider);
    final includeSavings = ref.watch(includeSavingsInProjectionProvider);
    final c = AppColors.of(context);

    // Last 3 past summaries (sorted most-recent-first by provider)
    final pastSummaries = allSummaries.take(3).toList().reversed.toList();

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
                'Nakit Akış Tahmini',
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
              actions: [
                // Tasarruf dahil toggle
                Padding(
                  padding:
                      const EdgeInsets.only(right: AppSpacing.base),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref
                          .read(includeSavingsInProjectionProvider.notifier)
                          .toggle();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: includeSavings
                            ? c.savings.withValues(alpha: 0.15)
                            : c.surfaceOverlay,
                        borderRadius: AppRadius.pill,
                        border: Border.all(
                          color: includeSavings
                              ? c.savings.withValues(alpha: 0.4)
                              : c.borderDefault,
                        ),
                      ),
                      child: Text(
                        includeSavings ? 'Birikim ✓' : 'Birikim',
                        style: AppTypography.labelSmall.copyWith(
                          color: includeSavings ? c.savings : c.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SliverPadding(
              padding: AppSpacing.screenH,
              sliver: isLoading
                  ? SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: AppSpacing.base),
                        const SavvyShimmer(
                          child: Column(
                            children: [
                              ShimmerBox(height: 140),
                              SizedBox(height: AppSpacing.base),
                              ShimmerBox(height: 72),
                              SizedBox(height: AppSpacing.sm),
                              ShimmerBox(height: 72),
                              SizedBox(height: AppSpacing.sm),
                              ShimmerBox(height: 72),
                              SizedBox(height: AppSpacing.base),
                              ShimmerBox(height: 72),
                              SizedBox(height: AppSpacing.sm),
                              ShimmerBox(height: 72),
                            ],
                          ),
                        ),
                      ]),
                    )
                  : SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: AppSpacing.base),

                        // ── Summary hero card ─────────────────────────
                        if (projections.isNotEmpty)
                          _SummaryCard(projections: projections),

                        const SizedBox(height: AppSpacing.xl),

                        // ── Gerçekleşen section ───────────────────────
                        if (pastSummaries.isNotEmpty) ...[
                          _SectionLabel(label: 'Gerçekleşen'),
                          const SizedBox(height: AppSpacing.sm),
                          ...pastSummaries.map(
                            (s) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm),
                              child: _MonthCard(
                                summary: s,
                                maxCumulative: pastSummaries
                                    .map((x) => x.netWithCarryOver.abs())
                                    .fold(1.0,
                                        (a, b) => a > b ? a : b),
                                isPast: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],

                        // ── Tahmin section ────────────────────────────
                        if (projections.isNotEmpty) ...[
                          _SectionLabel(label: 'Gelecek 12 Ay Tahmini'),
                          const SizedBox(height: AppSpacing.sm),
                          ...() {
                            final maxCum = projections
                                .map((p) => p.netWithCarryOver.abs())
                                .fold(1.0, (a, b) => a > b ? a : b);
                            return projections.map(
                              (p) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppSpacing.sm),
                                child: _MonthCard(
                                  summary: p,
                                  maxCumulative: maxCum,
                                  isPast: false,
                                ),
                              ),
                            );
                          }(),
                        ],

                        if (projections.isEmpty && !isLoading)
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

// ─── Summary Hero Card ─────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final List<MonthSummary> projections;

  const _SummaryCard({required this.projections});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    final best = projections.reduce(
        (a, b) => a.netBalance > b.netBalance ? a : b);
    final worst = projections.reduce(
        (a, b) => a.netBalance < b.netBalance ? a : b);
    final finalCumulative = projections.last.netWithCarryOver;

    return Container(
      padding: AppSpacing.cardLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            c.brandPrimary,
            c.brandPrimary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.cardLg,
        boxShadow: AppShadow.hero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '12 Ay Özeti',
            style: AppTypography.labelMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Row(
            children: [
              Expanded(
                child: _SummaryStat(
                  label: 'En Rahat Ay',
                  value: MonthLabels.short(best.yearMonth),
                  sub: CurrencyFormatter.compact(best.netBalance),
                  color: const Color(0xFF34D399),
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              Expanded(
                child: _SummaryStat(
                  label: 'En Sıkışık Ay',
                  value: MonthLabels.short(worst.yearMonth),
                  sub: CurrencyFormatter.compact(worst.netBalance),
                  color: const Color(0xFFFCA5A5),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          const SizedBox(height: AppSpacing.base),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '12 Ay Kümülatif Net',
                style: AppTypography.titleSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              Text(
                CurrencyFormatter.compact(finalCumulative),
                style: AppTypography.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;

  const _SummaryStat({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          sub,
          style: AppTypography.caption.copyWith(color: color),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Row(
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
          label.toUpperCase(),
          style: AppTypography.labelMedium.copyWith(
            color: c.textTertiary,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Month Card ───────────────────────────────────────────────────────────

class _MonthCard extends StatelessWidget {
  final MonthSummary summary;
  final double maxCumulative;
  final bool isPast;

  const _MonthCard({
    required this.summary,
    required this.maxCumulative,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isPositive = summary.netBalance >= 0;
    final netColor = isPositive ? c.income : c.expense;
    final barValue = maxCumulative > 0
        ? (summary.netWithCarryOver.abs() / maxCumulative).clamp(0.0, 1.0)
        : 0.0;
    final barColor = summary.netWithCarryOver >= 0 ? c.income : c.expense;

    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isPast
              ? c.borderDefault.withValues(alpha: 0.4)
              : netColor.withValues(alpha: 0.15),
        ),
        boxShadow: AppShadow.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Month label
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isPast
                      ? c.surfaceOverlay
                      : netColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.chip,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      MonthLabels.shortName(summary.yearMonth),
                      style: AppTypography.labelSmall.copyWith(
                        color: isPast ? c.textTertiary : netColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      "'${summary.yearMonth.split('-')[0].substring(2)}",
                      style: AppTypography.caption.copyWith(
                        color: isPast
                            ? c.textTertiary.withValues(alpha: 0.6)
                            : netColor.withValues(alpha: 0.7),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Income / Expense / Net
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _AmountColumn(
                        label: 'Gelir',
                        amount: summary.totalIncome,
                        color: c.income,
                      ),
                    ),
                    Expanded(
                      child: _AmountColumn(
                        label: 'Gider',
                        amount: summary.totalExpense,
                        color: c.expense,
                      ),
                    ),
                    Expanded(
                      child: _AmountColumn(
                        label: 'Net',
                        amount: summary.netBalance,
                        color: netColor,
                        bold: true,
                        showSign: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Cumulative bar
          Row(
            children: [
              const SizedBox(width: 56),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kümülatif',
                          style: AppTypography.caption.copyWith(
                            color: c.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.compact(summary.netWithCarryOver),
                          style: AppTypography.caption.copyWith(
                            color: barColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: AppRadius.pill,
                      child: LinearProgressIndicator(
                        value: barValue,
                        minHeight: 5,
                        backgroundColor: c.surfaceOverlay,
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountColumn extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool bold;
  final bool showSign;

  const _AmountColumn({
    required this.label,
    required this.amount,
    required this.color,
    this.bold = false,
    this.showSign = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final text = showSign
        ? CurrencyFormatter.withSign(amount).replaceAll(',00', '')
        : CurrencyFormatter.compact(amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: c.textTertiary,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          text,
          style: AppTypography.labelSmall.copyWith(
            color: color,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xl3, horizontal: AppSpacing.xl),
      child: Column(
        children: [
          Icon(Icons.trending_up_rounded,
              size: 48, color: c.textTertiary.withValues(alpha: 0.4)),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Projeksiyon için tekrar eden\ngelir veya gider ekleyin.',
            style: AppTypography.bodyMedium.copyWith(
              color: c.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
