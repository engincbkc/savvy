import 'dart:math';

import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/features/simulation/domain/models/simulation_change.dart';
import 'package:savvy/features/simulation/domain/models/simulation_result.dart';

/// BL-001: All simulation calculations happen here — nowhere else.
class SimulationCalculator {
  // ─── Main Entry Point ────────────────────────────────────────────

  /// Calculate a full scenario from composable changes against current budget.
  ///
  /// [baseItems] — when provided, the 12-month projection uses a dynamic base
  /// (each month filters active recurring items by their start/end dates).
  /// When empty, falls back to the static [currentBudget] snapshot (old behaviour).
  static SimulationResult calculateScenario({
    required List<SimulationChange> changes,
    required MonthSummary currentBudget,
    List<MonthLineItem> existingIncomeItems = const [],
    List<MonthLineItem> existingExpenseItems = const [],
    List<ProjectionBaseItem> baseItems = const [],
  }) {
    if (changes.isEmpty) {
      return _emptyResult(currentBudget, existingIncomeItems, existingExpenseItems, baseItems);
    }

    double totalIncomeImpact = 0;
    double totalExpenseImpact = 0;
    final changeResults = <ChangeResult>[];

    for (final change in changes) {
      final result = _calculateChange(change, currentBudget);
      changeResults.add(result);

      if (result.monthlyImpact > 0) {
        totalIncomeImpact += result.monthlyImpact;
      } else {
        totalExpenseImpact += result.monthlyImpact.abs();
      }
    }

    final newIncome = currentBudget.totalIncome + totalIncomeImpact;
    final newExpense = currentBudget.totalExpense + totalExpenseImpact;
    final newNet = newIncome - newExpense;
    final monthlyNetImpact = totalIncomeImpact - totalExpenseImpact;

    final newExpenseRate = newIncome > 0 ? newExpense / newIncome : 0.0;
    final newSavingsRate = newIncome > 0
        ? ((newIncome - newExpense) / newIncome).clamp(0.0, 1.0)
        : 0.0;

    // Affordability based on total new expense-only impacts vs income
    AffordabilityStatus? affordability;
    if (totalExpenseImpact > 0) {
      affordability = FinancialCalculator.loanAffordability(
        monthlyPayment: totalExpenseImpact,
        monthlyIncome: newIncome,
      );
    }

    // 12-month projection
    final projection = _buildProjection(
      changes: changes,
      changeResults: changeResults,
      currentBudget: currentBudget,
      existingIncomeItems: existingIncomeItems,
      existingExpenseItems: existingExpenseItems,
      baseItems: baseItems,
    );

    return SimulationResult(
      currentIncome: currentBudget.totalIncome,
      currentExpense: currentBudget.totalExpense,
      currentNet: currentBudget.netBalance,
      newIncome: newIncome,
      newExpense: newExpense,
      newNet: newNet,
      monthlyNetImpact: monthlyNetImpact,
      annualNetImpact: _calculateAnnualImpact(changes, changeResults),
      newSavingsRate: newSavingsRate,
      newExpenseRate: newExpenseRate,
      affordability: affordability,
      changeResults: changeResults,
      monthlyProjection: projection,
    );
  }

  // ─── Per-Change Calculators ──────────────────────────────────────

  static ChangeResult _calculateChange(
    SimulationChange change,
    MonthSummary budget,
  ) {
    return switch (change) {
      CreditChange() => _calcCredit(change, budget),
      HousingChange() => _calcHousing(change, budget),
      CarChange() => _calcCar(change, budget),
      RentChangeChange() => _calcRentChange(change),
      SalaryChangeChange() => _calcSalaryChange(change),
      IncomeChange() => _calcIncome(change),
      ExpenseChange() => _calcExpense(change),
      InvestmentChange() => _calcInvestment(change),
    };
  }

  static ChangeResult _calcCredit(CreditChange c, MonthSummary budget) {
    return _calcLoanBased(
      change: c,
      loanPrincipal: c.principal,
      annualRate: c.annualRate,
      termMonths: c.termMonths,
      downPayment: 0,
      monthlyExtras: 0,
    );
  }

