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

/// Effective incomes for a given month — includes recurring projections.
/// Returns the actual Income objects that contribute to this month,
/// with amount adjusted for overrides and gross calculation.
@riverpod
List<Income> effectiveMonthIncomes(Ref ref, String yearMonth) {
  final allInc = ref.watch(allIncomesProvider).value ?? [];
  final result = <Income>[];

  for (final i in allInc) {
    final startYm = i.date.toYearMonth();

    if (startYm == yearMonth) {
      // Original month — use override amount if available
      final amt = i.monthlyOverrides[yearMonth] ?? i.amount;
      final net = FinancialCalculator.resolveNetForMonth(
        amount: amt,
        isGross: i.isGross,
        month: i.date.month,
      );
      result.add(i.copyWith(amount: net));
    } else if (i.isRecurring && startYm.compareTo(yearMonth) < 0) {
      // Recurring item projected into this month
      final endDate = i.recurringEndDate;
      final projLimit = endDate != null
          ? ((endDate.year - i.date.year) * 12 +
                  endDate.month - i.date.month)
              .clamp(1, 240)
          : (i.isGross ? 60 : 12);

      // Check if yearMonth falls within projection range
      final ymParts = yearMonth.split('-');
      final ymY = int.parse(ymParts[0]);
      final ymM = int.parse(ymParts[1]);
      final monthsDiff =
          (ymY - i.date.year) * 12 + ymM - i.date.month;

      if (monthsDiff > 0 && monthsDiff <= projLimit) {
        if (endDate != null) {
          final futureDate = DateTime(ymY, ymM, 1);
          if (futureDate.isAfter(endDate)) continue;
        }
        final amt = i.monthlyOverrides[yearMonth] ?? i.amount;
        final net = FinancialCalculator.resolveNetForMonth(
          amount: amt,
          isGross: i.isGross,
          month: ymM,
        );
        result.add(i.copyWith(
          amount: net,
          date: DateTime(ymY, ymM, i.date.day),
        ));
      }
    }
  }

  return result;
}

/// Effective expenses for a given month — includes recurring projections.
@riverpod
List<Expense> effectiveMonthExpenses(Ref ref, String yearMonth) {
  final allExp = ref.watch(allExpensesProvider).value ?? [];
  final result = <Expense>[];

  for (final e in allExp) {
    final startYm = e.date.toYearMonth();

    if (startYm == yearMonth) {
      final amt = e.monthlyOverrides[yearMonth] ?? e.amount;
      result.add(e.copyWith(amount: amt));
    } else if (e.isRecurring && startYm.compareTo(yearMonth) < 0) {
      final endDate = e.recurringEndDate;
      final projLimit = endDate != null
          ? ((endDate.year - e.date.year) * 12 +
                  endDate.month - e.date.month)
              .clamp(1, 240)
          : 12;

      final ymParts = yearMonth.split('-');
      final ymY = int.parse(ymParts[0]);
      final ymM = int.parse(ymParts[1]);
      final monthsDiff =
          (ymY - e.date.year) * 12 + ymM - e.date.month;

      if (monthsDiff > 0 && monthsDiff <= projLimit) {
        if (endDate != null) {
          final futureDate = DateTime(ymY, ymM, 1);
          if (futureDate.isAfter(endDate)) continue;
        }
        final amt = e.monthlyOverrides[yearMonth] ?? e.amount;
        result.add(e.copyWith(
          amount: amt,
          date: DateTime(ymY, ymM, e.date.day),
        ));
      }
    }
  }

  return result;
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
