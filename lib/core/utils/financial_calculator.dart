import 'dart:math';
import 'package:savvy/core/constants/financial_enums.dart';

/// ALL financial calculations happen here — nowhere else.
/// BL-001: No math in UI. No math in Repository.
class FinancialCalculator {
  // ─── Core Summary ────────────────────────────────────────────────

  /// Net balance without carry-over
  static double netBalance({
    required double totalIncome,
    required double totalExpense,
    required double totalSavings,
  }) {
    assert(totalIncome >= 0, 'Income cannot be negative');
    assert(totalExpense >= 0, 'Expense cannot be negative');
    assert(totalSavings >= 0, 'Savings cannot be negative');
    return totalIncome - totalExpense - totalSavings;
  }

  /// Net balance with carry-over from previous month
  static double netWithCarryOver({
    required double netBalance,
    required double carryOver,
  }) =>
      netBalance + carryOver;

  /// Expense ratio (0.0 – 1.0+)
  static double expenseRatio({
    required double totalExpense,
    required double totalIncome,
  }) =>
      totalIncome > 0 ? totalExpense / totalIncome : 0.0;

  /// Savings rate (0.0 – 1.0)
  static double savingsRate({
    required double totalSavings,
    required double totalIncome,
  }) =>
      totalIncome > 0 ? totalSavings / totalIncome : 0.0;

  /// Target savings amount (default 20% rule)
  static double targetSavings({
    required double totalIncome,
    double targetRate = 0.20,
  }) =>
      totalIncome * targetRate;

  // ─── Financial Health Score (0–100) ──────────────────────────────

  static int financialHealthScore({
    required double savingsRate,
    required double expenseRatio,
    required double netBalance,
    required double emergencyFundMonths,
  }) {
    int score = 0;

    // Savings rate (max 35 pts)
    if (savingsRate >= 0.25) {
      score += 35;
    } else if (savingsRate >= 0.20) {
      score += 28;
    } else if (savingsRate >= 0.15) {
      score += 20;
    } else if (savingsRate >= 0.10) {
      score += 12;
    } else if (savingsRate >= 0.05) {
      score += 5;
    }

    // Expense ratio (max 30 pts)
    if (expenseRatio <= 0.50) {
      score += 30;
    } else if (expenseRatio <= 0.60) {
      score += 25;
    } else if (expenseRatio <= 0.70) {
      score += 18;
    } else if (expenseRatio <= 0.80) {
      score += 10;
    } else if (expenseRatio <= 0.90) {
      score += 4;
    }

    // Net balance (max 20 pts)
    if (netBalance > 0) {
      score += 20;
    } else if (netBalance == 0) {
      score += 8;
    }

    // Emergency fund (max 15 pts)
    if (emergencyFundMonths >= 6) {
      score += 15;
    } else if (emergencyFundMonths >= 3) {
      score += 10;
    } else if (emergencyFundMonths >= 1) {
      score += 5;
    }

    return score.clamp(0, 100);
  }

  static String healthScoreLabel(int score) => switch (score) {
        >= 80 => 'Mükemmel',
        >= 65 => 'İyi',
        >= 50 => 'Orta',
        >= 35 => 'Dikkat',
        _ => 'Kritik',
      };

  // ─── Savings Goal ────────────────────────────────────────────────

