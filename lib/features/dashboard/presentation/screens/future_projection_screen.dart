import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/dashboard/presentation/screens/dashboard_screen.dart';

class FutureProjectionScreen extends ConsumerWidget {
  const FutureProjectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projections = ref.watch(futureProjectionsProvider);
    final summaries = ref.watch(allMonthSummariesProvider);
    final currentBalance =
        summaries.isNotEmpty ? summaries.first.netWithCarryOver : 0.0;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text(
              'Gelecek Tahminim',
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

                // Info card
                _InfoCard(currentBalance: currentBalance),

                const SizedBox(height: AppSpacing.lg),

                if (projections.isEmpty) ...[
                  const SizedBox(height: AppSpacing.xl2),
                  _EmptyState(),
                ] else ...[
                  // Projection trend chart
                  _TrendCard(
                    projections: projections,
                    currentBalance: currentBalance,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Section title
                  Text(
                    'Aylık Projeksiyon',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Month projection cards
                  ...projections.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _ProjectionCard(
                          summary: p,
                          label: DashboardScreen.monthLabel(p.yearMonth),
                        ),
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

// ─── Info Card ───────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final double currentBalance;

  const _InfoCard({required this.currentBalance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.cardLg,
        boxShadow: AppShadow.hero,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(
                  LucideIcons.eye,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Finansal Projeksiyon',
                      style: AppTypography.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '6 aylık tahmini gelecek gorunumun',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: AppRadius.chip,
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.info,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Periyodik gelir ve giderlerine gore hesaplanir. '
                    'Tek seferlik gelecek islemler de dahildir.',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
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

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.brandLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.calendarOff,
              size: 36,
              color: AppColors.brandPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Henuz projeksiyon yok',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
            child: Text(
              'Periyodik gelir veya gider eklediginde gelecek ayların tahmini burada gozukecek.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Trend Card (mini chart) ─────────────────────────────────────────────────

class _TrendCard extends StatelessWidget {
  final List<MonthSummary> projections;
  final double currentBalance;

  const _TrendCard({
    required this.projections,
    required this.currentBalance,
  });

  @override
  Widget build(BuildContext context) {
    final endBalance = projections.last.netWithCarryOver;
    final diff = endBalance - currentBalance;
    final isPositive = diff >= 0;

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
            '6 Ay Sonra Tahmini Bakiye',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: endBalance),
            duration: AppDuration.countUp,
            curve: AppCurve.decelerate,
            builder: (context, value, child) => Text(
              CurrencyFormatter.formatNoDecimal(value),
              style: AppTypography.numericHero.copyWith(
                color: endBalance >= 0 ? AppColors.income : AppColors.expense,
                fontSize: 32,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Diff badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isPositive
                  ? AppColors.incomeSurface
                  : AppColors.expenseSurface,
              borderRadius: AppRadius.pill,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive
                      ? LucideIcons.trendingUp
                      : LucideIcons.trendingDown,
                  size: 14,
                  color: isPositive ? AppColors.income : AppColors.expense,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isPositive ? '+' : ''}${CurrencyFormatter.formatNoDecimal(diff)} bugunle kıyasla',
                  style: AppTypography.caption.copyWith(
                    color: isPositive ? AppColors.income : AppColors.expense,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Mini bar chart
          _MiniBarChart(projections: projections),
        ],
      ),
    );
  }
}

// ─── Mini Bar Chart ──────────────────────────────────────────────────────────

class _MiniBarChart extends StatelessWidget {
  final List<MonthSummary> projections;

  const _MiniBarChart({required this.projections});

  @override
  Widget build(BuildContext context) {
    if (projections.isEmpty) return const SizedBox.shrink();

    final maxVal = projections
        .map((p) => p.netWithCarryOver.abs())
        .reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: projections.map((p) {
          final ratio =
              maxVal > 0 ? (p.netWithCarryOver.abs() / maxVal) : 0.0;
          final isPositive = p.netWithCarryOver >= 0;
          final monthName = DashboardScreen.monthLabel(p.yearMonth).split(' ')[0];
          // First 3 chars
          final shortMonth =
              monthName.length > 3 ? monthName.substring(0, 3) : monthName;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.compact(p.netWithCarryOver),
                    style: AppTypography.caption.copyWith(
                      color: isPositive ? AppColors.income : AppColors.expense,
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: AppDuration.slow,
                    curve: AppCurve.decelerate,
                    height: (80 * ratio).clamp(8.0, 80.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isPositive
                            ? [
                                AppColors.income.withValues(alpha: 0.6),
                                AppColors.income,
                              ]
                            : [
                                AppColors.expense.withValues(alpha: 0.6),
                                AppColors.expense,
                              ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shortMonth,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Projection Card ─────────────────────────────────────────────────────────

class _ProjectionCard extends StatelessWidget {
  final MonthSummary summary;
  final String label;

  const _ProjectionCard({
    required this.summary,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = summary.netBalance >= 0;

    return Container(
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
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(
                  LucideIcons.calendar,
                  color: const Color(0xFF2563EB),
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
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                            borderRadius: AppRadius.pill,
                          ),
                          child: Text(
                            'Tahmini',
                            style: AppTypography.caption.copyWith(
                              color: const Color(0xFF2563EB),
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Saglık: ${summary.healthScore}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Net badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppColors.incomeSurface
                      : AppColors.expenseSurface,
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  '${isPositive ? '+' : ''}${CurrencyFormatter.formatNoDecimal(summary.netBalance)}',
                  style: AppTypography.numericSmall.copyWith(
                    color: isPositive ? AppColors.income : AppColors.expense,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.base),

          // Gelir / Gider row
          Row(
            children: [
              Expanded(
                child: _ProjStat(
                  icon: LucideIcons.trendingUp,
                  label: 'Tahmini Gelir',
                  amount: summary.totalIncome,
                  color: AppColors.income,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ProjStat(
                  icon: LucideIcons.trendingDown,
                  label: 'Tahmini Gider',
                  amount: summary.totalExpense,
                  color: AppColors.expense,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Cumulative row
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: summary.netWithCarryOver >= 0
                  ? AppColors.incomeSurfaceDim
                  : AppColors.expenseSurfaceDim,
              borderRadius: AppRadius.chip,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.wallet,
                      size: 16,
                      color: summary.netWithCarryOver >= 0
                          ? AppColors.income
                          : AppColors.expense,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Kumulatif Bakiye',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  CurrencyFormatter.formatNoDecimal(summary.netWithCarryOver),
                  style: AppTypography.numericSmall.copyWith(
                    color: summary.netWithCarryOver >= 0
                        ? AppColors.income
                        : AppColors.expense,
                    fontWeight: FontWeight.w700,
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

class _ProjStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;

  const _ProjStat({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: AppRadius.chip,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.formatNoDecimal(amount),
              style: AppTypography.numericSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
