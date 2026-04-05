import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/features/simulation/domain/models/simulation_change.dart';

/// Aggregated result of an entire simulation scenario.
class SimulationResult {
  final double currentIncome;
  final double currentExpense;
  final double currentNet;
  final double newIncome;
  final double newExpense;
  final double newNet;
  final double monthlyNetImpact;
  final double annualNetImpact;
  final double newSavingsRate;
  final double newExpenseRate;
  final AffordabilityStatus? affordability;
  final List<ChangeResult> changeResults;
  final List<MonthProjection> monthlyProjection;

  const SimulationResult({
    required this.currentIncome,
    required this.currentExpense,
    required this.currentNet,
    required this.newIncome,
    required this.newExpense,
    required this.newNet,
    required this.monthlyNetImpact,
    required this.annualNetImpact,
    required this.newSavingsRate,
    required this.newExpenseRate,
    this.affordability,
    required this.changeResults,
    required this.monthlyProjection,
  });

  /// Whether the scenario is net-positive.
  bool get isPositive => newNet >= 0;

  /// Whether any change has an amortization schedule.
  bool get hasAmortization =>
      changeResults.any((r) => r.amortizationSchedule != null);

  /// Total interest paid across all loan-based changes.
  double get totalInterest =>
      changeResults.fold(0.0, (sum, r) => sum + (r.totalInterest ?? 0));

  /// Total cost across all changes.
  double get totalCost =>
      changeResults.fold(0.0, (sum, r) => sum + (r.totalCost ?? 0));

  /// Income change delta.
  double get incomeDelta => newIncome - currentIncome;

  /// Expense change delta.
  double get expenseDelta => newExpense - currentExpense;
}

/// Per-change breakdown within a simulation.
class ChangeResult {
  final SimulationChange change;
  final double monthlyImpact;
  final double? totalCost;
  final double? totalInterest;
  final List<AmortizationRow>? amortizationSchedule;
  final SalaryImpact? salaryImpact;
  final InvestmentImpact? investmentImpact;

  const ChangeResult({
    required this.change,
    required this.monthlyImpact,
    this.totalCost,
    this.totalInterest,
    this.amortizationSchedule,
    this.salaryImpact,
    this.investmentImpact,
  });
}

/// Monthly projection row for 12-month forward view.
class MonthProjection {
  final String yearMonth;
  final String monthLabel;
  final double income;
  final double expense;
  final double net;
  final double cumulativeNet;
  final List<MonthLineItem> incomeItems;
  final List<MonthLineItem> expenseItems;

  const MonthProjection({
    required this.yearMonth,
    required this.monthLabel,
    required this.income,
    required this.expense,
    required this.net,
    required this.cumulativeNet,
    required this.incomeItems,
    required this.expenseItems,
  });
}

/// Single line item in a monthly projection (kalem kalem goruntuleme).
class MonthLineItem {
  final String label;
  final double amount;
  final bool isSimulated;

  const MonthLineItem({
    required this.label,
    required this.amount,
    this.isSimulated = false,
  });
}

/// Salary change impact details.
class SalaryImpact {
  final double currentGross;
  final double newGross;
  final double currentNetAvg;
  final double newNetAvg;
  final double monthlyNetDelta;
  final List<double> currentMonthlyNets;
  final List<double> newMonthlyNets;

  const SalaryImpact({
    required this.currentGross,
    required this.newGross,
    required this.currentNetAvg,
    required this.newNetAvg,
    required this.monthlyNetDelta,
    required this.currentMonthlyNets,
    required this.newMonthlyNets,
  });
}

/// Investment return impact details.
class InvestmentImpact {
  final double principal;
  final double totalReturn;
  /// Average monthly equivalent (totalReturn / termMonths) — for comparison display only.
  final double monthlyReturn;
  /// Maturity value = principal + totalReturn (vade sonu değeri).
  final double totalValue;
  final int termMonths;
  final bool isCompound;

  const InvestmentImpact({
    required this.principal,
    required this.totalReturn,
    required this.monthlyReturn,
    required this.totalValue,
    required this.termMonths,
    required this.isCompound,
  });
}

/// A recurring item used to build the dynamic monthly projection base.
///
/// Keeps SimulationCalculator free of Income/Expense model imports.
/// Provider layer maps Income/Expense → ProjectionBaseItem before calling
/// [SimulationCalculator.calculateScenario].
class ProjectionBaseItem {
  final String label;
  final bool isIncome;

  /// Date this recurring item became active (year+month precision).
  final DateTime startDate;

  /// null = indefinite (no end date).
  final DateTime? endDate;

  /// Non-null when the item is a gross salary — tax is applied per-month.
  final double? grossAmount;

  /// Pre-resolved net monthly amount (used when [grossAmount] is null).
  final double netAmount;

  const ProjectionBaseItem({
    required this.label,
    required this.isIncome,
    required this.startDate,
    this.endDate,
    this.grossAmount,
    this.netAmount = 0,
  });

  /// Whether this item is active during [month] (year+month comparison).
  bool isActiveOn(DateTime month) {
    final m = DateTime(month.year, month.month);
    final s = DateTime(startDate.year, startDate.month);
    if (m.isBefore(s)) return false;
    if (endDate == null) return true;
    final e = DateTime(endDate!.year, endDate!.month);
    return !m.isAfter(e);
  }
}

/// Amortization schedule row.
class AmortizationRow {
  final int month;
  final double payment;
  final double principal;
  final double interest;
  final double balance;

  const AmortizationRow({
    required this.month,
    required this.payment,
    required this.principal,
    required this.interest,
    required this.balance,
  });
}
