import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:savvy/core/providers/repository_providers.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/simulation/domain/models/simulation_change.dart';
import 'package:savvy/features/simulation/domain/models/simulation_entry.dart';
import 'package:savvy/features/simulation/domain/models/simulation_result.dart';
part 'simulation_provider.g.dart';

@riverpod
Stream<List<SimulationEntry>> allSimulations(Ref ref) {
  return ref.watch(simulationRepositoryProvider).watchAll();
}

/// Builds the dynamic projection base from all active recurring incomes/expenses.
/// Each screen passes this to [SimulationCalculator.calculateScenario] so that
/// the 12-month projection respects start/end dates of recurring items.
@riverpod
List<ProjectionBaseItem> projectionBaseItems(Ref ref) {
  final incomes = ref.watch(allIncomesProvider).value ?? [];
  final expenses = ref.watch(allExpensesProvider).value ?? [];

  return [
    for (final i in incomes)
      if (!i.isDeleted && i.isRecurring)
        ProjectionBaseItem(
          label: i.source?.isNotEmpty == true ? i.source! : i.category.label,
          isIncome: true,
          startDate: i.date,
          endDate: i.recurringEndDate,
          grossAmount: i.isGross ? i.amount : null,
          netAmount: i.isGross ? 0 : i.amount,
        ),
    for (final e in expenses)
      if (!e.isDeleted && e.isRecurring)
        ProjectionBaseItem(
          label: e.note?.isNotEmpty == true ? e.note! : e.category.label,
          isIncome: false,
          startDate: e.date,
          endDate: e.recurringEndDate,
          netAmount: e.amount,
        ),
  ];
}

@riverpod
class SimulationNotifier extends _$SimulationNotifier {
  @override
  FutureOr<void> build() {}

  Future<bool> addSimulation(SimulationEntry simulation) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(simulationRepositoryProvider).add(simulation);
    });
    if (ref.mounted) state = result;
    return !result.hasError;
  }

  Future<bool> updateSimulation(SimulationEntry simulation) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(simulationRepositoryProvider).update(simulation);
    });
    if (ref.mounted) state = result;
    return !result.hasError;
  }

  Future<bool> deleteSimulation(String id) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(simulationRepositoryProvider).softDelete(id);
    });
    if (ref.mounted) state = result;
    return !result.hasError;
  }

  Future<bool> toggleInclude(SimulationEntry simulation) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(simulationRepositoryProvider).update(
            simulation.copyWith(isIncluded: !simulation.isIncluded),
          );
    });
    if (ref.mounted) state = result;
    return !result.hasError;
  }
}

/// Gets the monthly expense impact of a simulation from its composable changes.
double simulationMonthlyPayment(SimulationEntry sim) {
  double total = 0;
  for (final change in sim.changes) {
    switch (change) {
      case CreditChange():
        total += FinancialCalculator.monthlyLoanPayment(
          principal: change.principal,
          annualRate: change.annualRate / 100,
          termMonths: change.termMonths,
        );
      case HousingChange():
        final loan = change.price - change.downPayment;
        if (loan > 0) {
          total += FinancialCalculator.monthlyLoanPayment(
            principal: loan,
            annualRate: change.annualRate / 100,
            termMonths: change.termMonths,
          );
        }
        total += change.monthlyExtras;
      case CarChange():
        final loan = change.price - change.downPayment;
        if (loan > 0) {
          total += FinancialCalculator.monthlyLoanPayment(
            principal: loan,
            annualRate: change.annualRate / 100,
            termMonths: change.termMonths,
          );
        }
        total += change.monthlyRunningCosts;
      case RentChangeChange():
        total += (change.newRent - change.currentRent).abs();
      case ExpenseChange():
        total += change.amount;
      case SalaryChangeChange():
      case IncomeChange():
      case InvestmentChange():
        break;
    }
  }
  return total;
}

/// Gets the max term months across all changes in a simulation.
int? simulationMaxTermMonths(SimulationEntry sim) {
  int? maxTerm;
  for (final change in sim.changes) {
    final term = switch (change) {
      CreditChange() => change.termMonths,
      HousingChange() => change.termMonths,
      CarChange() => change.termMonths,
      InvestmentChange() => change.termMonths,
      _ => null,
    };
    if (term != null && (maxTerm == null || term > maxTerm)) {
      maxTerm = term;
    }
  }
  return maxTerm;
}

/// Future projections that include "included" simulations.
@riverpod
List<MonthSummary> simulationAwareProjections(Ref ref) {
  final baseProjections = ref.watch(futureProjectionsProvider);
  final simsAsync = ref.watch(allSimulationsProvider);
  final sims = simsAsync.value ?? [];

  final included = sims.where((s) => s.isIncluded).toList();
  if (included.isEmpty) return baseProjections;

  double totalSimExpense = 0;
  for (final sim in included) {
    totalSimExpense += simulationMonthlyPayment(sim);
  }

  if (totalSimExpense <= 0) return baseProjections;

  double cumulativeAdjustment = 0;
  return baseProjections.map((proj) {
    final range = YearMonthRange.from(proj.yearMonth);
    final projDate = range.start;
    final now = DateTime.now();
    final monthsFromNow =
        (projDate.year - now.year) * 12 + projDate.month - now.month;

    double monthExtra = 0;
    for (final sim in included) {
      final termMonths = simulationMaxTermMonths(sim);
      if (termMonths != null && monthsFromNow > termMonths) continue;
      monthExtra += simulationMonthlyPayment(sim);
    }

    final newExpense = proj.totalExpense + monthExtra;
    final newNet = proj.totalIncome - newExpense;
    cumulativeAdjustment += -monthExtra;
    final newCum = proj.netWithCarryOver + cumulativeAdjustment;
    final savingsRate = proj.totalIncome > 0
        ? ((proj.totalIncome - newExpense) / proj.totalIncome).clamp(0.0, 1.0)
        : 0.0;
    final expenseRate = proj.totalIncome > 0
        ? (newExpense / proj.totalIncome).clamp(0.0, 2.0)
        : 0.0;

    return proj.copyWith(
      totalExpense: newExpense,
      netBalance: newNet,
      netWithCarryOver: newCum,
      savingsRate: savingsRate,
      expenseRate: expenseRate,
      healthScore: FinancialCalculator.financialHealthScore(
        savingsRate: savingsRate,
        expenseRatio: expenseRate,
        netBalance: newNet,
        emergencyFundMonths: 0,
      ),
    );
  }).toList();
}
