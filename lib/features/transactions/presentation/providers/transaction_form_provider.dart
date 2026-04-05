import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:savvy/core/providers/repository_providers.dart';
import 'package:savvy/features/transactions/domain/models/income.dart';
import 'package:savvy/features/transactions/domain/models/expense.dart';
import 'package:savvy/features/savings/domain/models/savings.dart';

part 'transaction_form_provider.g.dart';

@riverpod
class TransactionFormNotifier extends _$TransactionFormNotifier {
  @override
  FutureOr<void> build() {}

  // ─── Add ─────────────────────────────────────────────────────────────

  Future<bool> addIncome(Income income) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(incomeRepositoryProvider).add(income);
    });
    if (!ref.mounted) return true;
    state = result;
    return !state.hasError;
  }

  Future<bool> addExpense(Expense expense) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(expenseRepositoryProvider).add(expense);
    });
    if (!ref.mounted) return true;
    state = result;
    return !state.hasError;
  }

  Future<bool> addSavings(Savings savings) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(savingsRepositoryProvider).add(savings);
    });
    if (!ref.mounted) return true;
    state = result;
    return !state.hasError;
  }

  // ─── Update ──────────────────────────────────────────────────────────

  Future<bool> updateIncome(Income income) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(incomeRepositoryProvider).update(income);
    });
    if (!ref.mounted) return true;
    state = result;
    return !state.hasError;
  }

  Future<bool> updateExpense(Expense expense) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(expenseRepositoryProvider).update(expense);
    });
    if (!ref.mounted) return true;
    state = result;
    return !state.hasError;
  }

  Future<bool> updateSavings(Savings savings) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(savingsRepositoryProvider).update(savings);
    });
    if (!ref.mounted) return true;
    state = result;
    return !state.hasError;
  }

  // ─── Delete (soft) ───────────────────────────────────────────────────

  Future<bool> deleteMultipleIncomes(List<String> ids) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(incomeRepositoryProvider).softDeleteMany(ids);
    });
    if (!ref.mounted) return true;
    state = result;
    return !state.hasError;
  }

  Future<bool> deleteIncome(String id) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(incomeRepositoryProvider).softDelete(id);
    });
    if (!ref.mounted) return true;
    state = result;
    return !state.hasError;
  }

  Future<bool> deleteExpense(String id) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(expenseRepositoryProvider).softDelete(id);
    });
    if (!ref.mounted) return true;
    state = result;
    return !state.hasError;
  }

  Future<bool> deleteSavings(String id) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(savingsRepositoryProvider).softDelete(id);
    });
    if (!ref.mounted) return true;
    state = result;
    return !state.hasError;
  }
}
