import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';
import 'package:savvy/features/dashboard/presentation/widgets/hero_card.dart';
import 'package:savvy/features/dashboard/presentation/widgets/quick_stats_row.dart';
import 'package:savvy/features/dashboard/presentation/widgets/savings_toggle.dart';
import 'package:savvy/features/dashboard/presentation/widgets/monthly_flow_table.dart';
import 'package:savvy/features/dashboard/presentation/widgets/trend_chart.dart';

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

  static String shortMonthLabel(String yearMonth) {
    final parts = yearMonth.split('-');
    final month = int.parse(parts[1]);
    final name = _months[month];
    final short = name.length > 3 ? name.substring(0, 3) : name;
    return '$short \'${parts[0].substring(2)}';
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
    final projections = ref.watch(futureProjectionsProvider);
    final includeSavings = ref.watch(includeSavingsInProjectionProvider);
    final totalSavings = ref.watch(totalSavingsAmountProvider);

    final cumulativeNet =
        summaries.isNotEmpty ? summaries.first.netWithCarryOver : 0.0;
    final overallHealth =
        summaries.isNotEmpty ? summaries.first.healthScore : 0;
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
                  child: const Icon(LucideIcons.wallet,
                      color: Colors.white, size: 18),
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

                      // 1) Hero Card
                      HeroCard(
                        cumulativeNet: cumulativeNet,
                        healthScore: overallHealth,
                      ),

                      const SizedBox(height: AppSpacing.base),

                      // 2) Quick Stats
                      if (currentMonth != null) ...[
                        QuickStatsRow(summary: currentMonth),
                        const SizedBox(height: AppSpacing.base),
                      ],

                      // 3) Birikim toggle
                      if (totalSavings > 0) ...[
                        SavingsToggle(
                          isEnabled: includeSavings,
                          totalSavings: totalSavings,
                          onToggle: () {
                            HapticFeedback.selectionClick();
                            ref
                                .read(
                                    includeSavingsInProjectionProvider.notifier)
                                .toggle();
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],

                      // 4) Aylık Akış tablosu
                      MonthlyFlowTable(
                        summaries: summaries,
                        projections: projections,
                        includeSavings: includeSavings,
                        onMonthTap: (ym) {
                          HapticFeedback.lightImpact();
                          context.go('/dashboard/month/$ym');
                        },
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // 5) Trend grafiği
                      if (projections.isNotEmpty)
                        TrendChart(projections: projections),

                      const SizedBox(height: 100),
                    ]),
                  ),
          ),
        ],
      ),
    );
  }
}
