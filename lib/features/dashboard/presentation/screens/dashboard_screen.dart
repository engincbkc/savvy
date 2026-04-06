import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';
import 'package:savvy/features/dashboard/presentation/widgets/greeting_header.dart';
import 'package:savvy/features/dashboard/presentation/widgets/wallet_widget.dart';
import 'package:savvy/features/dashboard/presentation/widgets/savings_toggle.dart';
import 'package:savvy/features/dashboard/presentation/widgets/monthly_flow_table.dart';
import 'package:savvy/features/dashboard/presentation/widgets/trend_chart.dart';
import 'package:savvy/features/dashboard/presentation/widgets/goals_summary.dart';
import 'package:savvy/features/savings_goals/presentation/providers/goals_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final allIncomesAsync = ref.watch(allIncomesProvider);
    final allExpensesAsync = ref.watch(allExpensesProvider);
    final allSavingsAsync = ref.watch(allSavingsProvider);

    final isLoading = allIncomesAsync.isLoading ||
        allExpensesAsync.isLoading ||
        allSavingsAsync.isLoading;

    final allIncomes = allIncomesAsync.value ?? [];
    final allExpenses = allExpensesAsync.value ?? [];
    final hasData = allIncomes.isNotEmpty || allExpenses.isNotEmpty;

    final summaries = ref.watch(allMonthSummariesProvider);
    final projections = ref.watch(futureProjectionsProvider);
    final includeSavings = ref.watch(includeSavingsInProjectionProvider);
    final totalSavings = ref.watch(totalSavingsAmountProvider);

    final goals = ref.watch(allGoalsProvider).value ?? [];

    final cumulativeNet =
        summaries.isNotEmpty ? summaries.first.netWithCarryOver : 0.0;
    final currentMonth = summaries.isNotEmpty ? summaries.first : null;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: AppSpacing.screenH,
            sliver: isLoading
                ? SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: AppSpacing.base),
                      const SavvyShimmer(
                        child: Column(
                          children: [
                            ShimmerBox(height: 180),
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
                : !hasData
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: _DashboardEmptyState(),
                      )
                    : SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: AppSpacing.lg),

                      // 1) Greeting Header
                      _StaggeredEntry(
                        delay: 0,
                        child: const GreetingHeader(),
                      ),

                      const SizedBox(height: AppSpacing.base),

                      // 2) Wallet
                      _StaggeredEntry(
                        delay: 100,
                        child: WalletWidget(
                          cumulativeNet: cumulativeNet,
                          currentMonth: currentMonth,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.base),

                      // 3) Birikim toggle
                      if (totalSavings > 0) ...[
                        _StaggeredEntry(
                          delay: 200,
                          child: SavingsToggle(
                            isEnabled: includeSavings,
                            totalSavings: totalSavings,
                            onToggle: () {
                              HapticFeedback.selectionClick();
                              ref
                                  .read(includeSavingsInProjectionProvider
                                      .notifier)
                                  .toggle();
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],

                      // 4) Aylık Akış tablosu
                      _StaggeredEntry(
                        delay: 300,
                        child: MonthlyFlowTable(
                          summaries: summaries,
                          projections: projections,
                          includeSavings: includeSavings,
                          nearestGoalTarget: goals.isNotEmpty
                              ? goals
                                  .where((g) => g.status.name == 'active')
                                  .fold<double?>(null, (nearest, g) {
                                    if (nearest == null) return g.targetAmount;
                                    return g.targetAmount < nearest
                                        ? g.targetAmount
                                        : nearest;
                                  })
                              : null,
                          onMonthTap: (ym) {
                            HapticFeedback.lightImpact();
                            context.go('/dashboard/month/$ym');
                          },
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // 5) Hedefler özeti
                      if (goals.isNotEmpty) ...[
                        _StaggeredEntry(
                          delay: 400,
                          child: GoalsSummary(goals: goals),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],

                      // 6) Trend grafiği
                      if (projections.isNotEmpty)
                        _StaggeredEntry(
                          delay: 500,
                          child: TrendChart(
                            projections: projections,
                            goalTargets: goals
                                .where((g) => g.status.name == 'active')
                                .map((g) => g.targetAmount)
                                .toList(),
                          ),
                        ),

                      // 7) Nakit Akış Tahmini entry
                      if (projections.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xl),
                        _StaggeredEntry(
                          delay: 600,
                          child: _ForecastEntryCard(),
                        ),
                      ],

                      const SizedBox(height: 100),
                    ]),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Empty state shown when user has no income or expenses yet.
class _DashboardEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl2),
          const GreetingHeader(),
          const Spacer(),
          // Glassmorphism card
          ClipRRect(
            borderRadius: AppRadius.cardLg,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: c.surfaceCard.withValues(alpha: 0.6),
                  borderRadius: AppRadius.cardLg,
                  border: Border.all(
                    color: c.borderDefault.withValues(alpha: 0.3),
                  ),
                  boxShadow: AppShadow.sm,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: c.brandPrimary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.wallet,
                        size: 28,
                        color: c.brandPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    Text(
                      'Henüz gelir veya gideriniz\nbulunmamaktadır',
                      style: AppTypography.titleMedium.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'İlk işleminizi ekleyerek finansal takibinizi başlatın.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: c.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: _EmptyStateButton(
                            label: 'Gelir Ekle',
                            icon: LucideIcons.trendingUp,
                            color: c.income,
                            onTap: () => context.go('/transactions?tab=0'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _EmptyStateButton(
                            label: 'Gider Ekle',
                            icon: LucideIcons.trendingDown,
                            color: c.expense,
                            onTap: () => context.go('/transactions?tab=1'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _EmptyStateButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _EmptyStateButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.base,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: AppRadius.card,
          border: Border.all(
            color: color.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tappable card that navigates to the 12-month cash flow forecast screen.
class _ForecastEntryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.go('/dashboard/forecast');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: c.brandPrimary.withValues(alpha: 0.07),
          borderRadius: AppRadius.card,
          border: Border.all(
            color: c.brandPrimary.withValues(alpha: 0.18),
          ),
          boxShadow: AppShadow.xs,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c.brandPrimary.withValues(alpha: 0.12),
                borderRadius: AppRadius.chip,
              ),
              child: Icon(
                LucideIcons.trendingUp,
                size: 18,
                color: c.brandPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Gelecek 12 Ay',
                    style: AppTypography.titleSmall.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Nakit akış tahmini ve kümülatif projeksiyon',
                    style: AppTypography.caption.copyWith(
                      color: c.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: c.brandPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Staggered entrance animation for dashboard sections.
class _StaggeredEntry extends StatelessWidget {
  final int delay;
  final Widget child;

  const _StaggeredEntry({
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final adjusted =
            ((value * (600 + delay) - delay) / 600).clamp(0.0, 1.0);
        return Opacity(
          opacity: adjusted,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - adjusted)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
