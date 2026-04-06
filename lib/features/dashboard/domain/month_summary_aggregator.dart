import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/features/transactions/domain/models/income.dart';
import 'package:savvy/features/transactions/domain/models/expense.dart';
import 'package:savvy/features/savings/domain/models/savings.dart';

/// Raw per-month totals produced by [MonthSummaryAggregator.buildAllMonthTotals].
class MonthTotals {
  final Map<String, double> incomeTotals;
  final Map<String, double> expenseTotals;
  final Map<String, double> savingsTotals;

  const MonthTotals({
    required this.incomeTotals,
    required this.expenseTotals,
    required this.savingsTotals,
  });
}

/// Aggregates raw transactions into monthly summaries with carry-over.
class MonthSummaryAggregator {
  MonthSummaryAggregator._();

  /// Builds per-month income/expense/savings totals using the same projection
  /// logic as buildMonthlyCategoryData: each recurring item is projected
  /// forward from its start date. This is the single source of truth shared
  /// by both [buildSummaries] and [futureProjections].
  static MonthTotals buildAllMonthTotals({
    required List<Income> incomes,
    required List<Expense> expenses,
    required List<Savings> savings,
  }) {
    final incomeTotals = <String, double>{};
    final expenseTotals = <String, double>{};
    final savingsTotals = <String, double>{};

    void addIncome(String ym, double amount) {
      incomeTotals[ym] = (incomeTotals[ym] ?? 0) + amount;
    }

    void addExpense(String ym, double amount) {
      expenseTotals[ym] = (expenseTotals[ym] ?? 0) + amount;
    }

    // ── Process incomes ──
    for (final i in incomes) {
      final startYm = i.date.toYearMonth();
      final startAmount = i.monthlyOverrides[startYm] ?? i.amount;
      addIncome(
        startYm,
        FinancialCalculator.resolveNetForMonth(
          amount: startAmount,
          isGross: i.isGross,
          month: i.date.month,
        ),
      );

      if (i.isRecurring) {
        final endDate = i.recurringEndDate;
        final projLimit = endDate != null
            ? ((endDate.year - i.date.year) * 12 +
                    endDate.month - i.date.month)
                .clamp(1, 240)
            : (i.isGross ? 60 : 12);
        for (int m = 1; m <= projLimit; m++) {
          final futureDate = DateTime(i.date.year, i.date.month + m, 1);
          if (endDate != null && futureDate.isAfter(endDate)) break;
          final futureYm = futureDate.toYearMonth();
          final overrideAmount = i.monthlyOverrides[futureYm] ?? i.amount;
          addIncome(
            futureYm,
            FinancialCalculator.resolveNetForMonth(
              amount: overrideAmount,
              isGross: i.isGross,
              month: futureDate.month,
            ),
          );
        }
      }
    }

    // ── Process expenses ──
    for (final e in expenses) {
      final startYm = e.date.toYearMonth();
      addExpense(startYm, e.monthlyOverrides[startYm] ?? e.amount);

      if (e.isRecurring) {
        final endDate = e.recurringEndDate;
        final projLimit = endDate != null
            ? ((endDate.year - e.date.year) * 12 +
                    endDate.month - e.date.month)
                .clamp(1, 240)
            : 12;
        for (int m = 1; m <= projLimit; m++) {
          final futureDate = DateTime(e.date.year, e.date.month + m, 1);
          if (endDate != null && futureDate.isAfter(endDate)) break;
          final futureYm = futureDate.toYearMonth();
          addExpense(futureYm, e.monthlyOverrides[futureYm] ?? e.amount);
        }
      }
    }

    // ── Process savings ──
    for (final s in savings) {
      savingsTotals[s.date.toYearMonth()] =
          (savingsTotals[s.date.toYearMonth()] ?? 0) + s.amount;
    }

    return MonthTotals(
      incomeTotals: incomeTotals,
      expenseTotals: expenseTotals,
      savingsTotals: savingsTotals,
    );
  }

  /// Builds month summaries sorted most-recent-first with cumulative carry-over.
  static List<MonthSummary> buildSummaries({
    required List<Income> incomes,
    required List<Expense> expenses,
    required List<Savings> savings,
    bool includeSavings = false,
  }) {
    if (incomes.isEmpty && expenses.isEmpty && savings.isEmpty) return [];

    final data = buildAllMonthTotals(
      incomes: incomes,
      expenses: expenses,
      savings: savings,
    );

    // ── Determine which months to include (1 past + current) ──
    final allYms = <String>{
      ...data.incomeTotals.keys,
      ...data.expenseTotals.keys,
      ...data.savingsTotals.keys,
    };
    allYms.add(DateTime.now().toYearMonth());

    final now = DateTime.now();
    final currentYm = now.toYearMonth();
    final oneMonthAgo = DateTime(now.year, now.month - 1, 1).toYearMonth();
    allYms.removeWhere(
      (ym) => ym.compareTo(currentYm) > 0 || ym.compareTo(oneMonthAgo) < 0,
    );

    final sorted = allYms.toList()..sort();

    // ── Step 3: Build MonthSummary list with cumulative carry-over ──
    double cumulativeCarryOver = 0;
    final summaries = <MonthSummary>[];

    for (final ym in sorted) {
      final totalIncome = data.incomeTotals[ym] ?? 0;
      final totalExpense = data.expenseTotals[ym] ?? 0;
      final totalSavings = data.savingsTotals[ym] ?? 0;

      final effectiveIncome =
          includeSavings ? totalIncome + totalSavings : totalIncome;

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
