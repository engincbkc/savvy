import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/providers/repository_providers.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/features/budget/domain/models/budget_limit.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';

part 'budget_provider.g.dart';

/// Streams all active (non-deleted) budget limits from Firestore.
@riverpod
Stream<List<BudgetLimit>> budgetLimits(Ref ref) {
  return ref.watch(budgetLimitRepositoryProvider).watchAll();
}

/// Notifier for CRUD operations on budget limits.
@riverpod
class BudgetLimitNotifier extends _$BudgetLimitNotifier {
  @override
  FutureOr<void> build() {}

  Future<bool> upsert(BudgetLimit limit) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(budgetLimitRepositoryProvider).upsert(limit);
    });
    return !state.hasError;
  }

  Future<bool> softDelete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(budgetLimitRepositoryProvider).softDelete(id);
    });
    return !state.hasError;
  }
}

/// Computes total spending per category for a given yearMonth.
/// Returns Map of ExpenseCategory to total spent amount.
@riverpod
Map<ExpenseCategory, double> budgetUsage(Ref ref, String yearMonth) {
  final allExpenses = ref.watch(allExpensesProvider).value ?? [];
  final result = <ExpenseCategory, double>{};

  for (final expense in allExpenses) {
    if (expense.date.toYearMonth() != yearMonth) continue;
    result[expense.category] =
        (result[expense.category] ?? 0.0) + expense.amount;
  }

  return result;
}
