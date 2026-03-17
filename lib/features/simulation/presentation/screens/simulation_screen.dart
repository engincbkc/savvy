import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/dashboard/presentation/screens/dashboard_screen.dart';

class SimulationScreen extends ConsumerWidget {
  const SimulationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projections = ref.watch(futureProjectionsProvider);
    final allInc = ref.watch(allIncomesProvider).value ?? [];
    final allExp = ref.watch(allExpensesProvider).value ?? [];

    final now = DateTime.now();
    final recurringIncomes = allInc
        .where((i) =>
            i.isRecurring &&
            (i.recurringEndDate == null || i.recurringEndDate!.isAfter(now)))
        .toList();
    final recurringExpenses = allExp
        .where((e) =>
            e.isRecurring &&
            (e.recurringEndDate == null || e.recurringEndDate!.isAfter(now)))
        .toList();

    final totalRecurringIncome =
        recurringIncomes.fold(0.0, (sum, i) => sum + i.amount);
    final totalRecurringExpense =
        recurringExpenses.fold(0.0, (sum, e) => sum + e.amount);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text(
              'Gelecek Tahmini',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.brandPrimary,
              ),
            ),
            centerTitle: false,
          ),
          SliverPadding(
            padding: AppSpacing.screenH,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSpacing.sm),

                // ── Recurring summary card ──
                _RecurringSummaryCard(
                  recurringIncomeCount: recurringIncomes.length,
                  recurringExpenseCount: recurringExpenses.length,
                  totalRecurringIncome: totalRecurringIncome,
                  totalRecurringExpense: totalRecurringExpense,
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Section title ──
                Row(
                  children: [
                    const Icon(Icons.auto_graph_rounded,
                        size: 20, color: AppColors.brandPrimary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Önümüzdeki 6 Ay',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Periyodik gelir ve giderlerine göre tahmini projeksiyon',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                if (projections.isEmpty)
                  _EmptyProjection()
                else ...[
                  // ── Trend chart ──
                  _TrendChart(projections: projections),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Month projection cards ──
                  ...projections.map((p) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _ProjectionCard(projection: p),
                      )),
                ],

                const SizedBox(height: AppSpacing.xl5),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recurring Summary Card ──────────────────────────────────────────────────

class _RecurringSummaryCard extends StatelessWidget {
  final int recurringIncomeCount;
  final int recurringExpenseCount;
  final double totalRecurringIncome;
  final double totalRecurringExpense;

  const _RecurringSummaryCard({
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
            AppColors.brandPrimary,
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
              color: AppColors.textInverse.withValues(alpha: 0.7),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            CurrencyFormatter.formatNoDecimal(monthlyNet),
            style: AppTypography.numericHero.copyWith(
              color: AppColors.textInverse,
            ),
          ),
          Text(
            'aylık tahmini net',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textInverse.withValues(alpha: 0.6),
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
                  color: AppColors.income,
                  icon: AppIcons.income,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _RecurringMini(
                  label: 'Periyodik Gider',
                  amount: totalRecurringExpense,
                  count: recurringExpenseCount,
                  color: AppColors.expense,
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
        color: AppColors.textInverse.withValues(alpha: 0.1),
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
                    color: AppColors.textInverse.withValues(alpha: 0.7),
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
              color: AppColors.textInverse,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '$count adet',
            style: AppTypography.caption.copyWith(
              color: AppColors.textInverse.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Trend Chart ─────────────────────────────────────────────────────────────

class _TrendChart extends StatelessWidget {
  final List<MonthSummary> projections;

  const _TrendChart({required this.projections});

  static const _monthNames = [
    '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
  ];

  @override
  Widget build(BuildContext context) {
    final values = projections.map((p) => p.netWithCarryOver).toList();
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final range = (maxVal - minVal).abs();
    final effectiveRange = range == 0 ? 1.0 : range;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.card,
        boxShadow: AppShadow.sm,
        border: Border.all(
          color: AppColors.borderDefault.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kümülatif Bakiye Trendi',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: projections.asMap().entries.map((entry) {
                final idx = entry.key;
                final p = entry.value;
                final normalized =
                    ((p.netWithCarryOver - minVal) / effectiveRange)
                        .clamp(0.1, 1.0);

                final monthNum =
                    int.parse(p.yearMonth.split('-')[1]);

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: idx == 0 ? 0 : 3,
                      right: idx == projections.length - 1 ? 0 : 3,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.formatNoDecimal(
                              p.netWithCarryOver),
                          style: AppTypography.caption.copyWith(
                            color: p.netWithCarryOver >= 0
                                ? AppColors.income
                                : AppColors.expense,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 80 * normalized,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: p.netWithCarryOver >= 0
                                  ? [
                                      const Color(0xFF059669),
                                      const Color(0xFF10B981),
                                    ]
                                  : [
                                      const Color(0xFFDC2626),
                                      const Color(0xFFEF4444),
                                    ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _monthNames[monthNum],
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Projection Card ─────────────────────────────────────────────────────────

class _ProjectionCard extends StatelessWidget {
  final MonthSummary projection;

  const _ProjectionCard({required this.projection});

  @override
  Widget build(BuildContext context) {
    final label = DashboardScreen.monthLabel(projection.yearMonth);
    final isPositive = projection.netBalance >= 0;

    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.card,
        boxShadow: AppShadow.sm,
        border: Border.all(
          color: AppColors.borderDefault.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.income : AppColors.expense)
                      .withValues(alpha: 0.1),
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(
                  isPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: isPositive ? AppColors.income : AppColors.expense,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Tahmini',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Net',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Text(
                    '${isPositive ? '+' : ''}${CurrencyFormatter.formatNoDecimal(projection.netBalance)}',
                    style: AppTypography.numericSmall.copyWith(
                      color:
                          isPositive ? AppColors.income : AppColors.expense,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Row(
            children: [
              _MiniStat(
                label: 'Gelir',
                amount: projection.totalIncome,
                color: AppColors.income,
                prefix: '+',
              ),
              _MiniStat(
                label: 'Gider',
                amount: projection.totalExpense,
                color: AppColors.expense,
                prefix: '-',
              ),
              _MiniStat(
                label: 'Kümülatif',
                amount: projection.netWithCarryOver,
                color: projection.netWithCarryOver >= 0
                    ? AppColors.brandPrimary
                    : AppColors.expense,
                prefix: '',
              ),
            ],
          ),
          if (projection.totalIncome == 0 && projection.totalExpense == 0)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text(
                    'Bu ay için periyodik kayıt yok',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.warning,
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

class _MiniStat extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final String prefix;

  const _MiniStat({
    required this.label,
    required this.amount,
    required this.color,
    required this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$prefix${CurrencyFormatter.formatNoDecimal(amount)}',
            style: AppTypography.numericSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyProjection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_graph_rounded,
            size: 48,
            color: AppColors.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Henüz projeksiyon yok',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Gelir veya gider eklerken "Periyodik" seçeneğini açarak gelecek ay tahminlerinizi görün.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
