import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/features/dashboard/presentation/widgets/detail_hero_card.dart';
import 'package:savvy/features/dashboard/presentation/widgets/breakdown_section.dart';
import 'package:savvy/features/dashboard/presentation/widgets/month_transactions.dart';

class MonthDetailScreen extends ConsumerWidget {
  final String yearMonth;

  const MonthDetailScreen({super.key, required this.yearMonth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(monthSummaryProvider(yearMonth));
    final incomesAsync = ref.watch(monthIncomesProvider(yearMonth));
    final expensesAsync = ref.watch(monthExpensesProvider(yearMonth));
    final savingsAsync = ref.watch(monthSavingsProvider(yearMonth));

    final label = MonthLabels.full(yearMonth);

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
                      color: AppColors.of(context).textPrimary,
                    ),
                  ),
                  centerTitle: false,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    onPressed: () => context.go('/dashboard'),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        LucideIcons.gitCompare,
                        color: AppColors.of(context).textSecondary,
                        size: 20,
                      ),
                      tooltip: 'Ay Karşılaştır',
                      onPressed: () => context.push(
                        '/dashboard/compare?month=$yearMonth',
                      ),
                    ),
                  ],
                ),
                SliverPadding(
                  padding: AppSpacing.screenH,
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: AppSpacing.sm),

                  // ── Cumulative Balance Hero ──
                  DetailHeroCard(
                    netWithCarryOver: summary.netWithCarryOver,
                    netBalance: summary.netBalance,
                    carryOver: summary.carryOver,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Gelir / Gider / Birikim breakdown ──
                  BreakdownSection(
                    totalIncome: summary.totalIncome,
                    totalExpense: summary.totalExpense,
                    totalSavings: summary.totalSavings,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Transactions ──
                  Text(
                    'İşlemler',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.of(context).textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  MonthTransactions(
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