  static ChangeResult _calcHousing(HousingChange c, MonthSummary budget) {
    return _calcLoanBased(
      change: c,
      loanPrincipal: c.price - c.downPayment,
      annualRate: c.annualRate,
      termMonths: c.termMonths,
      downPayment: c.downPayment,
      monthlyExtras: c.monthlyExtras,
    );
  }

  static ChangeResult _calcCar(CarChange c, MonthSummary budget) {
    return _calcLoanBased(
      change: c,
      loanPrincipal: c.price - c.downPayment,
      annualRate: c.annualRate,
      termMonths: c.termMonths,
      downPayment: c.downPayment,
      monthlyExtras: c.monthlyRunningCosts,
    );
  }

  /// Shared loan calculation for credit, housing, and car changes.
  static ChangeResult _calcLoanBased({
    required SimulationChange change,
    required double loanPrincipal,
    required double annualRate,
    required int termMonths,
    required double downPayment,
    required double monthlyExtras,
  }) {
    if (loanPrincipal <= 0) {
      return ChangeResult(
        change: change,
        monthlyImpact: -monthlyExtras,
        totalCost: downPayment,
      );
    }

    final rate = annualRate / 100;
    final monthly = FinancialCalculator.monthlyLoanPayment(
      principal: loanPrincipal,
      annualRate: rate,
      termMonths: termMonths,
    );
    final total = monthly * termMonths;
    final interest = total - loanPrincipal;
    final totalMonthly = monthly + monthlyExtras;

    return ChangeResult(
      change: change,
      monthlyImpact: -totalMonthly,
      totalCost: total + downPayment + (monthlyExtras * termMonths),
      totalInterest: interest,
      amortizationSchedule: _amortizationSchedule(
        principal: loanPrincipal,
        annualRate: rate,
        termMonths: termMonths,
      ),
    );
  }

  static ChangeResult _calcRentChange(RentChangeChange c) {
    final diff = c.newRent - c.currentRent;
    return ChangeResult(
      change: c,
      monthlyImpact: -diff,
    );
  }

  /// Returns the rent diff for a given projection month index,
  /// applying annual compounding if annualIncreaseRate > 0.
  static double _rentDiffForMonth(RentChangeChange c, int monthIndex) {
    final baseDiff = c.newRent - c.currentRent;
    if (c.annualIncreaseRate <= 0) return baseDiff;
    final yearsPassed = (monthIndex / 12).floor();
    return baseDiff * pow(1 + c.annualIncreaseRate / 100, yearsPassed);
  }

  static ChangeResult _calcSalaryChange(SalaryChangeChange c) {
    final currentNets = FinancialCalculator.resolveAllMonths(
      amount: c.currentGross,
      isGross: true,
    );
    final newNets = FinancialCalculator.resolveAllMonths(
      amount: c.newGross,
      isGross: true,
    );

    final currentAvg = currentNets.reduce((a, b) => a + b) / 12;
    final newAvg = newNets.reduce((a, b) => a + b) / 12;
    final monthlyDelta = newAvg - currentAvg;

    return ChangeResult(
      change: c,
      monthlyImpact: monthlyDelta,
      salaryImpact: SalaryImpact(
        currentGross: c.currentGross,
        newGross: c.newGross,
        currentNetAvg: currentAvg,
        newNetAvg: newAvg,
        monthlyNetDelta: monthlyDelta,
        currentMonthlyNets: currentNets,
        newMonthlyNets: newNets,
      ),
    );
  }

  static ChangeResult _calcIncome(IncomeChange c) {
    return ChangeResult(
      change: c,
      monthlyImpact: c.amount,
    );
  }

  static ChangeResult _calcExpense(ExpenseChange c) {
    return ChangeResult(
      change: c,
      monthlyImpact: -c.amount,
    );
  }

