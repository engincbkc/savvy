import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:savvy/core/providers/repository_providers.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/features/dashboard/domain/month_summary_aggregator.dart';
import 'package:savvy/features/transactions/domain/models/income.dart';
import 'package:savvy/features/transactions/domain/models/expense.dart';
import 'package:savvy/features/savings/domain/models/savings.dart';

part 'dashboard_provider.g.dart';

@riverpod
class SelectedYearMonth extends _$SelectedYearMonth {
  @override
  String build() => DateTime.now().toYearMonth();

  void set(String yearMonth) => state = yearMonth;
}

@riverpod
Stream<List<Income>> monthIncomes(Ref ref, String yearMonth) {
  return ref.watch(incomeRepositoryProvider).watchMonthIncomes(yearMonth);
}

@riverpod
Stream<List<Expense>> monthExpenses(Ref ref, String yearMonth) {
  return ref.watch(expenseRepositoryProvider).watchMonthExpenses(yearMonth);
}

@riverpod
Stream<List<Savings>> monthSavings(Ref ref, String yearMonth) {
  return ref.watch(savingsRepositoryProvider).watchMonthSavings(yearMonth);
}

// All-time streams for multi-month overview
@riverpod
Stream<List<Income>> allIncomes(Ref ref) {
  return ref.watch(incomeRepositoryProvider).watchAll();
}

@riverpod
Stream<List<Expense>> allExpenses(Ref ref) {
  return ref.watch(expenseRepositoryProvider).watchAll();
}

@riverpod
Stream<List<Savings>> allSavings(Ref ref) {
  return ref.watch(savingsRepositoryProvider).watchAll();
}

/// All month summaries grouped by yearMonth, sorted most recent first.
/// Each summary includes carry-over from previous months.
@riverpod
List<MonthSummary> allMonthSummaries(Ref ref) {
  final allInc = ref.watch(allIncomesProvider).value ?? [];
  final allExp = ref.watch(allExpensesProvider).value ?? [];
  final allSav = ref.watch(allSavingsProvider).value ?? [];
  final includeSavings = ref.watch(includeSavingsInProjectionProvider);

  return MonthSummaryAggregator.buildSummaries(
    incomes: allInc,
    expenses: allExp,
    savings: allSav,
    includeSavings: includeSavings,
  );
}

/// Single month summary (used in detail screen)
@riverpod
MonthSummary? monthSummary(Ref ref, String yearMonth) {
  final all = ref.watch(allMonthSummariesProvider);
  final match = all.where((s) => s.yearMonth == yearMonth);
  return match.isEmpty ? null : match.first;
}

/// Toggle: include current savings as one-time income in projections.
@riverpod
class IncludeSavingsInProjection extends _$IncludeSavingsInProjection {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

/// Total savings amount across all time.
@riverpod
double totalSavingsAmount(Ref ref) {
  final allSav = ref.watch(allSavingsProvider).value ?? [];
  return allSav.fold(0.0, (sum, s) => sum + s.amount);
}

/// Future month projections based on recurring incomes/expenses.
/// Uses MonthSummaryAggregator (same engine as buildMonthlyCategoryData)
/// so dashboard and transactions screens always show consistent numbers.
@riverpod
List<MonthSummary> futureProjections(Ref ref) {
  final allInc = ref.watch(allIncomesProvider).value ?? [];
  final allExp = ref.watch(allExpensesProvider).value ?? [];
  final allSav = ref.watch(allSavingsProvider).value ?? [];
  final summaries = ref.watch(allMonthSummariesProvider);
  final includeSavings = ref.watch(includeSavingsInProjectionProvider);

  if (summaries.isEmpty) return [];

  // Get the latest cumulative balance as starting carry-over
  final latestCarryOver = summaries.first.netWithCarryOver;

  // Use the same aggregator to build all month totals, then pick
  // only the 12 future months.
  final allMonthData = MonthSummaryAggregator.buildAllMonthTotals(
    incomes: allInc,
    expenses: allExp,
    savings: allSav,
  );

  final now = DateTime.now();

  // Collect 12 future months
  double cumCarry = latestCarryOver;
  final projections = <MonthSummary>[];

  for (int m = 1; m <= 12; m++) {
    final futureDate = DateTime(now.year, now.month + m, 1);
    final ym = futureDate.toYearMonth();

    final totalIncome = allMonthData.incomeTotals[ym] ?? 0;
    final totalExpense = allMonthData.expenseTotals[ym] ?? 0;
    final monthSavings = allMonthData.savingsTotals[ym] ?? 0;

    final effectiveIncome =
        includeSavings ? totalIncome + monthSavings : totalIncome;

    final netBalance = effectiveIncome - totalExpense;
    final netWithCarry = netBalance + cumCarry;
    final savingsRate = totalIncome > 0
        ? ((totalIncome - totalExpense) / totalIncome).clamp(0.0, 1.0)
        : 0.0;
    final expenseRate =
        totalIncome > 0 ? (totalExpense / totalIncome).clamp(0.0, 2.0) : 0.0;

    projections.add(MonthSummary(
      yearMonth: ym,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      totalSavings: monthSavings,
      netBalance: netBalance,
      carryOver: cumCarry,
      netWithCarryOver: netWithCarry,
      savingsRate: savingsRate,
      expenseRate: expenseRate,
      healthScore: FinancialCalculator.financialHealthScore(
        savingsRate: savingsRate,
        expenseRatio: expenseRate,
        netBalance: netBalance,
        emergencyFundMonths: 0,
      ),
      updatedAt: DateTime.now(),
    ));

    cumCarry = netWithCarry;
  }

  return projections;
}
