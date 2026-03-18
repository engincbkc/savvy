import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/simulation/presentation/widgets/recurring_summary_card.dart';
import 'package:savvy/features/simulation/presentation/widgets/simulation_trend_chart.dart';
import 'package:savvy/features/simulation/presentation/widgets/simulation_projection_card.dart';
import 'package:savvy/features/simulation/presentation/widgets/empty_projection.dart';

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
                color: AppColors.of(context).brandPrimary,
              ),
            ),
            centerTitle: false,
          ),
          SliverPadding(
            padding: AppSpacing.screenH,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSpacing.sm),

                // Recurring summary card
                RecurringSummaryCard(
                  recurringIncomeCount: recurringIncomes.length,
                  recurringExpenseCount: recurringExpenses.length,
                  totalRecurringIncome: totalRecurringIncome,
                  totalRecurringExpense: totalRecurringExpense,
                ),

                const SizedBox(height: AppSpacing.xl),

                // Section title
                Row(
                  children: [
                    Icon(Icons.auto_graph_rounded,
                        size: 20, color: AppColors.of(context).brandPrimary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Önümüzdeki 6 Ay',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.of(context).textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Periyodik gelir ve giderlerine göre tahmini projeksiyon',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.of(context).textTertiary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                if (projections.isEmpty)
                  const EmptyProjection()
                else ...[
                  // Trend chart
                  SimulationTrendChart(projections: projections),
                  const SizedBox(height: AppSpacing.lg),

                  // Month projection cards
                  ...projections.map((p) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.md),
                        child: SimulationProjectionCard(projection: p),
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
