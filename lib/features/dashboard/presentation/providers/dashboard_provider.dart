import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:savvy/core/providers/repository_providers.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
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

  if (allInc.isEmpty && allExp.isEmpty && allSav.isEmpty) return [];

  // Collect all unique yearMonths
  final yearMonths = <String>{};
  for (final i in allInc) {
    yearMonths.add(i.date.toYearMonth());
  }
  for (final e in allExp) {
    yearMonths.add(e.date.toYearMonth());
  }
  for (final s in allSav) {
    yearMonths.add(s.date.toYearMonth());
  }
  // Also add current month even if empty
  yearMonths.add(DateTime.now().toYearMonth());

  // Sort chronologically
  final sorted = yearMonths.toList()..sort();

  // Calculate summaries with cumulative carry-over
  double cumulativeCarryOver = 0;
  final summaries = <MonthSummary>[];

  for (final ym in sorted) {
    final range = YearMonthRange.from(ym);

    final monthIncomeList = allInc.where(
      (i) =>
          !i.date.toUtc().isBefore(range.start) &&
          i.date.toUtc().isBefore(range.end),
    );
    final monthExpenseList = allExp.where(
      (e) =>
          !e.date.toUtc().isBefore(range.start) &&
          e.date.toUtc().isBefore(range.end),
    );
    final monthSavingsList = allSav.where(
      (s) =>
          !s.date.toUtc().isBefore(range.start) &&
          s.date.toUtc().isBefore(range.end),
    );

    final totalIncome =
        monthIncomeList.fold(0.0, (sum, i) => sum + i.amount);
    final totalExpense =
        monthExpenseList.fold(0.0, (sum, e) => sum + e.amount);
    final totalSavings =
        monthSavingsList.fold(0.0, (sum, s) => sum + s.amount);

    final netBalance = FinancialCalculator.netBalance(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      totalSavings: totalSavings,
    );

    final netWithCarry = FinancialCalculator.netWithCarryOver(
      netBalance: netBalance,
      carryOver: cumulativeCarryOver,
    );

    final savingsRate = FinancialCalculator.savingsRate(
      totalSavings: totalSavings,
      totalIncome: totalIncome,
    );

    final expenseRate = FinancialCalculator.expenseRatio(
      totalExpense: totalExpense,
      totalIncome: totalIncome,
    );

    final healthScore = FinancialCalculator.financialHealthScore(
      savingsRate: savingsRate,
      expenseRatio: expenseRate,
      netBalance: netBalance,
      emergencyFundMonths: 0,
    );

    summaries.add(MonthSummary(
      yearMonth: ym,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      totalSavings: totalSavings,
      netBalance: netBalance,
      carryOver: cumulativeCarryOver,
      netWithCarryOver: netWithCarry,
      savingsRate: savingsRate,
      expenseRate: expenseRate,
      healthScore: healthScore,
      updatedAt: DateTime.now(),
    ));

    cumulativeCarryOver = netWithCarry;
  }

  // Return most recent first
  return summaries.reversed.toList();
}

/// Single month summary (used in detail screen)
@riverpod
MonthSummary? monthSummary(Ref ref, String yearMonth) {
  final all = ref.watch(allMonthSummariesProvider);
  final match = all.where((s) => s.yearMonth == yearMonth);
  return match.isEmpty ? null : match.first;
}
