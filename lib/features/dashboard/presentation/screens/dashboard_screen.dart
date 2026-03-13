import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _months = [
    '',
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  static String monthLabel(String yearMonth) {
    final parts = yearMonth.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    return '${_months[month]} $year';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allIncomesAsync = ref.watch(allIncomesProvider);
    final allExpensesAsync = ref.watch(allExpensesProvider);
    final allSavingsAsync = ref.watch(allSavingsProvider);

    final isLoading = allIncomesAsync.isLoading ||
        allExpensesAsync.isLoading ||
        allSavingsAsync.isLoading;

    final summaries = ref.watch(allMonthSummariesProvider);

    // Overall cumulative = first item (most recent month) netWithCarryOver
    final cumulativeNet =
        summaries.isNotEmpty ? summaries.first.netWithCarryOver : 0.0;
    final overallHealth =
        summaries.isNotEmpty ? summaries.first.healthScore : 0;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            title: Text(
              'Savvy',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.brandPrimary,
              ),
            ),
            centerTitle: false,
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
                            SizedBox(height: AppSpacing.lg),
                            ShimmerBox(height: 160),
                            SizedBox(height: AppSpacing.sm),
                            ShimmerBox(height: 160),
                          ],
                        ),
                      ),
                    ]),
                  )
                : SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: AppSpacing.sm),

                      // ── Overall Hero ──
                      _OverallHeroCard(
                        cumulativeNet: cumulativeNet,
                        healthScore: overallHealth,
                        monthCount: summaries.length,
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Section title ──
                      Text(
                        'Aylık Özet',
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // ── Month cards ──
                      ...summaries.map((s) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _MonthCard(
                              summary: s,
                              monthLabel: monthLabel(s.yearMonth),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                context.go('/dashboard/month/${s.yearMonth}');
                              },
                            ),
                          )),

                      const SizedBox(height: AppSpacing.xl5),
                    ]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Overall Hero Card ──────────────────────────────────────────────────────

class _OverallHeroCard extends StatelessWidget {
  final double cumulativeNet;
  final int healthScore;
  final int monthCount;

  const _OverallHeroCard({
    required this.cumulativeNet,
    required this.healthScore,
    required this.monthCount,
  });

  List<Color> get _gradient {
    if (cumulativeNet > 0) {
      return [const Color(0xFF064E3B), const Color(0xFF059669)];
    } else if (cumulativeNet < 0) {
      return [const Color(0xFF7F1D1D), const Color(0xFFDC2626)];
    } else {
      return [AppColors.brandPrimaryDim, AppColors.brandPrimary];
    }
  }

  String get _healthLabel => FinancialCalculator.healthScoreLabel(healthScore);

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
          // Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOPLAM BAKİYE',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textInverse.withValues(alpha: 0.7),
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textInverse.withValues(alpha: 0.15),
                  borderRadius: AppRadius.pill,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _HealthIcon(score: healthScore, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$_healthLabel · $healthScore',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textInverse,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Big number
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: cumulativeNet),
            duration: AppDuration.countUp,
            curve: AppCurve.decelerate,
            builder: (context, value, child) => Text(
              CurrencyFormatter.formatNoDecimal(value),
              style: AppTypography.numericHero.copyWith(
                color: AppColors.textInverse,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            'Tüm zamanların kümülatif bakiyesi',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textInverse.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Month Card ─────────────────────────────────────────────────────────────

class _MonthCard extends StatelessWidget {
  final MonthSummary summary;
  final String monthLabel;
  final VoidCallback onTap;

  const _MonthCard({
    required this.summary,
    required this.monthLabel,
    required this.onTap,
  });

  Color get _netColor =>
      summary.netBalance >= 0 ? AppColors.income : AppColors.expense;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.card,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.card,
          boxShadow: AppShadow.sm,
          border: Border.all(
            color: AppColors.borderDefault.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: Month name + health badge + arrow
            Row(
              children: [
                // Month icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: summary.netBalance >= 0
                          ? [
                              const Color(0xFF059669),
                              const Color(0xFF10B981),
                            ]
                          : [
                              const Color(0xFFDC2626),
                              const Color(0xFFEF4444),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppRadius.chip,
                  ),
                  child: Icon(
                    summary.netBalance >= 0
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: AppColors.textInverse,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        monthLabel,
                        style: AppTypography.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          _HealthIcon(
                              score: summary.healthScore, size: 12),
                          const SizedBox(width: 3),
                          Text(
                            'Sağlık: ${summary.healthScore}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                  size: 24,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.base),

            // Financial summary grid
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Gelir',
                    amount: summary.totalIncome,
                    color: AppColors.income,
                    prefix: '+',
                  ),
                ),
                Expanded(
                  child: _MiniStat(
                    label: 'Gider',
                    amount: summary.totalExpense,
                    color: AppColors.expense,
                    prefix: '-',
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Aylık Net',
                    amount: summary.netBalance,
                    color: _netColor,
                    prefix: summary.netBalance >= 0 ? '+' : '',
                  ),
                ),
                Expanded(
                  child: _MiniStat(
                    label: 'Birikim',
                    amount: summary.totalSavings,
                    color: AppColors.savings,
                    prefix: '',
                  ),
                ),
              ],
            ),

            // Carry-over info
            if (summary.carryOver != 0) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.06),
                  borderRadius: AppRadius.chip,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.replay_rounded,
                      size: 14,
                      color: AppColors.brandPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Devir: ${CurrencyFormatter.formatNoDecimal(summary.carryOver)}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.brandPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '→ Kümülatif: ${CurrencyFormatter.formatNoDecimal(summary.netWithCarryOver)}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Mini Stat (used in month card) ─────────────────────────────────────────

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
    return Column(
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
    );
  }
}

// ─── Health Icon helper ─────────────────────────────────────────────────────

class _HealthIcon extends StatelessWidget {
  final int score;
  final double size;

  const _HealthIcon({required this.score, required this.size});

  @override
  Widget build(BuildContext context) {
    final icon = switch (score) {
      >= 80 => Icons.rocket_launch_rounded,
      >= 65 => Icons.trending_up_rounded,
      >= 50 => Icons.horizontal_rule_rounded,
      >= 35 => Icons.trending_down_rounded,
      _ => Icons.warning_rounded,
    };
    final color = switch (score) {
      >= 80 => AppColors.income,
      >= 65 => AppColors.brandPrimary,
      >= 50 => AppColors.warning,
      >= 35 => AppColors.savings,
      _ => AppColors.expense,
    };
    return Icon(icon, size: size, color: color);
  }
}