  static int monthsToGoal({
    required double targetAmount,
    required double currentAmount,
    required double monthlySavings,
  }) {
    if (monthlySavings <= 0) return -1;
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0) return 0;
    return (remaining / monthlySavings).ceil();
  }

  static double requiredMonthlySavings({
    required double targetAmount,
    required double currentAmount,
    required int monthsLeft,
  }) {
    if (monthsLeft <= 0) return double.infinity;
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0) return 0;
    return remaining / monthsLeft;
  }

  static double goalProgress({
    required double targetAmount,
    required double currentAmount,
  }) {
    if (targetAmount <= 0) return 0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  // ─── Loan / Installment ──────────────────────────────────────────

  /// Monthly loan payment (EMI - Equal Monthly Installment)
  static double monthlyLoanPayment({
    required double principal,
    required double annualRate,
    required int termMonths,
  }) {
    if (annualRate == 0) return principal / termMonths;
    final r = annualRate / 12;
    final n = termMonths;
    return principal * (r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
  }

  static double totalLoanPayment({
    required double monthlyPayment,
    required int termMonths,
  }) =>
      monthlyPayment * termMonths;

  static double totalInterest({
    required double totalPayment,
    required double principal,
  }) =>
      totalPayment - principal;

  static AffordabilityStatus loanAffordability({
    required double monthlyPayment,
    required double monthlyIncome,
  }) {
    final ratio =
        monthlyIncome > 0 ? monthlyPayment / monthlyIncome : 1.0;
    return switch (ratio) {
      < 0.25 => AffordabilityStatus.comfortable,
      < 0.35 => AffordabilityStatus.manageable,
      < 0.45 => AffordabilityStatus.tight,
      _ => AffordabilityStatus.risky,
    };
  }

  // ─── Brüt → Net Maaş Hesaplama (2026 Türkiye) ─────────────────

  /// 2026 Türkiye gelir vergisi dilimleri
  static const _taxBrackets2026 = [
    (limit: 158000.0, rate: 0.15),
    (limit: 350000.0, rate: 0.20),
    (limit: 900000.0, rate: 0.27),
    (limit: 1900000.0, rate: 0.35),
    (limit: double.infinity, rate: 0.40),
  ];

  static const sgkWorkerRate = 0.14;
  static const unemploymentInsuranceRate = 0.01;

  /// Brüt yıllık maaştan gelir vergisi hesapla (kümülatif dilim)
  static double _annualIncomeTax(double annualTaxBase) {
    double tax = 0;
    double remaining = annualTaxBase;
    double prevLimit = 0;

    for (final bracket in _taxBrackets2026) {
      final taxable = (remaining).clamp(0.0, bracket.limit - prevLimit);
      tax += taxable * bracket.rate;
      remaining -= taxable;
      prevLimit = bracket.limit;
      if (remaining <= 0) break;
    }
    return tax;
  }

  /// Brüt aylık maaştan net maaş ve kesinti detaylarını hesapla
  static SalaryBreakdown grossToNet({required double grossMonthly}) {
    final grossAnnual = grossMonthly * 12;

    // SGK işçi payı (brüt üzerinden, tavan kontrolü basitlik için yok)
    final sgkMonthly = grossMonthly * sgkWorkerRate;
    final unemploymentMonthly = grossMonthly * unemploymentInsuranceRate;

    // Gelir vergisi matrahı (yıllık)
    final annualTaxBase = grossAnnual - (sgkMonthly * 12) - (unemploymentMonthly * 12);
    final annualTax = _annualIncomeTax(annualTaxBase);
    final monthlyTax = annualTax / 12;

    // Damga vergisi (%0.759)
    final stampTax = grossMonthly * 0.00759;

    final totalDeductions = sgkMonthly + unemploymentMonthly + monthlyTax + stampTax;
    final netMonthly = grossMonthly - totalDeductions;

    return SalaryBreakdown(
      grossMonthly: grossMonthly,
      sgk: sgkMonthly,
      unemploymentInsurance: unemploymentMonthly,
      incomeTax: monthlyTax,
      stampTax: stampTax,
      totalDeductions: totalDeductions,
      netMonthly: netMonthly,
    );
  }

  // ─── Projections ─────────────────────────────────────────────────

  static double projectedSavings({
    required double currentSavings,
    required double monthlySavings,
    required int months,
  }) =>
      currentSavings + (monthlySavings * months);
}

/// Brüt → Net maaş hesaplama sonucu
class SalaryBreakdown {
  final double grossMonthly;
  final double sgk;
  final double unemploymentInsurance;
  final double incomeTax;
  final double stampTax;
  final double totalDeductions;
  final double netMonthly;

  const SalaryBreakdown({
    required this.grossMonthly,
    required this.sgk,
    required this.unemploymentInsurance,
    required this.incomeTax,
    required this.stampTax,
    required this.totalDeductions,
    required this.netMonthly,
  });
}
