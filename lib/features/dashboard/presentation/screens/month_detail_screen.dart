import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';

class MonthDetailScreen extends ConsumerWidget {
  final String yearMonth;

  const MonthDetailScreen({super.key, required this.yearMonth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(monthSummaryProvider(yearMonth));
    final incomesAsync = ref.watch(monthIncomesProvider(yearMonth));
    final expensesAsync = ref.watch(monthExpensesProvider(yearMonth));
    final savingsAsync = ref.watch(monthSavingsProvider(yearMonth));

    final label = DashboardScreen.monthLabel(yearMonth);

    return SafeArea(
      child: summary == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  title: Text(
                    label,
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  centerTitle: false,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    onPressed: () => context.go('/dashboard'),
                  ),
                ),
                SliverPadding(
                  padding: AppSpacing.screenH,
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: AppSpacing.sm),

                  // ── Cumulative Balance Hero ──
                  _DetailHeroCard(
                    netWithCarryOver: summary.netWithCarryOver,
                    netBalance: summary.netBalance,
                    carryOver: summary.carryOver,
                    healthScore: summary.healthScore,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Gelir / Gider / Birikim breakdown ──
                  _BreakdownSection(
                    totalIncome: summary.totalIncome,
                    totalExpense: summary.totalExpense,
                    totalSavings: summary.totalSavings,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Rates & Progress ──
                  _RatesCard(
                    savingsRate: summary.savingsRate,
                    expenseRate: summary.expenseRate,
                    healthScore: summary.healthScore,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Transactions ──
                  Text(
                    'İşlemler',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  _MonthTransactions(
                    incomesAsync: incomesAsync,
                    expensesAsync: expensesAsync,
                    savingsAsync: savingsAsync,
                  ),

                      const SizedBox(height: AppSpacing.xl5),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }
}

// ─── Detail Hero Card ───────────────────────────────────────────────────────

class _DetailHeroCard extends StatelessWidget {
  final double netWithCarryOver;
  final double netBalance;
  final double carryOver;
  final int healthScore;

  const _DetailHeroCard({
    required this.netWithCarryOver,
    required this.netBalance,
    required this.carryOver,
    required this.healthScore,
  });

  List<Color> get _gradient {
    if (netWithCarryOver > 0) {
      return [const Color(0xFF064E3B), const Color(0xFF059669)];
    } else if (netWithCarryOver < 0) {
      return [const Color(0xFF7F1D1D), const Color(0xFFDC2626)];
    } else {
      return [AppColors.brandPrimaryDim, AppColors.brandPrimary];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.cardLg,
        boxShadow: AppShadow.hero,
      ),
      child: Column(
        children: [
          // Label
          Text(
            'KÜMÜLATİF BAKİYE',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textInverse.withValues(alpha: 0.7),
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Big number
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: netWithCarryOver),
            duration: AppDuration.countUp,
            curve: AppCurve.decelerate,
            builder: (context, value, child) => Text(
              CurrencyFormatter.formatNoDecimal(value),
              style: AppTypography.numericHero.copyWith(
                color: AppColors.textInverse,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Breakdown row
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.textInverse.withValues(alpha: 0.1),
              borderRadius: AppRadius.chip,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _HeroStat(
                  label: 'Aylık Net',
                  value: CurrencyFormatter.formatNoDecimal(netBalance),
                  color: netBalance >= 0
                      ? const Color(0xFF86EFAC)
                      : const Color(0xFFFCA5A5),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: AppColors.textInverse.withValues(alpha: 0.2),
                ),
                _HeroStat(
                  label: 'Devir',
                  value: CurrencyFormatter.formatNoDecimal(carryOver),
                  color: carryOver >= 0
                      ? const Color(0xFF86EFAC)
                      : const Color(0xFFFCA5A5),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: AppColors.textInverse.withValues(alpha: 0.2),
                ),
                _HeroStat(
                  label: 'Sağlık',
                  value: '$healthScore',
                  color: AppColors.textInverse,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HeroStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textInverse.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.numericSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─── Breakdown Section ──────────────────────────────────────────────────────

class _BreakdownSection extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double totalSavings;

  const _BreakdownSection({
    required this.totalIncome,
    required this.totalExpense,
    required this.totalSavings,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BreakdownCard(
            icon: AppIcons.income,
            label: 'Gelir',
            amount: totalIncome,
            color: AppColors.income,
            bgColor: AppColors.incomeSurface,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _BreakdownCard(
            icon: AppIcons.expense,
            label: 'Gider',
            amount: totalExpense,
            color: AppColors.expense,
            bgColor: AppColors.expenseSurface,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _BreakdownCard(
            icon: AppIcons.savings,
            label: 'Birikim',
            amount: totalSavings,
            color: AppColors.savings,
            bgColor: AppColors.savingsSurface,
          ),
        ),
      ],
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  final Color bgColor;

  const _BreakdownCard({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadius.chip,
            ),
            child: Icon(icon, color: AppColors.textInverse, size: 16),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.formatNoDecimal(amount),
              style: AppTypography.numericMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Rates Card ─────────────────────────────────────────────────────────────

class _RatesCard extends StatelessWidget {
  final double savingsRate;
  final double expenseRate;
  final int healthScore;

  const _RatesCard({
    required this.savingsRate,
    required this.expenseRate,
    required this.healthScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.card,
        boxShadow: AppShadow.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Finansal Oranlar',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // Savings rate
          _ProgressRow(
            label: 'Tasarruf Oranı',
            value: savingsRate,
            color: AppColors.savings,
            target: 0.20,
            hint: 'Hedef: ≥%20',
          ),

          const SizedBox(height: AppSpacing.lg),

          // Expense rate
          _ProgressRow(
            label: 'Harcama Oranı',
            value: expenseRate.clamp(0.0, 1.0),
            color: expenseRate > 0.80
                ? AppColors.expense
                : expenseRate > 0.60
                    ? AppColors.warning
                    : AppColors.income,
            target: 0.70,
            hint: 'Hedef: ≤%70',
          ),

          const SizedBox(height: AppSpacing.lg),

          // Health score bar
          _HealthScoreBar(score: healthScore),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final double target;
  final String hint;

  const _ProgressRow({
    required this.label,
    required this.value,
    required this.color,
    required this.target,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              CurrencyFormatter.percent(value),
              style: AppTypography.numericSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: AppRadius.pill,
          child: Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.surfaceOverlay,
                ),
              ),
              AnimatedContainer(
                duration: AppDuration.slow,
                curve: AppCurve.decelerate,
                height: 10,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hint,
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _HealthScoreBar extends StatelessWidget {
  final int score;

  const _HealthScoreBar({required this.score});

  @override
  Widget build(BuildContext context) {
    final label = FinancialCalculator.healthScoreLabel(score);
    final color = switch (score) {
      >= 80 => AppColors.income,
      >= 65 => AppColors.brandPrimary,
      >= 50 => AppColors.warning,
      >= 35 => AppColors.savings,
      _ => AppColors.expense,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Finansal Sağlık',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppRadius.pill,
              ),
              child: Text(
                '$label · $score/100',
                style: AppTypography.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: AppRadius.pill,
          child: Stack(
            children: [
              Container(
                height: 10,
                color: AppColors.surfaceOverlay,
              ),
              AnimatedContainer(
                duration: AppDuration.slow,
                curve: AppCurve.decelerate,
                height: 10,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: (score / 100.0).clamp(0.0, 1.0),
                  child: Container(color: color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Month Transactions ─────────────────────────────────────────────────────

class _MonthTransactions extends StatelessWidget {
  final AsyncValue<List<dynamic>> incomesAsync;
  final AsyncValue<List<dynamic>> expensesAsync;
  final AsyncValue<List<dynamic>> savingsAsync;

  const _MonthTransactions({
    required this.incomesAsync,
    required this.expensesAsync,
    required this.savingsAsync,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = incomesAsync.isLoading ||
        expensesAsync.isLoading ||
        savingsAsync.isLoading;

    if (isLoading) {
      return const SavvyShimmer(
        child: Column(
          children: [
            ShimmerBox(height: 56),
            SizedBox(height: AppSpacing.xs),
            ShimmerBox(height: 56),
            SizedBox(height: AppSpacing.xs),
            ShimmerBox(height: 56),
          ],
        ),
      );
    }

    final incomes = incomesAsync.value ?? [];
    final expenses = expensesAsync.value ?? [];
    final savings = savingsAsync.value ?? [];

    final allItems = <_TxItem>[
      ...incomes.map((i) => _TxItem(
            title: i.category.label,
            note: i.note,
            amount: i.amount,
            type: _TxType.income,
            date: i.date,
          )),
      ...expenses.map((e) => _TxItem(
            title: e.category.label,
            note: e.note,
            amount: e.amount,
            type: _TxType.expense,
            date: e.date,
          )),
      ...savings.map((s) => _TxItem(
            title: s.category.label,
            note: s.note,
            amount: s.amount,
            type: _TxType.savings,
            date: s.date,
          )),
    ]..sort((a, b) => b.date.compareTo(a.date));

    if (allItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl2),
        child: Center(
          child: Text(
            'Bu ay henüz işlem yok',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
      );
    }

    return Column(
      children: allItems.map((item) {
        final iconColor = switch (item.type) {
          _TxType.income => AppColors.income,
          _TxType.expense => AppColors.expense,
          _TxType.savings => AppColors.savings,
        };
        final icon = switch (item.type) {
          _TxType.income => AppIcons.income,
          _TxType.expense => AppIcons.expense,
          _TxType.savings => AppIcons.savings,
        };
        final prefix = switch (item.type) {
          _TxType.income => '+',
          _TxType.expense => '-',
          _TxType.savings => '',
        };

        final dateStr =
            '${item.date.day.toString().padLeft(2, '0')}.${item.date.month.toString().padLeft(2, '0')}.${item.date.year}';

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
          padding: AppSpacing.listTile,
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: AppRadius.card,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(icon, color: AppColors.textInverse, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      item.note != null
                          ? '$dateStr · ${item.note}'
                          : dateStr,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                '$prefix${CurrencyFormatter.formatNoDecimal(item.amount)}',
                style: AppTypography.numericSmall.copyWith(
                  color: iconColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

enum _TxType { income, expense, savings }

class _TxItem {
  final String title;
  final String? note;
  final double amount;
  final _TxType type;
  final DateTime date;

  _TxItem({
    required this.title,
    this.note,
    required this.amount,
    required this.type,
    required this.date,
  });
}
