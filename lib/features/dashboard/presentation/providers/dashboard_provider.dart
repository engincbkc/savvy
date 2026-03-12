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
String selectedYearMonth(Ref ref) {
  return DateTime.now().toYearMonth();
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

@riverpod
MonthSummary? monthSummary(Ref ref, String yearMonth) {
  final incomes = ref.watch(monthIncomesProvider(yearMonth)).value ?? [];
  final expenses = ref.watch(monthExpensesProvider(yearMonth)).value ?? [];
  final savings = ref.watch(monthSavingsProvider(yearMonth)).value ?? [];

  final totalIncome = incomes.fold(0.0, (sum, i) => sum + i.amount);
  final totalExpense = expenses.fold(0.0, (sum, e) => sum + e.amount);
  final totalSavings = savings.fold(0.0, (sum, s) => sum + s.amount);

  final netBalance = FinancialCalculator.netBalance(
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    totalSavings: totalSavings,
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

  return MonthSummary(
    yearMonth: yearMonth,
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    totalSavings: totalSavings,
    netBalance: netBalance,
    savingsRate: savingsRate,
    expenseRate: expenseRate,
    healthScore: healthScore,
    updatedAt: DateTime.now(),
  );
}