  static ChangeResult _calcInvestment(InvestmentChange c) {
    double totalReturn;
    if (c.isCompound) {
      final monthlyRate = c.annualReturnRate / 100 / 12;
      totalReturn =
          c.principal * (pow(1 + monthlyRate, c.termMonths) - 1).toDouble();
    } else {
      totalReturn =
          c.principal * (c.annualReturnRate / 100) * (c.termMonths / 12);
    }
    final monthlyReturn = totalReturn / c.termMonths;

    return ChangeResult(
      change: c,
      monthlyImpact: monthlyReturn,
      investmentImpact: InvestmentImpact(
        principal: c.principal,
        totalReturn: totalReturn,
        monthlyReturn: monthlyReturn,
        totalValue: c.principal + totalReturn,
        termMonths: c.termMonths,
        isCompound: c.isCompound,
      ),
    );
  }

  // ─── Annual Impact Calculator ────────────────────────────────────

  /// Computes the correct annual net impact, accounting for:
  /// - Salary changes: sum of all 12 months' actual deltas (tax brackets vary)
  /// - Term-limited changes: capped at actual term (not always 12 months)
  static double _calculateAnnualImpact(
    List<SimulationChange> changes,
    List<ChangeResult> changeResults,
  ) {
    double annual = 0;
    for (int i = 0; i < changes.length; i++) {
      final change = changes[i];
      final result = changeResults[i];

      if (change is SalaryChangeChange && result.salaryImpact != null) {
        final si = result.salaryImpact!;
        annual += si.newMonthlyNets.reduce((a, b) => a + b) -
            si.currentMonthlyNets.reduce((a, b) => a + b);
      } else {
        final effectiveMonths = switch (change) {
          CreditChange c => min(c.termMonths, 12),
          HousingChange c => min(c.termMonths, 12),
          CarChange c => min(c.termMonths, 12),
          InvestmentChange c => min(c.termMonths, 12),
          _ => 12,
        };
        annual += result.monthlyImpact * effectiveMonths;
      }
    }
    return annual;
  }

  // ─── 12-Month Projection Builder ────────────────────────────────

