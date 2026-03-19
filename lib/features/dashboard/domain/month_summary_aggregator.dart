import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/features/transactions/domain/models/income.dart';
import 'package:savvy/features/transactions/domain/models/expense.dart';
import 'package:savvy/features/savings/domain/models/savings.dart';

/// Aggregates raw transactions into monthly summaries with carry-over.
class MonthSummaryAggregator {
  MonthSummaryAggregator._();

  /// Builds month summaries sorted most-recent-first with cumulative carry-over.
  static List<MonthSummary> buildSummaries({
    required List<Income> incomes,
    required List<Expense> expenses,
    required List<Savings> savings,
  }) {
    if (incomes.isEmpty && expenses.isEmpty && savings.isEmpty) return [];

    // Collect all unique yearMonths
    final yearMonths = <String>{};
    for (final i in incomes) {
      yearMonths.add(i.date.toYearMonth());
    }
    for (final e in expenses) {
      yearMonths.add(e.date.toYearMonth());
    }
    for (final s in savings) {
      yearMonths.add(s.date.toYearMonth());
    }
    yearMonths.add(DateTime.now().toYearMonth());

    // Only include months up to current month (future months handled by projections)
    final currentYm = DateTime.now().toYearMonth();
    yearMonths.removeWhere((ym) => ym.compareTo(currentYm) > 0);

    // Sort chronologically
    final sorted = yearMonths.toList()..sort();

    // Calculate summaries with cumulative carry-over
    double cumulativeCarryOver = 0;
    final summaries = <MonthSummary>[];

    for (final ym in sorted) {
      final range = YearMonthRange.from(ym);

      final monthIncomeList = incomes.where(
        (i) =>
            !i.date.toUtc().isBefore(range.start) &&
            i.date.toUtc().isBefore(range.end),
      );
      final monthExpenseList = expenses.where(
        (e) =>
            !e.date.toUtc().isBefore(range.start) &&
            e.date.toUtc().isBefore(range.end),
      );
      final monthSavingsList = savings.where(
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
}
