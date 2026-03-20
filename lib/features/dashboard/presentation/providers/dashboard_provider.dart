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

  return MonthSummaryAggregator.buildSummaries(
    incomes: allInc,
    expenses: allExp,
    savings: allSav,
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
/// Projects 12 months ahead from current month.
/// When includeSavings is true, total savings is added as one-time income
/// in month 1.
@riverpod
List<MonthSummary> futureProjections(Ref ref) {
  final allInc = ref.watch(allIncomesProvider).value ?? [];
  final allExp = ref.watch(allExpensesProvider).value ?? [];
  final summaries = ref.watch(allMonthSummariesProvider);
  final includeSavings = ref.watch(includeSavingsInProjectionProvider);
  final totalSavings = ref.watch(totalSavingsAmountProvider);

  if (summaries.isEmpty) return [];

  // Get the latest cumulative balance as starting carry-over
  final latestCarryOver = summaries.first.netWithCarryOver;

  // Find recurring incomes/expenses (active, not ended)
  final now = DateTime.now();
  final recurringIncomes = allInc.where((i) =>
      i.isRecurring &&
      (i.recurringEndDate == null || i.recurringEndDate!.isAfter(now)));
  final recurringExpenses = allExp.where((e) =>
      e.isRecurring &&
      (e.recurringEndDate == null || e.recurringEndDate!.isAfter(now)));

  // One-time future incomes/expenses
  final futureOneTimeIncomes =
      allInc.where((i) => !i.isRecurring && i.date.isAfter(now));
  final futureOneTimeExpenses =
      allExp.where((e) => !e.isRecurring && e.date.isAfter(now));

  // Project 12 months ahead
  double cumCarry = latestCarryOver;
  final projections = <MonthSummary>[];

  for (int m = 1; m <= 12; m++) {
    final futureDate = DateTime(now.year, now.month + m, 1);
    final ym = futureDate.toYearMonth();
    final range = YearMonthRange.from(ym);

    // Recurring incomes (check end date, resolve gross→net)
    double projIncome = 0;
    for (final i in recurringIncomes) {
      if (i.recurringEndDate != null &&
          i.recurringEndDate!.isBefore(futureDate)) {
        continue;
      }
      projIncome += FinancialCalculator.resolveNetForMonth(
        amount: i.amount,
        isGross: i.isGross,
        month: futureDate.month,
      );
    }
    // One-time future incomes in this month
    for (final i in futureOneTimeIncomes) {
      if (!i.date.isBefore(range.start) && i.date.isBefore(range.end)) {
        projIncome += FinancialCalculator.resolveNetForMonth(
          amount: i.amount,
          isGross: i.isGross,
          month: futureDate.month,
        );
      }
    }

    // Add savings as one-time income in month 1 only
    if (includeSavings && m == 1 && totalSavings > 0) {
      projIncome += totalSavings;
    }

    // Recurring expenses (check end date)
    double projExpense = 0;
    for (final e in recurringExpenses) {
      if (e.recurringEndDate != null &&
          e.recurringEndDate!.isBefore(futureDate)) {
        continue;
      }
      projExpense += e.amount;
    }
    // One-time future expenses in this month
    for (final e in futureOneTimeExpenses) {
      if (!e.date.isBefore(range.start) && e.date.isBefore(range.end)) {
        projExpense += e.amount;
      }
    }

    final netBalance = projIncome - projExpense;
    final netWithCarry = netBalance + cumCarry;
    final savingsRate = projIncome > 0
        ? ((projIncome - projExpense) / projIncome).clamp(0.0, 1.0)
        : 0.0;
    final expenseRate =
        projIncome > 0 ? (projExpense / projIncome).clamp(0.0, 2.0) : 0.0;

    projections.add(MonthSummary(
      yearMonth: ym,
      totalIncome: projIncome,
      totalExpense: projExpense,
      totalSavings: 0,
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