  static List<MonthProjection> _buildProjection({
    required List<SimulationChange> changes,
    required List<ChangeResult> changeResults,
    required MonthSummary currentBudget,
    required List<MonthLineItem> existingIncomeItems,
    required List<MonthLineItem> existingExpenseItems,
    List<ProjectionBaseItem> baseItems = const [],
  }) {
    final now = DateTime.now();
    final projections = <MonthProjection>[];
    double cumulative = 0;

    for (int i = 0; i < 12; i++) {
      final projMonth = DateTime(now.year, now.month + i);
      final ym =
          '${projMonth.year}-${projMonth.month.toString().padLeft(2, '0')}';
      final monthLabel = FinancialCalculator.monthShortNamesTR[
          (projMonth.month - 1) % 12];

      // Base: dynamic (recurring items filtered by active date range)
      //       or static fallback (current budget snapshot)
      double monthIncome;
      double monthExpense;
      final incomeItems = <MonthLineItem>[];
      final expenseItems = <MonthLineItem>[];

      if (baseItems.isNotEmpty) {
        monthIncome = 0;
        monthExpense = 0;
        for (final item in baseItems) {
          if (!item.isActiveOn(projMonth)) continue;
          final amount = item.grossAmount != null
              ? FinancialCalculator.resolveNetForMonth(
                  amount: item.grossAmount!,
                  isGross: true,
                  month: projMonth.month,
                )
              : item.netAmount;
          if (item.isIncome) {
            monthIncome += amount;
            incomeItems.add(MonthLineItem(label: item.label, amount: amount));
          } else {
            monthExpense += amount;
            expenseItems.add(MonthLineItem(label: item.label, amount: amount));
          }
        }
      } else {
        monthIncome = currentBudget.totalIncome;
        monthExpense = currentBudget.totalExpense;
        incomeItems.addAll(existingIncomeItems);
        expenseItems.addAll(existingExpenseItems);
      }

      // Apply each change
      for (int ci = 0; ci < changes.length; ci++) {
        final change = changes[ci];
        final result = changeResults[ci];

        // Check term limits for loan-based changes
        final isWithinTerm = switch (change) {
          CreditChange c => i < c.termMonths,
          HousingChange c => i < c.termMonths,
          CarChange c => i < c.termMonths,
          InvestmentChange c => i < c.termMonths,
          _ => true,
        };

        if (!isWithinTerm) continue;

        // Rent changes with annual increase: recompute diff for this month
        if (change is RentChangeChange && change.annualIncreaseRate > 0) {
          final rentDiff = _rentDiffForMonth(change, i);
          monthExpense += rentDiff;
          expenseItems.add(MonthLineItem(
            label: change.label,
            amount: rentDiff,
            isSimulated: true,
          ));
          continue;
        }

        // Salary changes use per-month net (Turkish tax brackets vary)
        if (change is SalaryChangeChange && result.salaryImpact != null) {
          final si = result.salaryImpact!;
          final monthIdx = (projMonth.month - 1) % 12;
          final delta = si.newMonthlyNets[monthIdx] - si.currentMonthlyNets[monthIdx];
          monthIncome += delta;
          incomeItems.add(MonthLineItem(
            label: change.label,
            amount: delta,
            isSimulated: true,
          ));
          continue;
        }

        if (result.monthlyImpact > 0) {
          monthIncome += result.monthlyImpact;
          incomeItems.add(MonthLineItem(
            label: change.label,
            amount: result.monthlyImpact,
            isSimulated: true,
          ));
        } else if (result.monthlyImpact < 0) {
          monthExpense += result.monthlyImpact.abs();
          expenseItems.add(MonthLineItem(
            label: change.label,
            amount: result.monthlyImpact.abs(),
            isSimulated: true,
          ));
        }
      }

      final net = monthIncome - monthExpense;
      cumulative += net;

      projections.add(MonthProjection(
        yearMonth: ym,
        monthLabel: monthLabel,
        income: monthIncome,
        expense: monthExpense,
        net: net,
        cumulativeNet: cumulative,
        incomeItems: incomeItems,
        expenseItems: expenseItems,
      ));
    }

    return projections;
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

  // ─── Empty Result ────────────────────────────────────────────────

  static SimulationResult _emptyResult(
    MonthSummary budget,
    List<MonthLineItem> incomeItems,
    List<MonthLineItem> expenseItems,
    List<ProjectionBaseItem> baseItems,
  ) {
    final now = DateTime.now();
    return SimulationResult(
      currentIncome: budget.totalIncome,
      currentExpense: budget.totalExpense,
      currentNet: budget.netBalance,
      newIncome: budget.totalIncome,
      newExpense: budget.totalExpense,
      newNet: budget.netBalance,
      monthlyNetImpact: 0,
      annualNetImpact: 0,
      newSavingsRate: budget.savingsRate,
      newExpenseRate: budget.expenseRate,
      changeResults: [],
      monthlyProjection: List.generate(12, (i) {
        final m = DateTime(now.year, now.month + i);
        final ym = '${m.year}-${m.month.toString().padLeft(2, '0')}';

        double monthInc;
        double monthExp;
        List<MonthLineItem> mIncItems;
        List<MonthLineItem> mExpItems;

        if (baseItems.isNotEmpty) {
          monthInc = 0;
          monthExp = 0;
          mIncItems = [];
          mExpItems = [];
          for (final item in baseItems) {
            if (!item.isActiveOn(m)) continue;
            final amount = item.grossAmount != null
                ? FinancialCalculator.resolveNetForMonth(
                    amount: item.grossAmount!,
                    isGross: true,
                    month: m.month,
                  )
                : item.netAmount;
            if (item.isIncome) {
              monthInc += amount;
              mIncItems.add(MonthLineItem(label: item.label, amount: amount));
            } else {
              monthExp += amount;
              mExpItems.add(MonthLineItem(label: item.label, amount: amount));
            }
          }
        } else {
          monthInc = budget.totalIncome;
          monthExp = budget.totalExpense;
          mIncItems = incomeItems;
          mExpItems = expenseItems;
        }

        final net = monthInc - monthExp;
        return MonthProjection(
          yearMonth: ym,
          monthLabel: FinancialCalculator.monthShortNamesTR[(m.month - 1) % 12],
          income: monthInc,
          expense: monthExp,
          net: net,
          cumulativeNet: net * (i + 1),
          incomeItems: mIncItems,
          expenseItems: mExpItems,
        );
      }),
    );
  }

}
