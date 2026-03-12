import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';

class SimulationCalculator {
  // ─── Credit Simulation ───────────────────────────────────────────

  static CreditSimulationResult credit({
    required double principal,
    required double annualRate,
    required int termMonths,
    required MonthSummary currentBudget,
  }) {
    final monthly = FinancialCalculator.monthlyLoanPayment(
      principal: principal,
      annualRate: annualRate,
      termMonths: termMonths,
    );
    final total = FinancialCalculator.totalLoanPayment(
      monthlyPayment: monthly,
      termMonths: termMonths,
    );
    return CreditSimulationResult(
      monthlyPayment: monthly,
      totalPayment: total,
      totalInterest: FinancialCalculator.totalInterest(
        totalPayment: total,
        principal: principal,
      ),
      incomeRatio: currentBudget.totalIncome > 0
          ? monthly / currentBudget.totalIncome
          : 1.0,
      newNetBalance: currentBudget.netBalance - monthly,
      newSavingsRate: currentBudget.totalIncome > 0
          ? currentBudget.totalSavings / currentBudget.totalIncome
          : 0,
      affordability: FinancialCalculator.loanAffordability(
        monthlyPayment: monthly,
        monthlyIncome: currentBudget.totalIncome,
      ),
      amortizationSchedule: _amortizationSchedule(
        principal: principal,
        annualRate: annualRate,
        termMonths: termMonths,
      ),
    );
  }

  // ─── Rent Change Simulation ──────────────────────────────────────

  static RentSimulationResult rentChange({
    required double currentRent,
    required double increasePercent,
    required MonthSummary currentBudget,
  }) {
    final newRent = currentRent * (1 + increasePercent / 100);
    final diff = newRent - currentRent;
    return RentSimulationResult(
      newRent: newRent,
      monthlyDiff: diff,
      annualDiff: diff * 12,
      newNetBalance: currentBudget.netBalance - diff,
      newExpenseRate: (currentBudget.totalExpense + diff) /
          currentBudget.totalIncome,
      newSavingsRate: currentBudget.savingsRate,
    );
  }

  // ─── Car Purchase Simulation ─────────────────────────────────────

  static CarSimulationResult car({
    required double vehiclePrice,
    required double downPayment,
    required double annualRate,
    required int termMonths,
    required double estimatedMonthlyCosts,
    required MonthSummary currentBudget,
  }) {
    final loanAmount = vehiclePrice - downPayment;
    final creditResult = credit(
      principal: loanAmount,
      annualRate: annualRate,
      termMonths: termMonths,
      currentBudget: currentBudget,
    );
    final totalMonthlyImpact =
        creditResult.monthlyPayment + estimatedMonthlyCosts;

    return CarSimulationResult(
      loanAmount: loanAmount,
      creditResult: creditResult,
      estimatedMonthlyCosts: estimatedMonthlyCosts,
      totalMonthlyImpact: totalMonthlyImpact,
      newNetBalance: currentBudget.netBalance - totalMonthlyImpact,
      affordability: FinancialCalculator.loanAffordability(
        monthlyPayment: totalMonthlyImpact,
        monthlyIncome: currentBudget.totalIncome,
      ),
    );
  }

  // ─── Amortization Schedule ───────────────────────────────────────

  static List<AmortizationRow> _amortizationSchedule({
    required double principal,
    required double annualRate,
    required int termMonths,
  }) {
    final r = annualRate / 12;
    final monthly = FinancialCalculator.monthlyLoanPayment(
      principal: principal,
      annualRate: annualRate,
      termMonths: termMonths,
    );
    double balance = principal;
    return List.generate(termMonths, (i) {
      final interest = balance * r;
      final principalPaid = monthly - interest;
      balance -= principalPaid;
      return AmortizationRow(
        month: i + 1,
        payment: monthly,
        principal: principalPaid,
        interest: interest,
        balance: balance.clamp(0, double.infinity),
      );
    });
  }
}

// ─── Result Models ─────────────────────────────────────────────────

class CreditSimulationResult {
  final double monthlyPayment;
  final double totalPayment;
  final double totalInterest;
  final double incomeRatio;
  final double newNetBalance;
  final double newSavingsRate;
  final AffordabilityStatus affordability;
  final List<AmortizationRow> amortizationSchedule;

  const CreditSimulationResult({
    required this.monthlyPayment,
    required this.totalPayment,
    required this.totalInterest,
    required this.incomeRatio,
    required this.newNetBalance,
    required this.newSavingsRate,
    required this.affordability,
    required this.amortizationSchedule,
  });
}

class RentSimulationResult {
  final double newRent;
  final double monthlyDiff;
  final double annualDiff;
  final double newNetBalance;
  final double newExpenseRate;
  final double newSavingsRate;

  const RentSimulationResult({
    required this.newRent,
    required this.monthlyDiff,
    required this.annualDiff,
    required this.newNetBalance,
    required this.newExpenseRate,
    required this.newSavingsRate,
  });
}

class CarSimulationResult {
  final double loanAmount;
  final CreditSimulationResult creditResult;
  final double estimatedMonthlyCosts;
  final double totalMonthlyImpact;
  final double newNetBalance;
  final AffordabilityStatus affordability;

  const CarSimulationResult({
    required this.loanAmount,
    required this.creditResult,
    required this.estimatedMonthlyCosts,
    required this.totalMonthlyImpact,
    required this.newNetBalance,
    required this.affordability,
  });
}

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
