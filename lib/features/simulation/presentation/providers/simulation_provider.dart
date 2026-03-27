import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:savvy/core/providers/repository_providers.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/simulation/domain/models/simulation_entry.dart';

part 'simulation_provider.g.dart';

@riverpod
Stream<List<SimulationEntry>> allSimulations(Ref ref) {
  return ref.watch(simulationRepositoryProvider).watchAll();
}

@riverpod
class SimulationNotifier extends _$SimulationNotifier {
  @override
  FutureOr<void> build() {}

  Future<bool> addSimulation(SimulationEntry simulation) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(simulationRepositoryProvider).add(simulation);
    });
    return !state.hasError;
  }

  Future<bool> updateSimulation(SimulationEntry simulation) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(simulationRepositoryProvider).update(simulation);
    });
    return !state.hasError;
  }

  Future<bool> deleteSimulation(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(simulationRepositoryProvider).softDelete(id);
    });
    return !state.hasError;
  }

  Future<bool> toggleInclude(SimulationEntry simulation) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(simulationRepositoryProvider).update(
            simulation.copyWith(isIncluded: !simulation.isIncluded),
          );
    });
    return !state.hasError;
  }
}

/// Gets the monthly payment (expense impact) of a simulation.
double simulationMonthlyPayment(SimulationEntry sim) {
  return (sim.parameters['monthlyPayment'] as num?)?.toDouble() ?? 0;
}

/// Future projections that include "included" simulations.
/// Adds each included simulation's monthly payment as an extra expense.
@riverpod
List<MonthSummary> simulationAwareProjections(Ref ref) {
  final baseProjections = ref.watch(futureProjectionsProvider);
  final simsAsync = ref.watch(allSimulationsProvider);
  final sims = simsAsync.value ?? [];

  // Filter to included simulations only
  final included = sims.where((s) => s.isIncluded).toList();
  if (included.isEmpty) return baseProjections;

  // Calculate total monthly payment from all included simulations
  double totalSimExpense = 0;
  for (final sim in included) {
    totalSimExpense += simulationMonthlyPayment(sim);
  }

  if (totalSimExpense <= 0) return baseProjections;

  // Apply to each projection month
  double cumulativeAdjustment = 0;
  return baseProjections.map((proj) {
    // Check if this month is still within the term for each sim
    final range = YearMonthRange.from(proj.yearMonth);
    final projDate = range.start;
    final now = DateTime.now();
    final monthsFromNow =
        (projDate.year - now.year) * 12 + projDate.month - now.month;

    double monthExtra = 0;
    for (final sim in included) {
      final termMonths = (sim.parameters['termMonths'] as num?)?.toInt();
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
