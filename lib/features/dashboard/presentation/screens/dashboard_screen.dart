import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
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

    final cumulativeNet =
        summaries.isNotEmpty ? summaries.first.netWithCarryOver : 0.0;
    final overallHealth =
        summaries.isNotEmpty ? summaries.first.healthScore : 0;

    // Current month summary for quick stats
    final currentMonth = summaries.isNotEmpty ? summaries.first : null;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.surfaceBackground,
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A56DB), Color(0xFF3F83F8)],
                    ),
                    borderRadius: AppRadius.chip,
                  ),
                  child: const Icon(LucideIcons.wallet, color: Colors.white, size: 18),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Savvy',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.brandPrimary,
                  ),
                ),
              ],
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
                            ShimmerBox(height: 170),
                            SizedBox(height: AppSpacing.base),
                            ShimmerBox(height: 80),
                            SizedBox(height: AppSpacing.base),
                            ShimmerBox(height: 60),
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

                      // Hero Card
                      _OverallHeroCard(
                        cumulativeNet: cumulativeNet,
                        healthScore: overallHealth,
                        monthCount: summaries.length,
                      ),

                      const SizedBox(height: AppSpacing.base),

                      // Quick Stats Row (current month)
                      if (currentMonth != null) ...[
                        _QuickStatsRow(summary: currentMonth),
                        const SizedBox(height: AppSpacing.base),
                      ],

                      // Future Projection
                      _FutureProjectionCard(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.go('/dashboard/projections');
                        },
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Section header
                      Row(
                        children: [
                          Text(
                            'Aylık Özet',
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceOverlay,
                              borderRadius: AppRadius.pill,
                            ),
                            child: Text(
                              '${summaries.length} ay',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Month cards
                      ...summaries.map((s) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _MonthCard(
                              summary: s,
                              monthLabel: monthLabel(s.yearMonth),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                context.go('/dashboard/month/${s.yearMonth}');
                              },
                            ),
                          )),

                      const SizedBox(height: 100),
                    ]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Stats Row ────────────────────────────────────────────────────────

class _QuickStatsRow extends StatelessWidget {
  final MonthSummary summary;
  const _QuickStatsRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickStatCard(
            label: 'Gelir',
            amount: summary.totalIncome,
            color: AppColors.income,
            icon: AppIcons.income,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickStatCard(
            label: 'Gider',
            amount: summary.totalExpense,
            color: AppColors.expense,
            icon: AppIcons.expense,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickStatCard(
            label: 'Birikim',
            amount: summary.totalSavings,
            color: AppColors.savings,
            icon: AppIcons.savings,
          ),
        ),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _QuickStatCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.input,
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
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
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            CurrencyFormatter.formatNoDecimal(amount),
            style: AppTypography.numericSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOPLAM BAKIYE',
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

          const SizedBox(height: AppSpacing.xl),

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
          border: Border.all(
            color: AppColors.borderDefault.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: summary.netBalance >= 0
                          ? [const Color(0xFF059669), const Color(0xFF10B981)]
                          : [const Color(0xFFDC2626), const Color(0xFFEF4444)],
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
                      Text(monthLabel,
                          style: AppTypography.titleLarge
                              .copyWith(color: AppColors.textPrimary)),
                      Row(
                        children: [
                          _HealthIcon(score: summary.healthScore, size: 12),
                          const SizedBox(width: 3),
                          Text('Sağlık: ${summary.healthScore}',
                              style: AppTypography.caption
                                  .copyWith(color: AppColors.textTertiary)),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.textTertiary, size: 24),
              ],
            ),

            const SizedBox(height: AppSpacing.base),

            // Stats grid
            Row(
              children: [
                Expanded(
                    child: _MiniStat(
                        label: 'Gelir',
                        amount: summary.totalIncome,
                        color: AppColors.income,
                        prefix: '+')),
                Expanded(
                    child: _MiniStat(
                        label: 'Gider',
                        amount: summary.totalExpense,
                        color: AppColors.expense,
                        prefix: '-')),
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
                        prefix: summary.netBalance >= 0 ? '+' : '')),
                Expanded(
                    child: _MiniStat(
                        label: 'Birikim',
                        amount: summary.totalSavings,
                        color: AppColors.savings,
                        prefix: '')),
              ],
            ),

            // Carry-over
            if (summary.carryOver != 0) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.06),
                  borderRadius: AppRadius.chip,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.replay_rounded,
                        size: 14, color: AppColors.brandPrimary),
                    const SizedBox(width: 4),
                    Text(
                      'Devir: ${CurrencyFormatter.formatNoDecimal(summary.carryOver)}',
                      style: AppTypography.caption.copyWith(
                          color: AppColors.brandPrimary,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        '→ Kümülatif: ${CurrencyFormatter.formatNoDecimal(summary.netWithCarryOver)}',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
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

class _MiniStat extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final String prefix;

  const _MiniStat(
      {required this.label,
      required this.amount,
      required this.color,
      required this.prefix});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppTypography.caption.copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: 2),
        Text('$prefix${CurrencyFormatter.formatNoDecimal(amount)}',
            style: AppTypography.numericSmall
                .copyWith(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

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

class _FutureProjectionCard extends StatelessWidget {
  final VoidCallback onTap;
  const _FutureProjectionCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.card,
          boxShadow: AppShadow.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: AppRadius.chip,
              ),
              child:
                  const Icon(LucideIcons.eye, color: Colors.white, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gelecek Tahminim',
                    style: AppTypography.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Periyodik gelir/giderlerine göre 6 aylık projeksiyon',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.7), size: 24),
          ],
        ),
      ),
    );
  }
}
