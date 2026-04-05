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
