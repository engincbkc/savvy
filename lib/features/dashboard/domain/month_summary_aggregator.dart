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
    bool includeSavings = false,
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
    // Show at most 1 past month (previous month only).
    final now = DateTime.now();
    final currentYm = now.toYearMonth();
    final oneMonthAgo = DateTime(now.year, now.month - 1, 1).toYearMonth();
    yearMonths.removeWhere(
      (ym) => ym.compareTo(currentYm) > 0 || ym.compareTo(oneMonthAgo) < 0,
    );

    // Sort chronologically
    final sorted = yearMonths.toList()..sort();

    // Calculate summaries with cumulative carry-over
    double cumulativeCarryOver = 0;
    final summaries = <MonthSummary>[];

    // Pre-filter recurring items for projection
    final recurringIncomes = incomes.where((i) => i.isRecurring).toList();
    final recurringExpenses = expenses.where((e) => e.isRecurring).toList();

    for (final ym in sorted) {
      final range = YearMonthRange.from(ym);

      // Direct transactions in this month
      final monthIncomeList = incomes.where(
        (i) => i.date.toYearMonth() == ym,
      );
      final monthExpenseList = expenses.where(
        (e) => e.date.toYearMonth() == ym,
      );
      final monthSavingsList = savings.where(
        (s) => s.date.toYearMonth() == ym,
      );

      final month = range.start.month; // 1-indexed

      // Start with direct income entries
      double totalIncome = monthIncomeList.fold(0.0, (sum, i) {
        return sum +
            FinancialCalculator.resolveNetForMonth(
              amount: i.amount,
              isGross: i.isGross,
              month: month,
            );
      });

      // Add recurring incomes that started before this month
      // but don't have a direct entry in this month
      final directIncomeIds = monthIncomeList.map((i) => i.id).toSet();
      for (final ri in recurringIncomes) {
        if (directIncomeIds.contains(ri.id)) continue;
        if (ri.date.toYearMonth().compareTo(ym) >= 0) {
          continue; // not started yet
        }
        if (ri.recurringEndDate != null &&
            ri.recurringEndDate!.isBefore(range.start)) {
          continue; // ended
        }
        totalIncome += FinancialCalculator.resolveNetForMonth(
          amount: ri.amount,
          isGross: ri.isGross,
          month: month,
        );
      }

      // Start with direct expense entries
      double totalExpense =
          monthExpenseList.fold(0.0, (sum, e) => sum + e.amount);

      // Add recurring expenses that started before this month
      final directExpenseIds = monthExpenseList.map((e) => e.id).toSet();
      for (final re in recurringExpenses) {
        if (directExpenseIds.contains(re.id)) continue;
        if (re.date.toYearMonth().compareTo(ym) >= 0) {
          continue;
        }
        if (re.recurringEndDate != null &&
            re.recurringEndDate!.isBefore(range.start)) {
          continue;
        }
        totalExpense += re.amount;
      }

      final totalSavings =
          monthSavingsList.fold(0.0, (sum, s) => sum + s.amount);

      // includeSavings açıkken birikim gelire eklenir
      final effectiveIncome = includeSavings
          ? totalIncome + totalSavings
          : totalIncome;

      final netBalance = FinancialCalculator.netBalance(
        totalIncome: effectiveIncome,
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
